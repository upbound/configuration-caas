import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2
import models.io.k8s.api.core.v1 as v1

observeSecret = lambda config: ObserveSecret -> any {
   """
   Observe a Secret.
   """
   [
        kubernetesv1alpha2.Object{
            metadata = _metadata(config.resourceName) | {
                name = "{}-{}-observed".format(config.ctp, config.resourceName)
            }
            spec = {
                forProvider = {
                    manifest = v1.Secret{
                        metadata = {
                            name = config.name
                            namespace = config.namespace
                        }
                    }
                }
                providerConfigRef = {
                    name = config.providerConfigName
                }
                managementPolicies = ["Observe"]
            }
        }
]}