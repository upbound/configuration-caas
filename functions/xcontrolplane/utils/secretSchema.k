schema ObserveSecret:
    r"""
    ObserveSecret represents an Input for an Observe Secret.

    Attributes
    ----------
    name : str, required
        The metadata.name of the observed secret.
    namespace : str, required
        The metadata.namespace of the observed secret.
    ctp : str, required
        The control plane name for control plane-level access
    resourceName : str, required
        The crossplane.io/composition-resource-name for the observed secret.
    providerConfigName : str, required
        The Name of the provider config to reference
    """

    name: str
    namespace: str
    ctp: str
    resourceName: str
    providerConfigName: str

