import models.io.upbound.aws.v1beta1 as awsv1beta1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1


_items = [
    metav1alpha1.E2ETest{
        metadata.name: "e2etest-xcluster-aws"
        spec= {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                caasv1alpha1.XCluster{
                    metadata = {
                        name = "configuration-caas-aws"
                    }
                    spec = {
                        parameters = {
                            cloud = "aws"
                            id = "configuration-caas-aws"
                            region = "us-west-2"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            iam = {
                                roleArn = "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                            }
                            nodes = {
                                count = 1
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
                            name = "configuration-caas-aws-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
            ]
            extraResources: [
                awsv1beta1.ProviderConfig{
                    metadata.name = "default"
                    spec = {
                        credentials = {
                            source = "Upbound"
                            upbound = {
                                webIdentity = {
                                    roleARN = "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                                }
                            }
                        }
                    }
                }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items= _items
