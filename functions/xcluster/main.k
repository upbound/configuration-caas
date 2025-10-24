import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1
import models.io.upbound.platform.azure.v1alpha1 as azurev1alpha1
import models.io.upbound.platform.gcp.v1alpha1 as gcpv1alpha1
import models.io.upbound.platform.observe.v1alpha1 as observev1alpha1
import models.io.crossplane.apiextensions.v1alpha1 as apiextensionsv1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1

oxr = option("params").oxr
_ocds = option("params").ocds

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

# Helper function to check if a resource is ready
_isReady = lambda resourceName: str -> bool {
    resource = _ocds?[resourceName]?.Resource
    conditions = resource?.status?.conditions or []
    all_true([c.status == "True" for c in conditions if c.type == "Ready"]) if len(conditions) > 0 else False
}

# Extract parameters from XR
cloud = oxr.spec.parameters.cloud
id = oxr.spec.parameters.id
region = oxr.spec.parameters.region
deletionPolicy = oxr.spec.parameters.deletionPolicy
providerConfigName = oxr.spec.parameters.providerConfigName
version = oxr.spec.parameters.version
nodeCount = oxr.spec.parameters.nodes.count
instanceType = oxr.spec.parameters.nodes.instanceType
iamRoleArn = oxr.spec?.parameters?.iam?.roleArn
iamUserArn = oxr.spec?.parameters?.iam?.userArn
iamPrincipalArn = iamRoleArn if iamRoleArn else iamUserArn
gitopsOperator = oxr.spec.parameters.gitops.operator
gitopsGit = oxr.spec.parameters.gitops.git
gitopsIngressUrl = oxr.spec?.parameters?.gitops?.ingressUrl
gitopsOidcConfig = oxr.spec?.parameters?.gitops?.oidcConfig
prometheusVersion = oxr.spec.parameters.operators.prometheus.version
fluxVersion = oxr.spec?.parameters?.operators?.flux?.version
fluxSyncVersion = oxr.spec?.parameters?.operators?.fluxSync?.version
argocdVersion = oxr.spec?.parameters?.operators?.argocd?.version
uid = oxr.metadata.uid
connectionSecretNamespace = oxr.spec?.writeConnectionSecretToRef?.namespace or "upbound-system"

_items = []

# AWS Resources
if cloud == "aws":
    _items += [
        platformawsv1alpha1.XNetwork{
            metadata: _metadata("XNetworkAWS")
            spec: {
                parameters: {
                    id: id
                    region: region
                    deletionPolicy: deletionPolicy
                    providerConfigName: providerConfigName
                }
            }
        }
        platformawsv1alpha1.XEKS{
            metadata: _metadata("XEKS") | {
                labels: {
                    "xeks.aws.platform.upbound.io/cluster-id": id
                }
                annotations: {
                    "crossplane.io/external-name": id
                }
            }
            spec: {
                parameters: {
                    id: id
                    region: region
                    deletionPolicy: deletionPolicy
                    providerConfigName: providerConfigName
                    version: version
                    accessConfig: {
                        authenticationMode: "API_AND_CONFIG_MAP"
                        bootstrapClusterCreatorAdminPermissions: True
                    }
                    nodes: {
                        count: nodeCount
                        instanceType: instanceType
                    }
                    **({iam: {principalArn: iamPrincipalArn}} if iamPrincipalArn else {})
                }
                writeConnectionSecretToRef: {
                    name: "{}-eks".format(id)
                    namespace: connectionSecretNamespace
                }
            }
        }
        apiextensionsv1alpha1.Usage{
            metadata: _metadata("usageXEksByXOss")
            spec: {
                of: {
                    apiVersion: "aws.platform.upbound.io/v1alpha1"
                    kind: "XEKS"
                    resourceSelector: {
                        matchControllerRef: True
                    }
                }
                by: {
                    apiVersion: "observe.platform.upbound.io/v1alpha1"
                    kind: "XOss"
                    resourceSelector: {
                        matchControllerRef: True
                    }
                }
            }
        }
    ]

# Azure Resources
if cloud == "azure":
    _items += [
        azurev1alpha1.XNetwork{
            metadata: _metadata("XNetworkAZURE")
            spec: {
                parameters: {
                    id: id
                    region: region
                    addressRange: "10.1.0.0/16"
                    generalSubnetRange: "10.1.1.0/24"
                    deletionPolicy: deletionPolicy
                    providerConfigName: providerConfigName
                }
            }
        }
        azurev1alpha1.XAKS{
            metadata: _metadata("XAKS") | {
                labels: {
                    "xaks.azure.platform.upbound.io/cluster-id": id
                }
            }
            spec: {
                parameters: {
                    id: id
                    region: region
                    deletionPolicy: deletionPolicy
                    providerConfigName: providerConfigName
                    version: version
                    nodes: {
                        count: nodeCount
                        instanceType: instanceType
                    }
                }
                writeConnectionSecretToRef: {
                    name: "{}-aks".format(id)
                    namespace: connectionSecretNamespace
                }
            }
        }
        apiextensionsv1alpha1.Usage{
            metadata: _metadata("usageXAksByXOss")
            spec: {
                of: {
                    apiVersion: "azure.platform.upbound.io/v1alpha1"
                    kind: "XAKS"
                    resourceSelector: {
                        matchControllerRef: True
                    }
                }
                by: {
                    apiVersion: "observe.platform.upbound.io/v1alpha1"
                    kind: "XOss"
                    resourceSelector: {
                        matchControllerRef: True
                    }
                }
            }
        }
    ]

# GCP Resources
if cloud == "gcp":
    _items += [
        gcpv1alpha1.XNetwork{
            metadata: _metadata("XNetworkGCP")
            spec: {
                parameters: {
                    id: id
                    region: region
                    deletionPolicy: deletionPolicy
                    providerConfigName: providerConfigName
                }
            }
        }
        gcpv1alpha1.XGKE{
            metadata: _metadata("XGKE") | {
                labels: {
                    "xgke.gcp.platform.upbound.io/cluster-id": id
                }
                annotations: {
                    "crossplane.io/external-name": id
                }
            }
            spec: {
                parameters: {
                    id: id
                    region: region
                    deletionPolicy: deletionPolicy
                    providerConfigName: providerConfigName
                    version: version
                    nodes: {
                        count: nodeCount
                        instanceType: instanceType
                    }
                }
                writeConnectionSecretToRef: {
                    name: "{}-gke".format(id)
                    namespace: connectionSecretNamespace
                }
            }
        }
        apiextensionsv1alpha1.Usage{
            metadata: _metadata("usageXGkeByXOss")
            spec: {
                of: {
                    apiVersion: "gcp.platform.upbound.io/v1alpha1"
                    kind: "XGKE"
                    resourceSelector: {
                        matchControllerRef: True
                    }
                }
                by: {
                    apiVersion: "observe.platform.upbound.io/v1alpha1"
                    kind: "XOss"
                    resourceSelector: {
                        matchControllerRef: True
                    }
                }
            }
        }
    ]

# Map cloud provider to cluster resource name
_clusterResourceNames = {
    "aws": "XEKS"
    "azure": "XAKS"
    "gcp": "XGKE"
}
_clusterResourceName = _clusterResourceNames[cloud]

# Check if dependent resources already exist (safety checks to prevent uninstalling)
_ossExists = "XOss" in _ocds
_fluxExists = "XFlux" in _ocds
_argoExists = "XArgo" in _ocds

# Observability (created after cluster is ready, or if it already exists)
if _isReady(_clusterResourceName) or _ossExists:
    _items += [
        observev1alpha1.XOss{
            metadata: _metadata("XOss")
            spec: {
                parameters: {
                    deletionPolicy: deletionPolicy
                    id: id
                    operators: {
                        prometheus: {
                            version: prometheusVersion
                        }
                    }
                }
            }
        }
    ]

# Flux GitOps (created after cluster is ready, or if it already exists)
if gitopsOperator == "flux" and (_isReady(_clusterResourceName) or _fluxExists):
    _items += [
        gitopsv1alpha1.XFlux{
            metadata: _metadata("XFlux")
            spec: {
                parameters: {
                    deletionPolicy: deletionPolicy
                    providerConfigName: id
                    operators: {
                        flux: {
                            version: fluxVersion
                        }
                        fluxSync: {
                            version: fluxSyncVersion
                        }
                    }
                    source: {
                        git: gitopsGit
                    }
                }
            }
        }
    ]

    # Usage resources for Flux
    if cloud == "aws":
        _items += [
            apiextensionsv1alpha1.Usage{
                metadata: _metadata("usageXEksByXFlux")
                spec: {
                    of: {
                        apiVersion: "aws.platform.upbound.io/v1alpha1"
                        kind: "XEKS"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                    by: {
                        apiVersion: "gitops.platform.upbound.io/v1alpha1"
                        kind: "XFlux"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                }
            }
        ]
    elif cloud == "azure":
        _items += [
            apiextensionsv1alpha1.Usage{
                metadata: _metadata("usageXAksByXFlux")
                spec: {
                    of: {
                        apiVersion: "azure.platform.upbound.io/v1alpha1"
                        kind: "XAKS"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                    by: {
                        apiVersion: "gitops.platform.upbound.io/v1alpha1"
                        kind: "XFlux"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                }
            }
        ]
    elif cloud == "gcp":
        _items += [
            apiextensionsv1alpha1.Usage{
                metadata: _metadata("usageXGkeByXFlux")
                spec: {
                    of: {
                        apiVersion: "gcp.platform.upbound.io/v1alpha1"
                        kind: "XGKE"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                    by: {
                        apiVersion: "gitops.platform.upbound.io/v1alpha1"
                        kind: "XFlux"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                }
            }
        ]

# ArgoCD GitOps (created after cluster is ready, or if it already exists)
if gitopsOperator == "argocd" and (_isReady(_clusterResourceName) or _argoExists):
    _items += [
        gitopsv1alpha1.XArgo{
            metadata: _metadata("XArgo")
            spec: {
                parameters: {
                    deletionPolicy: deletionPolicy
                    providerConfigName: id
                    operators: {
                        argocd: {
                            version: argocdVersion
                        }
                    }
                    source: {
                        git: {
                            url: gitopsGit.url
                            **({path: gitopsGit.path} if gitopsGit?.path else {})
                            **({ref: gitopsGit.ref} if gitopsGit?.ref else {})
                        }
                    }
                    **({ingressUrl: gitopsIngressUrl} if gitopsIngressUrl else {})
                    **({oidcConfig: gitopsOidcConfig} if gitopsOidcConfig else {})
                }
            }
        }
    ]

    # Usage resources for ArgoCD
    if cloud == "aws":
        _items += [
            apiextensionsv1alpha1.Usage{
                metadata: _metadata("usageXEksByXArgo")
                spec: {
                    of: {
                        apiVersion: "aws.platform.upbound.io/v1alpha1"
                        kind: "XEKS"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                    by: {
                        apiVersion: "gitops.platform.upbound.io/v1alpha1"
                        kind: "XArgo"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                }
            }
        ]
    elif cloud == "azure":
        _items += [
            apiextensionsv1alpha1.Usage{
                metadata: _metadata("usageXAksByXArgo")
                spec: {
                    of: {
                        apiVersion: "azure.platform.upbound.io/v1alpha1"
                        kind: "XAKS"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                    by: {
                        apiVersion: "gitops.platform.upbound.io/v1alpha1"
                        kind: "XArgo"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                }
            }
        ]
    elif cloud == "gcp":
        _items += [
            apiextensionsv1alpha1.Usage{
                metadata: _metadata("usageXGkeByXArgo")
                spec: {
                    of: {
                        apiVersion: "gcp.platform.upbound.io/v1alpha1"
                        kind: "XGKE"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                    by: {
                        apiVersion: "gitops.platform.upbound.io/v1alpha1"
                        kind: "XArgo"
                        resourceSelector: {
                            matchControllerRef: True
                        }
                    }
                }
            }
        ]

# Connection details for kubeconfig
_items += [{
    apiVersion: "meta.krm.kcl.dev/v1alpha1"
    kind: "CompositeConnectionDetails"
    data: {
        kubeconfig: _ocds?.XEKS?.ConnectionDetails?.kubeconfig or _ocds?.XAKS?.ConnectionDetails?.kubeconfig or _ocds?.XGKE?.ConnectionDetails?.kubeconfig
    }
}]

items = _items
