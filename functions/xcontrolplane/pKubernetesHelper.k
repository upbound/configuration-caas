"""
Helper module that provides functions for configuring Kubernetes providers and
generating kubeconfig objects for connecting to Upbound Spaces.

This module supports creating provider configurations at different scopes:
- Space level: For accessing APIs at the Upbound Spaces level
- Group level: For accessing APIs at the environment group level
- Control plane level: For accessing APIs within a specific control plane
"""

import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2
import models.io.crossplane.kubernetes.v1alpha1 as kubernetesv1alpha1
import utils

schema UpboundTokenSecretRef:
    name: str
    namespace: str
    key: str

schema UpboundProviderConfigInput:
    """
    Input schema for configuring a Kubernetes provider for Upbound Spaces.
    Exactly one of group+ctp or prefix must be provided to determine the scope.
    """
    spaceHost: str  # The Upbound Spaces host (e.g. spaces.upbound.io)
    org: str        # The Upbound organization name
    group?: str     # Optional: The group name for group-level access
    ctp?: str       # Optional: The control plane name for control plane-level access
    # should be set when neither group nor ctp is set
    prefix?: str    # Optional: Prefix for space-level access (when no group/ctp provided)
    providerConfigName: str  # Name of the provider config to reference
    upboundTokenSecretRef: UpboundTokenSecretRef        # Reference to the Upbound authentication token

# Helper for generating a controlplane, space or group-level kubeconfig for provider-kubernetes on upbound
# This function creates a kubeconfig that targets the appropriate API endpoint based on the scope:
# - If ctp and group are provided: Targets a specific control plane within a group
# - If only group is provided: Targets all control planes within a group
# - If neither is provided: Targets the space-level APIs
upboundKubeconfig = lambda spaceHost: str, org: str, group: str, ctp: str -> any { str({
    apiVersion = "v1"
    clusters = [
        {
            cluster = {
                "insecure-skip-tls-verify" = True
                if ctp == "":
                    server = "https://{}".format(spaceHost)
                else:
                    server = "https://{}/apis/spaces.upbound.io/v1beta1/namespaces/{}/controlplanes/{}/k8s".format(spaceHost, group, ctp)
            }
            name = "upbound"
        }
    ]
    contexts = [
        {
            context = {
                cluster = "upbound"
                extensions = [
                    {
                        extension = {
                            apiVersion = "upbound.io/v1alpha1"
                            kind = "SpaceExtension"
                            spec = {
                                cloud = {
                                    organization = org
                                }
                            }
                        }
                        name = "spaces.upbound.io/space"
                    }
                ]
                if ctp == "":
                    namespace = group
                else:
                    namespace = "default"
                user = "upbound"
            }
            name = "upbound"
        }
    ]
    "current-context" = "upbound"
    kind = "Config"
    preferences = {}
    users = [
        {
            name = "upbound"
            user = {
                exec = {
                    apiVersion = "client.authentication.k8s.io/v1"
                    args = [
                        "organization"
                        "token"
                    ]
                    command = "up"
                    env = [
                        {
                            name = "ORGANIZATION"
                            value = org
                        }
                        {
                            name = "UP_PROFILE"
                            value = "default"
                        }
                    ]
                    interactiveMode: "IfAvailable"
                    provideClusterInfo = False
                }
            }

        }
    ]
})}

configName = lambda group: str, ctp: str, prefix: str -> any {
   """
   Generates a configuration name based on the scope:
   - For control plane scope: "<ctp>-ctp"
   - For group scope: "<group>-group"
   - For space scope: "<prefix>-space"
   """
   "{}-ctp".format(ctp) if ctp else ("{}-group".format(group) if group else "{}-space".format(prefix))
}

resourceName = lambda group: str, ctp: str -> any {
   """
   Generates a resource name identifier based on the scope:
   - For control plane scope: "envCtp"
   - For group scope: "envGroup"
   - For space scope: "space"
   """
   "envCtp" if ctp else ("envGroup" if group else "space")
}

upboundProviderConfig = lambda config: UpboundProviderConfigInput -> any {
   """
   Creates a complete Kubernetes provider configuration bundle for Upbound Spaces, including:
   1. A Kubernetes Object to store the kubeconfig secret
   2. A ProviderConfig that references the kubeconfig secret
   3. A Usage resource to establish dependency between the secret and provider config

   Returns a list of these three resources properly configured for the specified scope.
   """
   [
        kubernetesv1alpha2.Object{
            metadata = utils._metadata("{}Kubeconfig".format(resourceName(config.group, config.ctp))) | {
                name = "{}-kubeconfig".format(configName(config.group, config.ctp, config.prefix))
            }
            spec = {
                forProvider = {
                    manifest = {
                        apiVersion = "v1"
                        kind = "Secret"
                        metadata = {
                            name = "{}-kubeconfig".format(configName(config.group, config.ctp, config.prefix))
                            namespace = "default"
                        }
                        stringData = {
                            kubeconfig = upboundKubeconfig(
                                            config.spaceHost,
                                            config.org,
                                            config.group if config.group else "default",
                                            config.ctp if config.ctp else "")
                        }
                    }
                }
                providerConfigRef = {
                    name = config.providerConfigName
                }
            }
        }

        kubernetesv1alpha1.ProviderConfig{
            metadata = utils._metadata("{}ProviderConfig".format(resourceName(config.group, config.ctp))) | {
                name = configName(config.group, config.ctp, config.prefix)
                annotations = {
                  "krm.kcl.dev/ready" = "True"
                }
            }
            spec = {
                credentials = {
                    source = "Secret"
                    secretRef = {
                        name = "{}-kubeconfig".format(configName(config.group, config.ctp, config.prefix))
                        namespace = "default"
                        key = "kubeconfig"
                    }
                }
                identity = {
                    type = "UpboundTokens"
                    source = "Secret"
                    secretRef = {
                        # Uses the token from the shared bootstrap control plane
                        name = config.upboundTokenSecretRef.name
                        namespace = config.upboundTokenSecretRef.namespace
                        key = config.upboundTokenSecretRef.key
                    }
                }
            }
        }

        {
            apiVersion = "apiextensions.crossplane.io/v1alpha1"
            kind = "Usage"
            metadata = utils._metadata("{}Usage".format(resourceName(config.group, config.ctp))) | {
                name = "{}-kubeconfig".format(configName(config.group, config.ctp, config.prefix))
            }
            spec = {
                replayDeletion = True
                of = {
                    apiVersion = "kubernetes.crossplane.io/v1alpha2"
                    kind = "Object"
                    resourceRef = {
                        name = "{}-kubeconfig".format(configName(config.group, config.ctp, config.prefix))
                    }
                }
                by = {
                    apiVersion = "kubernetes.crossplane.io/v1alpha1"
                    kind = "ProviderConfig"
                    resourceRef = {
                        name = configName(config.group, config.ctp, config.prefix)
                    }
                }
            }
        }
]}

