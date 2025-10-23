import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.caas.mcp.v1alpha1 as mcpv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1

_items = [
    metav1alpha1.CompositionTest {
        metadata.name: "test-mcp-connector"
        spec = {
            assertResources: [
                mcpv1alpha1.XConnector{
                    metadata = {
                        name = "caas-aws-flux"
                    }
                    spec = {
                        parameters = {
                            organizationName = "upbound"
                            controlPlaneName = "caas"
                            version = "0.3.5"
                            providerConfigName = "caas-aws-flux"
                            deletionPolicy = "Delete"
                        }
                    }
                }
                helmv1beta1.Release{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas-aws-flux"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "mcp-connector"
                        }
                    }
                    spec = {
                        deletionPolicy = "Delete"
                        providerConfigRef = {
                            name = "caas-aws-flux"
                        }
                        forProvider = {
                            namespace = "kube-system"
                            chart = {
                                name = "mcp-connector"
                                version = "0.3.5"
                                url = "https://charts.upbound.io/beta/mcp-connector-0.3.5.tgz"
                            }
                            set = [{
                                name = "mcp.token"
                                valueFrom = {
                                    secretKeyRef = {
                                        key = "token"
                                        namespace = "upbound-system"
                                        name = "caas-connection-details"
                                        optional = False
                                    }
                                }
                            }]
                            values = {
                                mcp = {
                                    host = "https://proxy.upbound.io"
                                    account = "upbound"
                                    name = "caas"
                                    namespace = "caas-aws-flux"
                                }
                                image = {
                                    tag = "v0.3.5"
                                }
                            }
                        }
                    }
                }
            ]
            compositionPath: "apis/upbound/mcp-connector/composition.yaml"
            xrPath: "examples/upbound-mcp-connector-xr.yaml"
            xrdPath: "apis/upbound/mcp-connector/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items = _items