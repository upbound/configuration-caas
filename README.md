# Cluster-as-a-Service base configuration

This repo provides a configuration for a Cluster-as-a-Service, built on top of
Crossplane. This configuration exposes a simple API to your internal developers
for creating Kubernetes clusters. In the background, this configuration can create clusters in AWS, Azure, and GCP. It automatically applies common recommended practices, such as connecting the cluster to existing Flux deployments, automating VPC setup, and creating a Flux operator in a cluster.

This repo is a starting point for you to deliver your own
Cluster-as-a-Service. Fork this repository and customize the configuration to
meet your teams' needs.

To deploy a multicloud CaaS control plane in your organization, check out the
[Multicloud Quickstart](https://docs.upbound.io/quickstart/multicloud-deploy/).

Advantages of CaaS:

- GitOps workflow
- Production-ready template
- Scalable architecture
- Product agnostic approach

## Available APIs

This repository uses Compositions for AWS, Azure, and GCP provider APIs, as well as the Upbound Control Plane provider. For more information, review the provider Configurations below:

- [`Cluster.aws.caas.upbound.io`](https://marketplace.upbound.io/configurations/upbound/configuration-caas/v0.1.0/resources/aws.caas.upbound.io/XCluster/v1alpha1) 
    - Provision/Manage an EKS Cluster

- [`Cluster.azure.caas.upbound.io`](https://marketplace.upbound.io/configurations/upbound/configuration-caas/v0.1.0/resources/azure.caas.upbound.io/XCluster/v1alpha1) 

    - Provision/Manage an AKS Cluster
    
- [`Cluster.gcp.caas.upbound.io`](https://marketplace.upbound.io/configurations/upbound/configuration-caas/v0.1.0/resources/gcp.caas.upbound.io/XCluster/v1alpha1) 
    - Provision/Manage a GKE Cluster

- [`ControlPlane.mcp.caas.upbound.io`](https://marketplace.upbound.io/configurations/upbound/configuration-caas/v0.1.0/resources/mcp.caas.upbound.io/XControlPlane/v1alpha1)  
    - Provision/Manage an Upbound Control Plane

- [`Connector.mcp.caas.upbound.io`](https://marketplace.upbound.io/configurations/upbound/configuration-caas/v0.1.0/resources/mcp.caas.upbound.io/XCluster/v1alpha1)
    - Provision/Manage an MCP Connector

Each API in the [`apis`](https://github.com/upbound/configuration-caas/tree/main/apis) folder contains compositions and definitions for each cloud provider. Once you clone the CaaS repository, you can modify these compositions to fit your organizations needs. 
    
## Deployment

To deploy CaaS in a new organization, follow the [Get Started guide](https://docs.upbound.io/quickstart/multicloud-deploy/).

For deployments to an existing organization, log in to your Upbound organization
and go to **Configurations** and click **Create Configuration**.

Connect your Upbound organization to GitHub. Select the Github organization and
repository name for your cloned repo and choose the **Cluster as a
Service** configuration.

When your new configuration is ready, create a new control plane based on the
cloned repo you just created.

After a few minutes, your new control plane is ready!

To authenticate and configure your providers, see the [multicloud deployment
guide](https://docs.upbound.io/quickstart/multicloud-deploy/#configure-provider-upbound).

Once authenticated and configured, your self-service Upbound console lists
available cloud resources.

## GitOps integration

CaaS deployments work best when managed in your infrastructure as code
lifecycle. 

For more information on how to integrate Argo CD and Flux in your Upbound
environment, check out the [GitOps with Control Planes doc](https://docs.upbound.io/quickstart/multicloud-deploy/#configure-provider-upbound).

The Upbound Marketplace hosts a [community-owned Argo CD provider](https://github.com/crossplane-contrib/provider-argocd) to manage and
create Argo CD resources with Crossplane.

## Contributing

If you encounter issues or want to request improvements, review the
[Contributing Guides](https://docs.crossplane.io/contribute/).
