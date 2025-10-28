import file
import models.io.upbound.caas.mcp.v1alpha1 as mcpv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1


_items = [
    metav1alpha1.E2ETest{
        metadata.name: "e2etest-xcontrolplane"
        spec= {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
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
            ]
            extraResources: [
                # Bootstrap provider-kubernetes ProviderConfig
                # Created after configuration is installed so CRDs are available
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
            timeoutSeconds: 4500
        }
    }
]
items= _items