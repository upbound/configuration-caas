import models.io.upbound.caas.mcp.v1alpha1 as caasmcpv1alpha1
import models.io.upbound.iam.v1alpha1 as iamv1alpha1
import models.io.upbound.v1alpha1 as upboundv1alpha1
import models.io.crossplane.kubernetes.v1alpha2 as kubernetesv1alpha2

oxr = option("params").oxr
_ocds = option("params").ocds

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

# Extract parameters from XR
controlPlaneName = oxr.metadata.name
organizationName = oxr.spec.parameters.organizationName
configuration = oxr.spec.parameters.configuration
robotPermission = oxr.spec.parameters.robotPermission
upboundTokenSecretName = oxr.spec?.parameters?.upboundTokenSecretName or "upbound-token"
upboundTokenSecretNamespace = oxr.spec?.parameters?.upboundTokenSecretNamespace or "upbound-system"
upboundTokenSecretKey = oxr.spec?.parameters?.upboundTokenSecretKey or "token"

# Computed names
robotName = "{}-robot".format(controlPlaneName)
teamName = "{}-team".format(controlPlaneName)
tokenSecretName = "{}-robot-token".format(controlPlaneName)
providerConfigName = "{}-upbound".format(controlPlaneName)

# Get status values from observed composed resources
teamExternalName = _ocds?["mcp-team"]?.Resource?.metadata?.annotations?["crossplane.io/external-name"]
tokenSecret = _ocds?["mcp-robot-token"]?.Resource?.spec?.writeConnectionSecretToRef?.name
tokenAccessID = _ocds?["mcp-robot-token"]?.Resource?.metadata?.annotations?["crossplane.io/external-name"]
connectionSecretName = "{}-connection-details".format(controlPlaneName)

_items = [
    # ProviderConfig for provider-upbound using the supplied token
    upboundv1alpha1.ProviderConfig{
        metadata: _metadata("providerConfigUpbound") | {
            annotations: {
                "krm.kcl.dev/ready": "True"
            }
            name: providerConfigName
        }
        spec: {
            credentials: {
                secretRef: {
                    name: upboundTokenSecretName
                    namespace: upboundTokenSecretNamespace
                    key: upboundTokenSecretKey
                }
                source: "Secret"
            }
            organization: organizationName
        }
    }
    # ControlPlane XR (the actual MCP)
    caasmcpv1alpha1.ControlPlane{
        metadata: _metadata("controlplane") | {
            annotations: {
                "crossplane.io/external-name": controlPlaneName
            }
        }
        spec: {
            parameters: {
                organizationName: organizationName
                configuration: configuration
                robotPermission: robotPermission
            }
        }
    }
    # Robot for the control plane
    iamv1alpha1.Robot{
        metadata: _metadata("mcp-robot") | {
            name: robotName
        }
        spec: {
            forProvider: {
                name: robotName
                owner: {
                    name: organizationName
                }
                description: "Robot for {}".format(controlPlaneName)
            }
            providerConfigRef: {
                name: providerConfigName
            }
        }
    }
    # Robot Token
    iamv1alpha1.Token{
        metadata: _metadata("mcp-robot-token") | {
            name: tokenSecretName
        }
        spec: {
            forProvider: {
                name: controlPlaneName
                owner: {
                    idRef: {
                        name: robotName
                    }
                    type: "robots"
                }
            }
            providerConfigRef: {
                name: providerConfigName
            }
            writeConnectionSecretToRef: {
                name: tokenSecretName
                namespace: "upbound-system"
            }
        }
    }
    # Team
    iamv1alpha1.Team{
        metadata: _metadata("mcp-team") | {
            name: teamName
        }
        spec: {
            deletionPolicy: "Orphan"
            forProvider: {
                organizationName: organizationName
                name: teamName
            }
            providerConfigRef: {
                name: providerConfigName
            }
        }
    }
    # Robot team membership
    iamv1alpha1.RobotTeamMembership{
        metadata: _metadata("mcp-team-membership") | {
            name: "{}-membership".format(robotName)
        }
        spec: {
            forProvider: {
                robotIdRef: {
                    name: robotName
                }
                teamIdRef: {
                    name: teamName
                }
            }
            providerConfigRef: {
                name: providerConfigName
            }
        }
    }
    # ObjectRoleBinding for admin access to the control plane namespace
    kubernetesv1alpha2.Object{
        metadata: _metadata("team-admin-binding") | {
            name: "{}-admin-binding".format(controlPlaneName)
        }
        spec: {
            forProvider: {
                manifest: {
                    apiVersion: "authorization.spaces.upbound.io/v1alpha1"
                    kind: "ObjectRoleBinding"
                    metadata: {
                        name: "{}-admin-binding".format(controlPlaneName)
                        namespace: controlPlaneName
                    }
                    spec: {
                        object: {
                            apiGroup: "core"
                            resource: "namespaces"
                            name: controlPlaneName
                        }
                        subjects: [
                            {
                                kind: "UpboundTeam"
                                role: robotPermission
                                **({name: teamExternalName} if teamExternalName else {})
                            }
                        ]
                    }
                }
            }
            providerConfigRef: {
                name: controlPlaneName
            }
        }
    }
]

# Status updates - add to desired composite resource status
_dxr = {
    **option("params").dxr
    **{
        status: {
            mcp: {
                **({tokenSecret: tokenSecret} if tokenSecret else {})
                **({tokenAccessID: tokenAccessID} if tokenAccessID else {})
                connectionSecretName: connectionSecretName
            }
        }
    }
}

# Connection details for kubeconfig come from the ControlPlane XR
_items += [{
    apiVersion: "meta.krm.kcl.dev/v1alpha1"
    kind: "CompositeConnectionDetails"
    data: {
        kubeconfig: _ocds?.controlplane?.ConnectionDetails?.kubeconfig
    }
}]

items = _items
dxr = _dxr
