import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.platform.azure.v1alpha1 as azurev1alpha1
import models.io.upbound.platform.observe.v1alpha1 as observev1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1
import models.io.crossplane.apiextensions.v1alpha1 as crossplaneapiextensionsv1alpha1

_items = [
    metav1alpha1.CompositionTest {
        metadata.name: "test-cluster-azure-argocd"
        spec = {
            assertResources: [
                caasv1alpha1.XCluster{
                    metadata = {
                        name = "caas-azure-argocd"
                    }
                    spec = {
                        parameters = {
                            cloud = "azure"
                            id = "caas-azure-argocd"
                            region = "eastus"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            nodes = {
                                count = 3
                                instanceType = "Standard_B2s"
                            }
                            gitops = {
                                operator = "argocd"
                                git = {
                                    url = "https://github.com/upbound/configuration-caas.git"
                                    path = "configuration/infrastructure.yaml"
                                    ref = {
                                        name = "refs/heads/main"
                                    }
                                }
                                ingressUrl = "https://argocd.example.com"
                            }
                            operators = {
                                prometheus = {
                                    version = "67.4.0"
                                }
                                argocd = {
                                    version = "7.7.7"
                                }
                            }
                        }
                        writeConnectionSecretToRef = {
                            name = "caas-azure-argocd-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
                azurev1alpha1.XNetwork{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-azure-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XNetworkAZURE"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-azure-argocd"
                            region = "eastus"
                            addressRange = "10.1.0.0/16"
                            generalSubnetRange = "10.1.1.0/24"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                        }
                    }
                }
                azurev1alpha1.XAKS{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-azure-argocd"
                            "xaks.azure.platform.upbound.io/cluster-id" = "caas-azure-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XAKS"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-azure-argocd"
                            region = "eastus"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            version = "1.31"
                            nodes = {
                                count = 3
                                instanceType = "Standard_B2s"
                            }
                        }
                        writeConnectionSecretToRef = {
                            name = "caas-azure-argocd-aks"
                            namespace = "upbound-system"
                        }
                    }
                }
                crossplaneapiextensionsv1alpha1.Usage{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-azure-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "usageXAksByXOss"
                        }
                    }
                    spec = {
                        of = {
                            apiVersion = "azure.platform.upbound.io/v1alpha1"
                            kind = "XAKS"
                            resourceSelector = {
                                matchControllerRef = True
                            }
                        }
                        by = {
                            apiVersion = "observe.platform.upbound.io/v1alpha1"
                            kind = "XOss"
                            resourceSelector = {
                                matchControllerRef = True
                            }
                        }
                    }
                }
                observev1alpha1.XOss{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-azure-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XOss"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            id = "caas-azure-argocd"
                            operators = {
                                prometheus = {
                                    version = "67.4.0"
                                }
                            }
                        }
                    }
                }
                gitopsv1alpha1.XArgo{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-azure-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XArgo"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            ingressUrl = "https://argocd.example.com"
                            providerConfigName = "caas-azure-argocd"
                            operators = {
                                argocd = {
                                    version = "7.7.7"
                                }
                            }
                            source = {
                                git = {
                                    url = "https://github.com/upbound/configuration-caas.git"
                                    path = "configuration/infrastructure.yaml"
                                    ref = {
                                        name = "refs/heads/main"
                                    }
                                }
                            }
                        }
                    }
                }
                crossplaneapiextensionsv1alpha1.Usage{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-azure-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "usageXAksByXArgo"
                        }
                    }
                    spec = {
                        of = {
                            apiVersion = "azure.platform.upbound.io/v1alpha1"
                            kind = "XAKS"
                            resourceSelector = {
                                matchControllerRef = True
                            }
                        }
                        by = {
                            apiVersion = "gitops.platform.upbound.io/v1alpha1"
                            kind = "XArgo"
                            resourceSelector = {
                                matchControllerRef = True
                            }
                        }
                    }
                }
            ]
            observedResources: [
                azurev1alpha1.XAKS{
                    metadata.annotations = {
                        "crossplane.io/composition-resource-name": "XAKS"
                    }
                    spec = {
                        parameters = {
                            id = "caas-azure-argocd"
                            region = "eastus"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            nodes = {
                                count = 3
                                instanceType = "Standard_B2s"
                            }
                        }
                    }
                    status = {
                        conditions = [
                            {
                                type: "Ready"
                                status: "True"
                                reason: "Available"
                                lastTransitionTime: "2024-01-01T00:00:00Z"
                            }
                        ]
                    }
                }
            ]
            compositionPath: "apis/composition.yaml"
            xrPath: "examples/argocd/azure-cluster-xr.yaml"
            xrdPath: "apis/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items = _items
