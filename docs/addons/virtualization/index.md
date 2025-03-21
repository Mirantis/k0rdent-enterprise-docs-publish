# k0rdent Virtualization

## Introduction

k0rdent virtualization is a complete solution for users looking to run virtual machine–based workloads on top of Kubernetes. The central technology is [KubeVirt](https://kubernetes.io/), a virtual machine management add-on for Kubernetes. At its core, KubeVirt extends Kubernetes by adding additional virtualization resource types (especially the `VirtualMachine` type) through Kubernetes’s Custom Resource Definitions (CRDs) API. This mechanism enables you to manage VirtualMachine resources alongside all other Kubernetes resources.

## Concepts

To configure KubeVirt functionality in a k0rdent environment, the **Hyperconverged Cluster Operator (HCO)** is used. The HCO allows the deployment of multiple Kubernetes operators—such as kubevirt, CDI (Containerized Data Importer), networking, and kubevirt-manager—through a single entry point. This enables users to have a fully operational environment by enabling the HCO ServiceTemplate for a k0rdent ClusterDeployment.

## Architecture

### Hyperconverged Cluster Operator

The **HyperConverged Cluster Operator** follows the operator pattern for managing multi-operator products. The default HCO ServiceTemplate installs the following components:

- **KubeVirt**
- **Containerized Data Importer (CDI):**  
  A persistent storage management add-on for Kubernetes. Its primary goal is to provide a declarative way to build virtual machine disks on PVCs for KubeVirt VMs.
- **Cluster Network Addons (CNA):**  
  Deploys additional networking components on top of the Kubernetes cluster (default setup uses Multus).
- **Kubevirt-manager:**  
  A Web UI for operating with Virtual Machines.

For more details, see:  
[https://kubernetes.io/](https://kubernetes.io/)  
[Extending Kubernetes API with CRDs](https://kubernetes.io/docs/tasks/access-kubernetes-api/extend-api-custom-resource-definitions/)

### KubeVirt

[KubeVirt](https://kubevirt.io/) adds virtualization functionality to your Kubernetes cluster by managing the Kubernetes Custom Resource `VirtualMachine` via a set of controllers:

#### Cluster Level Controllers

- **virt-controller:**  
  Monitors Virtual Machine Instances (VMIs) and manages the lifecycle of the associated pods.
- **virt-api:**  
  An HTTP API server that acts as the entry point for all virtualization-related operations, handling defaulting and validation of VMI CRDs.

#### Node Level Controllers

- **virt-handler:**  
  Observes when a VMI is assigned to a host and, using the VMI specification, signals the creation of the corresponding domain via a `libvirtd` instance running in the VMI’s pod.
- **virt-launcher (per VMI):**  
  Provides the necessary cgroups and namespaces to host the VMI process.

For more details on CRDs, refer to:  
[Extending Kubernetes API with CRDs](https://kubernetes.io/docs/tasks/access-kubernetes-api/extend-api-custom-resource-definitions/)

## Limitations

- **MKE Virtualization Limitations**
- **KubeVirt Limitations:**  
  For details on limitations, refer to the official documentation on [KubeVirt Live Migration Limitations](https://kubevirt.io/user-guide/compute/live_migration/#limitations).