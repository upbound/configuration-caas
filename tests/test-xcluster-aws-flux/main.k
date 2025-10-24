import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1
import models.io.upbound.platform.observe.v1alpha1 as observev1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1
import models.io.crossplane.apiextensions.v1alpha1 as crossplaneapiextensionsv1alpha1

_items = [
    metav1alpha1.CompositionTest {
        metadata.name: "test-cluster-aws-flux"
        spec = {
            assertResources: [
                caasv1alpha1.XCluster{
                    metadata = {
                        name = "caas-aws-flux"
                    }
                    spec = {
                        parameters = {
                            cloud = "aws"
                            id = "caas-aws-flux"
                            region = "us-west-2"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            iam = {
                                roleArn = "arn:aws:iam::123456789:role/AWSReservedSSO_AdministratorAccess_test"
                            }
                            nodes = {
                                count = 3
                                instanceType = "t3.small"
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
                            name = "caas-aws-flux-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
                platformawsv1alpha1.XNetwork{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-aws-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XNetworkAWS"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-aws-flux"
                            region = "us-west-2"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                        }
                    }
                }
                platformawsv1alpha1.XEKS{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-aws-flux"
                            "xeks.aws.platform.upbound.io/cluster-id" = "caas-aws-flux"
                        }
                        annotations = {
                            "crossplane.io/external-name" = "caas-aws-flux"
                            "crossplane.io/composition-resource-name" = "XEKS"
                        }
                    }
                    spec = {
                        parameters = {
                            id = "caas-aws-flux"
                            region = "us-west-2"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            version = "1.31"
                            accessConfig = {
                                authenticationMode = "API_AND_CONFIG_MAP"
                                bootstrapClusterCreatorAdminPermissions = True
                            }
                            nodes = {
                                count = 3
                                instanceType = "t3.small"
                            }
                            iam = {
                                principalArn = "arn:aws:iam::123456789:role/AWSReservedSSO_AdministratorAccess_test"
                            }
                        }
                        writeConnectionSecretToRef = {
                            name = "caas-aws-flux-eks"
                            namespace = "upbound-system"
                        }
                    }
                }
                crossplaneapiextensionsv1alpha1.Usage{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-aws-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "usageXEksByXOss"
                        }
                    }
                    spec = {
                        of = {
                            apiVersion = "aws.platform.upbound.io/v1alpha1"
                            kind = "XEKS"
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
                            "crossplane.io/composite" = "caas-aws-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XOss"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            id = "caas-aws-flux"
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
                            "crossplane.io/composite" = "caas-aws-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "XFlux"
                        }
                    }
                    spec = {
                        parameters = {
                            deletionPolicy = "Delete"
                            providerConfigName = "caas-aws-flux"
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
                            "crossplane.io/composite" = "caas-aws-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "usageXEksByXFlux"
                        }
                    }
                    spec = {
                        of = {
                            apiVersion = "aws.platform.upbound.io/v1alpha1"
                            kind = "XEKS"
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
                platformawsv1alpha1.XEKS{
                    metadata.annotations = {
                        "crossplane.io/composition-resource-name": "XEKS"
                    }
                    spec = {
                        parameters = {
                            id = "caas-aws-flux"
                            region = "us-west-2"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            accessConfig = {
                                authenticationMode = "API_AND_CONFIG_MAP"
                                bootstrapClusterCreatorAdminPermissions = True
                            }
                            nodes = {
                                count = 3
                                instanceType = "t3.small"
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
            xrPath: "examples/flux/aws-cluster-xr.yaml"
            xrdPath: "apis/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items = _items