import models.io.crossplane.helm.v1beta1 as helmv1beta1

oxr = option("params").oxr
_ocds = option("params").ocds

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

# Extract parameters from XR
providerConfigName = oxr.spec.parameters.providerConfigName
deletionPolicy = oxr.spec.parameters.deletionPolicy
version = oxr.spec.parameters.version
organizationName = oxr.spec.parameters.organizationName
controlPlaneName = oxr.spec.parameters.controlPlaneName
# Use XR name for namespace
clusterName = oxr.metadata.name

# Computed values
chartUrl = "https://charts.upbound.io/beta/mcp-connector-{}.tgz".format(version)
imageTag = "v{}".format(version)
connectionSecretName = "{}-connection-details".format(controlPlaneName)

_items = [
    helmv1beta1.Release{
        metadata: _metadata("mcp-connector") | {
            labels: oxr.metadata?.labels
            annotations: oxr.metadata?.annotations
        }
        spec: {
            deletionPolicy: deletionPolicy
            providerConfigRef: {
                name: providerConfigName
            }
            forProvider: {
                namespace: "kube-system"
                chart: {
                    name: "mcp-connector"
                    version: version
                    url: chartUrl
                }
                set: [{
                    name: "mcp.token"
                    valueFrom: {
                        secretKeyRef: {
                            key: "token"
                            namespace: "upbound-system"
                            name: connectionSecretName
                            optional: False
                        }
                    }
                }]
                values: {
                    mcp: {
                        host: "https://proxy.upbound.io"
                        account: organizationName
                        name: controlPlaneName
                        namespace: clusterName
                    }
                    image: {
                        tag: imageTag
                    }
                }
            }
        }
    }
]

items = _items
