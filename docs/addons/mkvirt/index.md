# Mirantis k0rdent Virtualization

Mirantis k0rdent Virtualization (KubeVirt) is a complete solution for users looking to run virtual machine–based workloads on top of Kubernetes. The central technology is [KubeVirt](https://kubernetes.io/), a virtual machine management add-on for Kubernetes. Mirantis k0rdent Virtualization extends Kubernetes by adding additional virtualization resource types (especially the `VirtualMachine` type) through Kubernetes’s Custom Resource Definitions (CRDs) API. This mechanism enables you to manage VirtualMachine resources alongside all other Kubernetes resources.

## Concepts

At the heart of this approach is the **Hyperconverged Cluster Operator (HCO)**. The HCO streamlines deployment by unifying the configuration and management of multiple operators, including KubeVirt, Containerized Data Importer (CDI), networking components, and `kubevirt-manager`, via a single entry point. This cohesive setup, delivered through the HCO `ServiceTemplate` for a {{{ docsVersionInfo.k0rdentName }}} `ClusterDeployment`, helps maintain consistency and reduces the administrative burden.

## Architecture

The architecture of Mirantis k0rdent Virtualization is designed to leverage Kubernetes-native patterns for effective virtual machine management.

### Hyperconverged Cluster Operator

The **Hyperconverged Cluster Operator** aggregates a suite of components into a single management layer, following the operator pattern for managing multi-operator products. The default HCO `ServiceTemplate` installs the following components:

- **Mirantis k0rdent Virtualization:** Provides the foundational virtualization capabilities.
- **Containerized Data Importer (CDI):** Manages persistent storage by constructing virtual machine disks on PVCs.
- **Cluster Network Addons (CNA):** Enhances networking functionality, typically through Multus.
- **Kubevirt-manager:** Supplies a Web UI for easier virtual machine management.

(For more details, see [Extending Kubernetes API with CRDs](https://kubernetes.io/docs/tasks/access-kubernetes-api/extend-api-custom-resource-definitions/))
 
This consolidation reduces operational overhead and contributes to a more maintainable and resilient virtualization environment.

### KubeVirt

[KubeVirt](https://kubevirt.io/) is the core engine for virtualization within Mirantis k0rdent Virtualization. It manages the `VirtualMachine` custom resource via dedicated controllers:

#### Cluster Level Controllers

- **virt-controller:** Monitors Virtual Machine Instances (VMIs) and orchestrates their lifecycle by managing associated pods.
- **virt-api:** An HTTP API server that acts as the entry point for all virtualization-related operations, handling defaulting and validation of VMI CRDs.

#### Node Level Controllers

- **virt-handler:**  When a VMI is assigned to a host, `virt-handler` initiates the creation of the virtual domain using the `libvirtd` instance running in the VMI’s pod.
- **virt-launcher (per VMI):**  Sets up the necessary cgroups and namespaces for each VMI to run reliably.

## Limitations

While the solution is robust, constraints native to `kubevirt` inherently exist. For example, details on live migration limitations can be found in the [KubeVirt Live Migration Limitations](https://kubevirt.io/user-guide/compute/live_migration/#limitations) documentation.
