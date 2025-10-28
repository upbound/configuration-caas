import file
import models.io.upbound.aws.v1beta1 as awsv1beta1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.caas.mcp.v1alpha1 as mcpv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1


_items = [
    metav1alpha1.E2ETest{
        metadata.name: "e2etest-xconnector"
        spec= {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                # Create XControlPlane (MCP) first
                mcpv1alpha1.XControlPlane{
                    metadata = {
                        name = "configuration-caas-mcp"
                    }
                    spec = {
                        parameters = {
                            organizationName = "solutions"
                            spaceHost = "upbound-gcp-us-central-1.space.mxe.upbound.io"
                            groupName = "testing"
                            configuration = "configuration-caas"
                            robotPermission = "owner"
                        }
                        writeConnectionSecretToRef = {
                            name = "configuration-caas-mcp-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
                # Create XCluster (AWS EKS)
                caasv1alpha1.XCluster{
                    metadata = {
                        name = "configuration-caas-connector-aws"
                    }
                    spec = {
                        parameters = {
                            cloud = "aws"
                            id = "configuration-caas-connector-aws"
                            region = "us-west-2"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            iam = {
                                roleArn = "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
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
                            name = "configuration-caas-connector-aws-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
                # Create XConnector to connect the cluster to the MCP
                mcpv1alpha1.XConnector{
                    metadata = {
                        name = "configuration-caas-connector"
                    }
                    spec = {
                        parameters = {
                            organizationName = "solutions"
                            controlPlaneName = "configuration-caas-mcp"
                            version = "0.3.5"
                            providerConfigName = "configuration-caas-connector-aws"
                            deletionPolicy = "Delete"
                            tokenSecretRef = {
                                name = "configuration-caas-mcp-kubeconfig"
                                namespace = "upbound-system"
                            }
                        }
                    }
                }
            ]
            extraResources: [
                # AWS ProviderConfig
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
                # Bootstrap provider-kubernetes ProviderConfig
                {
                    apiVersion = "kubernetes.crossplane.io/v1alpha1"
                    kind = "ProviderConfig"
                    metadata = {
                        name = "default"
                    }
                    spec = {
                        credentials = {
                            source = "InjectedIdentity"
                        }
                    }
                }
                # Upbound token secret for MCP creation
                {
                    apiVersion = "v1"
                    kind = "Secret"
                    metadata = {
                        name = "upbound-token"
                        namespace = "upbound-system"
                    }
                    stringData.token = file.read_env("UP_E2E_API_TOKEN")
                }
            ]
            skipDelete: False
            timeoutSeconds: 5400
        }
    }
]
items= _items
