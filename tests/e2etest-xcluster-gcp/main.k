import models.io.upbound.gcp.v1beta1 as gcpv1beta1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1


_items = [
    metav1alpha1.E2ETest{
        metadata.name: "e2etest-xcluster-gcp"
        spec= {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                caasv1alpha1.XCluster{
                    metadata = {
                        name = "configuration-caas-gcp"
                    }
                    spec = {
                        parameters = {
                            cloud = "gcp"
                            id = "configuration-caas-gcp"
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
                            name = "configuration-caas-gcp-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
            ]
            extraResources: [
                gcpv1beta1.ProviderConfig{
                    metadata.name = "default"
                    spec = {
                        projectID = "crossplane-playground"
                        credentials = {
                            source = "Upbound"
                            upbound = {
                                federation = {
                                    providerID = "projects/283222062215/locations/global/workloadIdentityPools/solutions-upbound-oidc-pool/providers/solutions-u5d-oidc-pool"
                                    serviceAccount = "solutions-u5d-service-account@crossplane-playground.iam.gserviceaccount.com"
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