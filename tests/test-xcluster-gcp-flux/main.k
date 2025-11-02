import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.platform.gcp.v1alpha1 as gcpv1alpha1
import models.io.upbound.platform.observe.v1alpha1 as observev1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1
import models.io.crossplane.apiextensions.v1alpha1 as crossplaneapiextensionsv1alpha1

_items = [
    metav1alpha1.CompositionTest {
        metadata.name: "test-cluster-gcp-flux"
        spec = {
            assertResources: [
                caasv1alpha1.XCluster{
                    metadata = {
                        name = "caas-gcp-flux"
                    }
                    spec = {
                        parameters = {
                            cloud = "gcp"
                            id = "caas-gcp-flux"
                            region = "us-central1"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            nodes = {
                                count = 3
                                instanceType = "n1-standard-1"
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
                            name = "caas-gcp-flux-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
                gcpv1alpha1.XNetwork{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-gcp-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XNetworkGCP"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-gcp-flux"
                            region = "us-central1"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                        }
                    }
                }
                gcpv1alpha1.XGKE{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-gcp-flux"
                            "xgke.gcp.platform.upbound.io/cluster-id" = "caas-gcp-flux"
                        }
                        annotations = {
                            "crossplane.io/external-name" = "caas-gcp-flux"
                            "crossplane.io/composition-resource-name" = "XGKE"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-gcp-flux"
                            region = "us-central1"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            version = "1.31"
                            nodes = {
                                count = 3
                                instanceType = "n1-standard-1"
                            }
                        }
                        writeConnectionSecretToRef = {
                            name = "caas-gcp-flux-gke"
                            namespace = "upbound-system"
                        }
                    }
                }
                crossplaneapiextensionsv1alpha1.Usage{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-gcp-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "usageXGkeByXOss"
                        }
                    }
                    spec = {
                        of = {
                            apiVersion = "gcp.platform.upbound.io/v1alpha1"
                            kind = "XGKE"
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
                            "crossplane.io/composite" = "caas-gcp-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XOss"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            id = "caas-gcp-flux"
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
                            "crossplane.io/composite" = "caas-gcp-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XFlux"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            providerConfigName = "caas-gcp-flux"
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
                            "crossplane.io/composite" = "caas-gcp-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "usageXGkeByXFlux"
                        }
                    }
                    spec = {
                        of = {
                            apiVersion = "gcp.platform.upbound.io/v1alpha1"
                            kind = "XGKE"
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
                gcpv1alpha1.XGKE{
                    metadata.annotations = {
                        "crossplane.io/composition-resource-name": "XGKE"
                    }
                    spec = {
                        parameters = {
                            id = "caas-gcp-flux"
                            region = "us-central1"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            nodes = {
                                count = 3
                                instanceType = "n1-standard-1"
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
            xrPath: "examples/flux/gcp-cluster-xr.yaml"
            xrdPath: "apis/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items = _items
