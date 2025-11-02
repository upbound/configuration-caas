import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1


_items = [
    metav1alpha1.E2ETest{
        metadata.name = "e2etest-xcluster-azure"
        spec = {
            # Configure Crossplane for the test environment
            crossplane = {
                autoUpgrade.channel = "Rapid"
                version = "1.18.3-up.1"
            }

            # Define the conditions that indicate successful resource creation
            defaultConditions = [
                "Ready"
            ]

            # Define the resources to be created
            manifests = [
                caasv1alpha1.XCluster{
                    metadata = {
                        name = "configuration-caas-azure"
                    }
                    spec = {
                        parameters = {
                            cloud = "azure"
                            id = "configuration-caas-azure"
                            region = "westus"
                            version = "1.31"
                            deletionPolicy = "Delete"
                            providerConfigName = "default"
                            nodes = {
                                count = 1
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
                            name = "configuration-caas-azure-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
            ]

            # Define the provider configuration
            extraResources = [
                azurev1beta1.ProviderConfig{
                    metadata.name = "default"
                    spec = {
                        credentials = {
                            source = "Upbound"
                        }
                        clientID = "bcf40abd-283c-494b-b186-03d6c864be51"
                        tenantID = "b9925bc4-8383-4c37-b9d2-fa456d1bb1c7"
                        subscriptionID = "038f2b7c-3265-43b8-8624-c9ad5da610a8"
                    }
                }
            ]

            # Test cleanup settings
            skipDelete = False

            # Set a reasonable timeout for resources to be provisioned
            timeoutSeconds = 3600
        }
    }
]
items = _items