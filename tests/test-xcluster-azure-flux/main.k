import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.platform.azure.v1alpha1 as azurev1alpha1
import models.io.upbound.platform.observe.v1alpha1 as observev1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1
import models.io.crossplane.apiextensions.v1alpha1 as crossplaneapiextensionsv1alpha1

_items = [
    metav1alpha1.CompositionTest {
        metadata.name: "test-cluster-azure-flux"
        spec = {
            assertResources: [
                caasv1alpha1.XCluster{
                    metadata = {
                        name = "caas-azure-flux"
                    }
                    spec = {
                        parameters = {
                            cloud = "azure"
                            id = "caas-azure-flux"
                            region = "eastus"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            nodes = {
                                count = 3
                                instanceType = "Standard_B2s"
                            }
                            gitops = {
                                operator = "flux"
                                git = {
                                    url = "https://github.com/upbound/configuration-caas/"
                                    ref = {
                                        name = "refs/heads/main"
                                    }
                                }
                            }
                            operators = {
                                prometheus = {
                                    version = "67.4.0"
                                }
                                flux = {
                                    version = "2.16.4"
                                }
                                fluxSync = {
                                    version = "1.13.4"
                                }
                            }
                        }
                        writeConnectionSecretToRef = {
                            name = "caas-azure-flux-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
                azurev1alpha1.XNetwork{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-azure-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XNetworkAZURE"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-azure-flux"
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
                            "crossplane.io/composite" = "caas-azure-flux"
                            "xaks.azure.platform.upbound.io/cluster-id" = "caas-azure-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XAKS"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-azure-flux"
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
                            name = "caas-azure-flux-aks"
                            namespace = "upbound-system"
                        }
                    }
                }
                crossplaneapiextensionsv1alpha1.Usage{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-azure-flux"
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
                            "crossplane.io/composite" = "caas-azure-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XOss"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            id = "caas-azure-flux"
                            operators = {
                                prometheus = {
                                    version = "67.4.0"
                                }
                            }
                        }
                    }
                }
                gitopsv1alpha1.XFlux{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-azure-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XFlux"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            providerConfigName = "caas-azure-flux"
                            operators = {
                                flux = {
                                    version = "2.16.4"
                                }
                                fluxSync = {
                                    version = "1.13.4"
                                }
                            }
                            source = {
                                git = {
                                    url = "https://github.com/upbound/configuration-caas/"
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
                            "crossplane.io/composite" = "caas-azure-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "usageXAksByXFlux"
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
                            kind = "XFlux"
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
                            id = "caas-azure-flux"
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
            xrPath: "examples/flux/azure-cluster-xr.yaml"
            xrdPath: "apis/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items = _items
