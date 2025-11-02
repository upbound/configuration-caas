import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.platform.gcp.v1alpha1 as gcpv1alpha1
import models.io.upbound.platform.observe.v1alpha1 as observev1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1
import models.io.crossplane.apiextensions.v1alpha1 as crossplaneapiextensionsv1alpha1

_items = [
    metav1alpha1.CompositionTest {
        metadata.name: "test-cluster-gcp-argocd"
        spec = {
            assertResources: [
                caasv1alpha1.XCluster{
                    metadata = {
                        name = "caas-gcp-argocd"
                    }
                    spec = {
                        parameters = {
                            cloud = "gcp"
                            id = "caas-gcp-argocd"
                            region = "us-central1"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            nodes = {
                                count = 3
                                instanceType = "n1-standard-1"
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
                            name = "caas-gcp-argocd-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
                gcpv1alpha1.XNetwork{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-gcp-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XNetworkGCP"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-gcp-argocd"
                            region = "us-central1"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                        }
                    }
                }
                gcpv1alpha1.XGKE{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-gcp-argocd"
                            "xgke.gcp.platform.upbound.io/cluster-id" = "caas-gcp-argocd"
                        }
                        annotations = {
                            "crossplane.io/external-name" = "caas-gcp-argocd"
                            "crossplane.io/composition-resource-name" = "XGKE"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-gcp-argocd"
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
                            name = "caas-gcp-argocd-gke"
                            namespace = "upbound-system"
                        }
                    }
                }
                crossplaneapiextensionsv1alpha1.Usage{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-gcp-argocd"
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
                            "crossplane.io/composite" = "caas-gcp-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XOss"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            id = "caas-gcp-argocd"
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
                            "crossplane.io/composite" = "caas-gcp-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XArgo"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            ingressUrl = "https://argocd.example.com"
                            providerConfigName = "caas-gcp-argocd"
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
                            "crossplane.io/composite" = "caas-gcp-argocd"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "usageXGkeByXArgo"
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
                            kind = "XArgo"
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
                            id = "caas-gcp-argocd"
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
            xrPath: "examples/argocd/gcp-cluster-xr.yaml"
            xrdPath: "apis/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items = _items
