
import models.io.crossplane.apiextensions.v1 as apiextensionsv1
import models.io.crossplane.apiextensions.v1alpha1 as apiextensionsv1alpha1
import models.io.crossplane.helm.v1alpha1 as helmv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.crossplane.kubernetes.v1alpha1 as kubernetesv1alpha1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2
import models.io.crossplane.pkg.v1 as pkgv1
import models.io.crossplane.pkg.v1alpha1 as pkgv1alpha1
import models.io.crossplane.pkg.v1beta1 as pkgv1beta1
import models.io.k8s.api.admissionregistration.v1 as admissionregistrationv1
import models.io.k8s.api.admissionregistration.v1alpha1 as admissionregistrationv1alpha1
import models.io.k8s.api.admissionregistration.v1beta1 as admissionregistrationv1beta1
import models.io.k8s.api.apiserverinternal.v1alpha1 as apiserverinternalv1alpha1
import models.io.k8s.api.apps.v1 as appsv1
import models.io.k8s.api.authentication.v1 as authenticationv1
import models.io.k8s.api.authorization.v1 as authorizationv1
import models.io.k8s.api.autoscaling.v1 as autoscalingv1
import models.io.k8s.api.autoscaling.v2 as autoscalingv2
import models.io.k8s.api.batch.v1 as batchv1
import models.io.k8s.api.certificates.v1 as certificatesv1
import models.io.k8s.api.certificates.v1alpha1 as certificatesv1alpha1
import models.io.k8s.api.certificates.v1beta1 as certificatesv1beta1
import models.io.k8s.api.coordination.v1 as coordinationv1
import models.io.k8s.api.coordination.v1alpha2 as coordinationv1alpha2
import models.io.k8s.api.coordination.v1beta1 as coordinationv1beta1
import models.io.k8s.api.core.v1 as corev1
import models.io.k8s.api.discovery.v1 as discoveryv1
import models.io.k8s.api.events.v1 as eventsv1
import models.io.k8s.api.flowcontrol.v1 as flowcontrolv1
import models.io.k8s.api.networking.v1 as networkingv1
import models.io.k8s.api.networking.v1beta1 as networkingv1beta1
import models.io.k8s.api.node.v1 as nodev1
import models.io.k8s.api.policy.v1 as policyv1
import models.io.k8s.api.rbac.v1 as rbacv1
import models.io.k8s.api.resource.v1alpha3 as resourcev1alpha3
import models.io.k8s.api.resource.v1beta1 as resourcev1beta1
import models.io.k8s.api.resource.v1beta2 as resourcev1beta2
import models.io.k8s.api.scheduling.v1 as schedulingv1
import models.io.k8s.api.storage.v1 as storagev1
import models.io.k8s.api.storage.v1alpha1 as storagev1alpha1
import models.io.k8s.api.storage.v1beta1 as storagev1beta1
import models.io.k8s.api.storagemigration.v1alpha1 as storagemigrationv1alpha1
import models.io.k8s.apiextensions_apiserver.pkg.apis.apiextensions.v1 as apisapiextensionsv1
import models.io.k8s.apimachinery.pkg.api.resource as apiresource
import models.io.k8s.apimachinery.pkg.apis.meta.v1 as metav1
import models.io.k8s.apimachinery.pkg.runtime as pkgruntime
import models.io.k8s.apimachinery.pkg.util.intstr as utilintstr
import models.io.k8s.apimachinery.pkg.version as pkgversion
import models.io.k8s.kube_aggregator.pkg.apis.apiregistration.v1 as apiregistrationv1
import models.io.upbound.aws.ec2.v1beta1 as ec2v1beta1
import models.io.upbound.aws.ec2.v1beta2 as ec2v1beta2
import models.io.upbound.aws.eks.v1beta1 as eksv1beta1
import models.io.upbound.aws.eks.v1beta2 as eksv1beta2
import models.io.upbound.aws.iam.v1beta1 as iamv1beta1
import models.io.upbound.aws.v1alpha1 as awsv1alpha1
import models.io.upbound.aws.v1beta1 as awsv1beta1
import models.io.upbound.azure.containerservice.v1beta1 as containerservicev1beta1
import models.io.upbound.azure.containerservice.v1beta2 as containerservicev1beta2
import models.io.upbound.azure.network.v1beta1 as networkv1beta1
import models.io.upbound.azure.network.v1beta2 as networkv1beta2
import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.azurem.v1beta1 as azuremv1beta1
import models.io.upbound.caas.mcp.v1alpha1 as mcpv1alpha1
import models.io.upbound.caas.v1alpha1 as caasv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.dev.meta.v2alpha1 as metav2alpha1
import models.io.upbound.gcp.cloudplatform.v1beta1 as cloudplatformv1beta1
import models.io.upbound.gcp.cloudplatform.v1beta2 as cloudplatformv1beta2
import models.io.upbound.gcp.compute.v1beta1 as computev1beta1
import models.io.upbound.gcp.compute.v1beta2 as computev1beta2
import models.io.upbound.gcp.container.v1beta1 as containerv1beta1
import models.io.upbound.gcp.container.v1beta2 as containerv1beta2
import models.io.upbound.gcp.v1beta1 as gcpv1beta1
import models.io.upbound.gcpm.cloudplatform.v1beta1 as gcpmcloudplatformv1beta1
import models.io.upbound.gcpm.compute.v1beta1 as gcpmcomputev1beta1
import models.io.upbound.gcpm.container.v1beta1 as gcpmcontainerv1beta1
import models.io.upbound.gcpm.v1beta1 as gcpmv1beta1
import models.io.upbound.iam.v1alpha1 as iamv1alpha1
import models.io.upbound.iamm.v1alpha1 as iammv1alpha1
import models.io.upbound.m.v1alpha1 as mv1alpha1
import models.io.upbound.platform.aws.v1alpha1 as platformawsv1alpha1
import models.io.upbound.platform.azure.v1alpha1 as azurev1alpha1
import models.io.upbound.platform.gcp.v1alpha1 as gcpv1alpha1
import models.io.upbound.platform.gitops.v1alpha1 as gitopsv1alpha1
import models.io.upbound.platform.observe.v1alpha1 as observev1alpha1
import models.io.upbound.repository.v1alpha1 as repositoryv1alpha1
import models.io.upbound.repositorym.v1alpha1 as repositorymv1alpha1
import models.io.upbound.v1alpha1 as upboundv1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as apismetav1


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