# AddOns

{{{ docsVersionInfo.k0rdentName }}} is inherently flexibile, enabling you to integrate additional functionalities, such as KubeVirt for virtualization, or Ceph for storage, into your Kubernetes clusters. This extensibility means you can address a wide range of workload requirements without overcomplicating your deployment.

KubeVirt extends Kubernetes to run virtual machine workloads alongside containers. By introducing native resource types for virtual machines, it allows you to manage VMs using the same operational tools and workflows you already use for Kubernetes resources. Features such as live migration and flexible scheduling ensure that virtualized workloads can be maintained with minimal disruption.

Ceph provides a unified storage solution that supports block, file, and object storage within a single system. It simplifies the management of persistent volumes by automating key processes like data replication and recovery, thereby reducing the manual overhead typically associated with enterprise storage.

Together, these add-ons increase the utility of {{{ docsVersionInfo.k0rdentName }}}, enabling you to tailor your cluster with the additional functionality you need—all while keeping the management process straightforward and consistent.

For more information:

- [Mirantis k0rdent Enterprise Virtualization (kubevirt)](kubevirt/index.md)
- [Ceph](ceph/index.md)
