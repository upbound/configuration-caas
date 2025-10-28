import models.io.upbound.caas.mcp.v1alpha1 as caasmcpv1alpha1
import models.io.upbound.iam.v1alpha1 as iamv1alpha1
import models.io.upbound.v1alpha1 as upboundv1alpha1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2

import pKubernetesHelper
import utils

oxr = option("params").oxr
_ocds = option("params").ocds

# Extract parameters from XR
controlPlaneName = oxr.metadata.name
organizationName = oxr.spec.parameters.organizationName
# Upbound Space host (e.g., upbound-gcp-us-central-1.space.mxe.upbound.io)
spaceHost = oxr.spec.parameters.spaceHost
# Group (namespace) where the ControlPlane will be created
groupName = oxr.spec.parameters.groupName
configuration = oxr.spec.parameters.configuration
robotPermission = oxr.spec.parameters.robotPermission
upboundTokenSecretName = oxr.spec?.parameters?.upboundTokenSecretName or "upbound-token"
upboundTokenSecretNamespace = oxr.spec?.parameters?.upboundTokenSecretNamespace or "upbound-system"
upboundTokenSecretKey = oxr.spec?.parameters?.upboundTokenSecretKey or "token"
# Bootstrap provider-kubernetes ProviderConfig (must exist in the control plane)
# This is used to create the kubeconfig Secret, then we create a new ProviderConfig
bootstrapProviderConfigName = oxr.spec?.parameters?.bootstrapProviderConfigName or "default"

# Computed names
robotName = "{}-robot".format(controlPlaneName)
teamName = "{}-team".format(controlPlaneName)
tokenSecretName = "{}-robot-token".format(controlPlaneName)
providerConfigNameUpbound = "{}-upbound".format(controlPlaneName)

# Get status values from observed composed resources
teamExternalName = _ocds?["mcp-team"]?.Resource?.metadata?.annotations?["crossplane.io/external-name"]
tokenSecret = _ocds?["mcp-robot-token"]?.Resource?.spec?.writeConnectionSecretToRef?.name
tokenAccessID = _ocds?["mcp-robot-token"]?.Resource?.metadata?.annotations?["crossplane.io/external-name"]
connectionSecretName = "{}-connection-details".format(controlPlaneName)

_items = [
    # ProviderConfig for provider-upbound using the supplied token
    upboundv1alpha1.ProviderConfig{
        metadata: {
            annotations: {
                "krm.kcl.dev/composition-resource-name": "providerConfigUpbound"
                "krm.kcl.dev/ready": "True"
            }
            name: providerConfigNameUpbound
        }
        spec: {
            credentials: {
                secretRef: {
                    name: upboundTokenSecretName
                    namespace: upboundTokenSecretNamespace
                    key: upboundTokenSecretKey
                }
                source: "Secret"
            }
            organization: organizationName
        }
    }
    # ControlPlane in Upbound Spaces (the actual MCP)
    kubernetesv1alpha2.Object{
        metadata: utils._metadata("controlplane") | {
            name: "{}-ctp".format(controlPlaneName)
        }
        spec: {
            forProvider: {
                manifest: {
                    apiVersion: "spaces.upbound.io/v1beta1"
                    kind: "ControlPlane"
                    metadata: {
                        name: controlPlaneName
                        namespace: groupName
                    }
                    spec: {
                        writeConnectionSecretToRef: {
                            name: "{}-kubeconfig".format(controlPlaneName)
                        }
                    }
                }
            }
            providerConfigRef: {
                name: "{}-group".format(groupName)
            }
        }
    }
    # Robot for the control plane
    iamv1alpha1.Robot{
        metadata: utils._metadata("mcp-robot") | {
            name: robotName
        }
        spec: {
            forProvider: {
                name: robotName
                owner: {
                    name: organizationName
                }
                description: "Robot for {}".format(controlPlaneName)
            }
            providerConfigRef: {
                name: providerConfigNameUpbound
            }
        }
    }
    # Robot Token
    iamv1alpha1.Token{
        metadata: utils._metadata("mcp-robot-token") | {
            name: tokenSecretName
        }
        spec: {
            forProvider: {
                name: controlPlaneName
                owner: {
                    idRef: {
                        name: robotName
                    }
                    type: "robots"
                }
            }
            providerConfigRef: {
                name: providerConfigNameUpbound
            }
            writeConnectionSecretToRef: {
                name: tokenSecretName
                namespace: "upbound-system"
            }
        }
    }
    # Team
    iamv1alpha1.Team{
        metadata: utils._metadata("mcp-team") | {
            name: teamName
        }
        spec: {
            deletionPolicy: "Orphan"
            forProvider: {
                organizationName: organizationName
                name: teamName
            }
            providerConfigRef: {
                name: providerConfigNameUpbound
            }
        }
    }
    # Robot team membership
    iamv1alpha1.RobotTeamMembership{
        metadata: utils._metadata("mcp-team-membership") | {
            name: "{}-membership".format(robotName)
        }
        spec: {
            forProvider: {
                robotIdRef: {
                    name: robotName
                }
                teamIdRef: {
                    name: teamName
                }
            }
            providerConfigRef: {
                name: providerConfigNameUpbound
            }
        }
    }
]

# ObjectRoleBinding for team access to the group namespace
# Only create when team external name is available from the observed Team resource
if teamExternalName:
    _items += [
        kubernetesv1alpha2.Object{
            metadata: utils._metadata("team-admin-binding") | {
                name: "{}-admin-binding".format(controlPlaneName)
            }
            spec: {
                forProvider: {
                    manifest: {
                        apiVersion: "authorization.spaces.upbound.io/v1alpha1"
                        kind: "ObjectRoleBinding"
                        metadata: {
                            name: "{}-admin-binding".format(controlPlaneName)
                            namespace: groupName
                        }
                        spec: {
                            object: {
                                apiGroup: "core"
                                resource: "namespaces"
                                name: groupName
                            }
                            subjects: [
                                {
                                    kind: "UpboundTeam"
                                    role: robotPermission
                                    name: teamExternalName
                                }
                            ]
                        }
                    }
                }
                providerConfigRef: {
                    name: "{}-group".format(groupName)
                }
            }
        }
    ]

# Use pKubernetesHelper to create group-level provider config (for creating control planes and managing access in the group)
_items += pKubernetesHelper.upboundProviderConfig(pKubernetesHelper.UpboundProviderConfigInput{
    spaceHost = spaceHost
    org = organizationName
    group = groupName
    providerConfigName = bootstrapProviderConfigName
    upboundTokenSecretRef = pKubernetesHelper.UpboundTokenSecretRef{
        name = upboundTokenSecretName
        namespace = upboundTokenSecretNamespace
        key = upboundTokenSecretKey
    }
})

# Status updates - add to desired composite resource status
_dxr = {
    **option("params").dxr
    **{
        status: {
            mcp: {
                **({tokenSecret: tokenSecret} if tokenSecret else {})
                **({tokenAccessID: tokenAccessID} if tokenAccessID else {})
                connectionSecretName: connectionSecretName
            }
        }
    }
}

# Connection details for kubeconfig
# The ControlPlane writes its kubeconfig to a secret in Upbound Spaces
# We'll need to observe that secret to extract the kubeconfig
# For now, marking this as a placeholder for kubeconfig propagation
_kubeconfigSecretData = _ocds?.controlplane?.Resource?.status?.atProvider?.manifest?.data?.kubeconfig
_items += [{
    apiVersion: "meta.krm.kcl.dev/v1alpha1"
    kind: "CompositeConnectionDetails"
    data: {
        **({kubeconfig: _kubeconfigSecretData} if _kubeconfigSecretData else {})
    }
}]

items = _items
dxr = _dxr
