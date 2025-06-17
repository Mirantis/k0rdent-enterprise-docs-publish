# Mirantis k0rdent Enterprise v1.0.0 Release Notes

Released: June 17, 2025

Mirantis k0rdent Enterprise is the enterprise-grade, commercially supported version of the k0rdent platform. It delivers a comprehensive, composable control plane for managing Kubernetes clusters, services, and observability across public clouds, private data centers, bare metal, and edge environments with enhanced security, support, and enterprise features.

## Component Breakdown

-   **KCM (k0rdent Cluster Management)**
    Manages provisioning, upgrade, scaling, and lifecycle of Kubernetes clusters via Cluster API with enhanced bare metal and airgapped support.
    
-   **KSM (k0rdent State Management)**
    Uses declarative, templated `ServiceTemplate` objects to manage consistent deployment of services like Istio, Flux, and cert-manager.
    
-   **KOF (k0rdent Observability & FinOps)**
    Provides comprehensive metrics, logs, dashboards, and cost visibility using VictoriaMetrics, OpenCost integration.

## Major Highlights

This initial release of Mirantis k0rdent Enterprise includes:

-   Fully stabilized v1beta1 APIs across components
-   Production-grade multi-cluster support
-   Bare metal deployment capabilities
-   Enterprise-ready service templating and orchestration
-   Integrated observability stack with AI/ML workload support
-   Airgapped installation and deployment capabilities
-   Commercial support and enterprise-grade security features

## Core Features

### Cluster Lifecycle Management (KCM)

-   **Multi-Cloud Cluster Provisioning**
    Declarative cluster creation and management across AWS, Azure, GCP, vSphere, OpenStack, and bare metal environments using Cluster API

-   **Cluster Templates**
    Reusable, parameterized templates for consistent cluster provisioning with customizable node pools, networking, and security configurations

-   **Automated Cluster Scaling**
    Dynamic horizontal and vertical scaling of worker nodes based on resource demands and policies

-   **Cluster Upgrades & Maintenance**
    Rolling updates of Kubernetes versions with automated health checks and rollback capabilities

-   **Bare Metal Cluster Deployment**
    Native support for provisioning and managing Kubernetes clusters on bare metal infrastructure with automated node discovery and configuration

-   **Airgapped Installation**
    Complete offline installation capabilities with pre-packaged container images and Helm charts for secure, disconnected environments

### Service Management (KSM)

-   **ServiceTemplates**
    Declarative templates for deploying and managing applications and platform services consistently across multiple clusters

-   **ServiceTemplateChains**
    Enables conditional, chained service deployments with upgrade paths for complex service topologies

-   **Multi-Cluster Service Orchestration**
    Coordinate service deployments across multiple clusters with dependency management and ordering

-   **GitOps Integration**
    Native integration with ArgoCD and FluxCD for continuous deployment workflows

-   **Provider Templates**
    Infrastructure provider configurations that can be reused across multiple cluster deployments

-   **Global Values Support**
    Reuse consistent variables across ClusterTemplates and ProviderTemplates ensuring DRY, repeatable infrastructure definitions

### Networking & Connectivity

-   **IPAM Controller Integration**
    Automates IP address management across environments, removing manual allocation and avoiding IP conflicts

-   **Multi-Cluster Networking**
    Service mesh integration with Istio for secure, observable communication between clusters

-   **Load Balancer Integration**
    Automated configuration of cloud and on-premises load balancers for cluster ingress

-   **Network Policy Management**
    Centralized network security policy enforcement across clusters

### Observability & Monitoring (KOF)

-   **NVIDIA GPU Monitoring**
    Native Grafana dashboards for AI/ML workloads providing visibility into GPU utilization without additional configuration

-   **Kube API Server Metrics**
    OpenTelemetry-based monitoring of API server health with immediate insights into control plane performance

-   **VictoriaMetrics Log Cluster**
    Scalable logging stack with high-retention support, improved storage efficiency and performance

-   **Cluster Annotation Support for Promxy/Datasource Config**
    Allows per-cluster HTTP configuration customization

-   **Custom Resource Limits for Observability Stack**
    Fine-tune Grafana and VictoriaMetrics components to optimize memory and CPU usage across environments

## Enterprise Solutions

Mirantis provides validated and fully-supported solutions for Mirantis k0rdent Enterprise, addressing a range of use cases. Mirantis k0rdent Enterprise v1.0.0 introduces three integrated solutions designed to work together:

- **Mirantis k0rdent Virtualization**

    A commercially supported virtualization platform based on KubeVirt that enable you to run virtual machines alongside containers in Kubernetes clusters. It provides VM lifecycle management, live migration, storage integration with Ceph, and enterprise-grade support for hybrid workloads.

- **Ceph Storage**

    Automated deployment and management of Ceph distributed storage clusters on k0rdent child clusters using `ServiceTemplate` objects. Ceph povides scalable, reliable storage that is ideal for the virtual machine workloads in Mirantis k0rdent Virtualization, with support for both block and object storage needs, enterprise-grade data protection, and performance optimization.

- **Mirantis StackLight LMA**

    Comprehensive monitoring solution originally designed for Kubernetes clusters running on bare metal or VMs, now distributed as a Kubernetes Operator and installed as a Helm chart. Provides enterprise-grade observability with prebuilt dashboards, advanced analytics, and intelligent alerting capabilities specifically optimized for Mirantis k0rdent Virtualization environments. Includes log aggregation, metric collection, distributed tracing, and anomaly detection.

## Component & Provider Versions

| Component / Provider          | Version          |
|-------------------------------|------------------|
| Cluster API                   | v1.9.7           |
| CAPI Provider AWS             | v2.8.2           |
| CAPI Provider Azure           | v1.19.4          |
| CAPI Provider Docker          | v1.9.6           |
| CAPI Provider GCP             | v1.8.1           |
| CAPI Provider Infoblox        | v0.1.0-alpha.8   |
| CAPI Provider IPAM            | v0.18.0          |
| CAPI Provider k0smotron       | v1.5.2           |
| CAPI Provider OpenStack (ORC) | v0.12.3 / v2.1.0 |
| CAPI Provider vSphere         | v1.13.0          |
| CAPI Provider Metal3          | v1.8.0           |
| Project Sveltos               | v0.54.0          |
| Mirantis k0rdent Virtualization | v1.0.0        |
| Ceph                          | v18.2.0          |
| Mirantis StackLight LMA       | v1.0.0           |

## Platform Benefits

- Declarative, template-driven provisioning of clusters and services across multiple infrastructure types
- Comprehensive observability built-in, including GPU, API metrics, and enterprise-grade monitoring
- GitOps-ready: compatible with ArgoCD, FluxCD, Velero, and other CNCF tools
- Unified Kubernetes-native APIs with long-term schema stability
- Enterprise support with SLA guarantees and professional services
- Enhanced security features for regulated environments
- Bare metal and airgapped deployment capabilities for edge and secure environments
- Integrated virtualization platform for hybrid container/VM workloads
- Enterprise-grade storage solutions with Ceph integration

## Installation Requirements

### Standard Installation
- Kubernetes 1.28+ management cluster
- Minimum 8GB RAM, 4 CPU cores
- 100GB storage for management cluster
- Network connectivity to target infrastructure providers

### Airgapped Installation
- Pre-configured container registry accessible from management cluster
- Downloaded k0rdent Commercial airgap bundle (contact Mirantis for access)
- Offline Helm chart repository

## Upgrade Notes

-   Ensure all `ClusterTemplate`, `ServiceTemplate`, and `ProviderTemplate` definitions are updated to use `apiVersion: v1beta1`.
-   Custom tooling or integrations built on v1alpha1 resources must be updated.
-   We recommend creating a Velero backup of your management cluster before upgrade.
-   Use helm upgrade `--reuse-values` to preserve your existing configuration.

## Deprecations

-   All `v1alpha1` APIs are now deprecated and will be removed in a future release.
-   Support for the legacy `loki-stack` logging backend has been removed. Migrate to the `victoria-log-cluster` stack.

## Known Issues

-   Grafana dashboards may take up to 60 seconds to initialise after cluster deployment.
-   MultiClusterService priority conflicts may require manual resolution if priorities are equal.
-   In high-latency networks, IPAM reconciliation can be delayed.
-   Velero restore across cloud providers may require exclusion of specific resources (see docs).

## Notable Fixes

-   Fixed invalid CR references in OpenStack/IPAM providers 
    [*#1522, #1496*]
-   Improved e2e test reliability and configuration fetching 
    [*#1517, #1463*]
-   Fixed resource tuning for VM services 
    [*#279*]
-   Corrected Istio remote secret creation 
    [*#270*]
-   Addressed Helm/YQ compatibility issue (2-arg enforcement) 
    [*#282*]

## Release Metadata

| Key                   | Value                              |
| --------------------- | ---------------------------------- |
| Helm Charts           | kcm: 1.0.0, kof: 1.0.0, ksm: 1.0.0 |
| OCI Registry          | registry.mirantis.com/k0rdent      |
| SBOM                  | Included with commercial license   |
| OCI Signature Support | Included                          |
| Release Tags          | v1.0.0 across all components       |
| Support Level         | Commercial with SLA               |

## Contributors

Special thanks to the Mirantis engineering team and the broader k0rdent community for making this release possible:  
[@gmlexx](https://github.com/gmlexx), [@denis-ryzhkov](https://github.com/denis-ryzhkov), [@ramessesii2](https://github.com/ramessesii2), [@aglarendil](https://github.com/aglarendil), [@kylewuolle](https://github.com/kylewuolle), [@a13x5](https://github.com/a13x5), [@eromanova](https://github.com/eromanova), [@zerospiel](https://github.com/zerospiel), [@BROngineer](https://github.com/BROngineer), [@cdunkelb](https://github.com/cdunkelb)

## Resources

-   [Documentation](https://docs.k0rdent.com)
-   [Mirantis Support Portal](https://support.mirantis.com)
-   [Professional Services](https://www.mirantis.com/services)
-   Enterprise Support: support@mirantis.com

## Get Started

You can try Mirantis kordent Enterprise easily using one of our [QuickStarts](../quickstarts/index.md).