import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.caas.mcp.v1alpha1 as caasmcpv1alpha1
import models.io.upbound.iam.v1alpha1 as iamv1alpha1
import models.io.upbound.v1alpha1 as upboundv1alpha1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2

_items = [
    metav1alpha1.CompositionTest {
        metadata.name: "test-control-plane"
        spec = {
            assertResources: [
                caasmcpv1alpha1.XControlPlane{
                    metadata = {
                        name = "caas"
                    }
                    spec = {
                        parameters = {
                            organizationName = "upbound"
                            configuration = "caas-test"
                            robotPermission = "owner"
                        }
                        writeConnectionSecretToRef = {
                            name = "caas-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
                upboundv1alpha1.ProviderConfig{
                    metadata = {
                        name = "caas-upbound"
                        labels = {
                            "crossplane.io/composite" = "caas"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "providerConfigUpbound"
                        }
                    }
                    spec = {
                        credentials = {
                            secretRef = {
                                name = "upbound-token"
                                namespace = "upbound-system"
                                key = "token"
                            }
                            source = "Secret"
                        }
                        organization = "upbound"
                    }
                }
                caasmcpv1alpha1.ControlPlane{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas"
                        }
                        annotations = {
                            "crossplane.io/external-name" = "caas"
                            "crossplane.io/composition-resource-name" = "controlplane"
                        }
                    }
                    spec = {
                        parameters = {
                            organizationName = "upbound"
                            configuration = "caas-test"
                            robotPermission = "owner"
                        }
                    }
                }
                iamv1alpha1.Robot{
                    metadata = {
                        name = "caas-robot"
                        labels = {
                            "crossplane.io/composite" = "caas"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "mcp-robot"
                        }
                    }
                    spec = {
                        forProvider = {
                            name = "caas-robot"
                            owner = {
                                name = "upbound"
                            }
                            description = "Robot for caas"
                        }
                        providerConfigRef = {
                            name = "caas-upbound"
                        }
                    }
                }
                iamv1alpha1.Token{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "mcp-robot-token"
                        }
                    }
                    spec = {
                        forProvider = {
                            name = "caas"
                            owner = {
                                idRef = {
                                    name = "caas-robot"
                                }
                                type = "robots"
                            }
                        }
                        providerConfigRef = {
                            name = "caas-upbound"
                        }
                        writeConnectionSecretToRef = {
                            name = "caas-robot-token"
                            namespace = "upbound-system"
                        }
                    }
                }
                iamv1alpha1.Team{
                    metadata = {
                        labels = {
                            "crossplane.io/composite" = "caas"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "mcp-team"
                        }
                    }
                    spec = {
                        deletionPolicy = "Orphan"
                        forProvider = {
                            organizationName = "upbound"
                            name = "caas-team"
                        }
                        providerConfigRef = {
                            name = "caas-upbound"
                        }
                    }
                }
                iamv1alpha1.RobotTeamMembership{
                    metadata = {
                        name = "caas-robot-membership"
                        labels = {
                            "crossplane.io/composite" = "caas"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "mcp-team-membership"
                        }
                    }
                    spec = {
                        forProvider = {
                            robotIdRef = {
                                name = "caas-robot"
                            }
                            teamIdRef = {
                                name = "caas-team"
                            }
                        }
                        providerConfigRef = {
                            name = "caas-upbound"
                        }
                    }
                }
                kubernetesv1alpha2.Object{
                    metadata = {
                        name = "caas-admin-binding"
                        labels = {
                            "crossplane.io/composite" = "caas"
                        }
                        annotations = {
                            "crossplane.io/composition-resource-name" = "team-admin-binding"
                        }
                    }
                    spec = {
                        forProvider = {
                            manifest = {
                                apiVersion = "authorization.spaces.upbound.io/v1alpha1"
                                kind = "ObjectRoleBinding"
                                metadata = {
                                    name = "caas-admin-binding"
                                    namespace = "caas"
                                }
                                spec = {
                                    object = {
                                        apiGroup = "core"
                                        resource = "namespaces"
                                        name = "caas"
                                    }
                                    subjects = [
                                        {
                                            kind = "UpboundTeam"
                                            role = "owner"
                                        }
                                    ]
                                }
                            }
                        }
                        providerConfigRef = {
                            name = "caas"
                        }
                    }
                }
            ]
            compositionPath: "apis/upbound/controlplane/composition.yaml"
            xrPath: "examples/upbound-controlplane.yaml"
            xrdPath: "apis/upbound/controlplane/definition.yaml"
            timeoutSeconds: 60
            validate: False
            observedResources: [
                iamv1alpha1.Token{
                    metadata.annotations = {
                        "crossplane.io/composition-resource-name": "mcp-robot-token"
                    }
                    spec = {
                        forProvider = {
                            name: "caas"
                            owner = {
                                idRef = {
                                    name: "caas-robot"
                                }
                                type: "robots"
                            }
                        }
                        writeConnectionSecretToRef = {
                            name: "caas-robot-token"
                            namespace: "upbound-system"
                        }
                    }
                    status = {
                        atProvider = {
                            id: "test-token-id-123"
                        }
                        conditions = [
                            {
                                type: "Ready"
                                status: "True"
                                lastTransitionTime: "2024-01-01T00:00:00Z"
                                reason: "Available"
                            }
                        ]
                    }
                }
                iamv1alpha1.Team{
                    metadata.annotations = {
                        "crossplane.io/composition-resource-name": "mcp-team"
                        "crossplane.io/external-name": "team-external-id-456"
                    }
                    spec = {
                        forProvider = {
                            organizationName: "upbound"
                            name: "caas-team"
                        }
                    }
                    status = {
                        atProvider = {
                            id: "team-id-456"
                        }
                        conditions = [
                            {
                                type: "Ready"
                                status: "True"
                                lastTransitionTime: "2024-01-01T00:00:00Z"
                                reason: "Available"
                            }
                        ]
                    }
                }
            ]
        }
    }
]
items = _items