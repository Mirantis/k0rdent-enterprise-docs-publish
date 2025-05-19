# Configuration

This section describes how to fine-tune Mirantis k0rdent Virtualization by modifying the HyperConverged (HCO) custom resource, which is the central configuration point for Mirantis k0rdent Virtualization (KubeVirt) and its related components. By updating this resource, administrators can adjust certificate management, live migration behavior, resource allocation, and various operational strategies.

## HCO Custom Resource

Administrators can adjust the configuration of Mirantis k0rdent Virtualization by updating the HyperConverged custom resource. The default configuration includes:

- `CertConfig`:  Rotation policy for internal, self-signed certificates, including duration and renewBefore settings. It includes:
    - `Ca`:
        - `Duration`: The lifespan of the certificate authority (CA) certificate, such as `48h0m0s`.
        - `Renew Before`: When the certificate should be renewed prior to expiration, for example, `24h0m0s`.
    - `Server`:
        - `Duration`: The validity period for server certificates, as in `24h0m0s`.
        - `Renew Before`: How early a server certificate is renewed before it expires, as in `12h0m0s`.

- `EvictionStrategy`: Specifies how `VirtualMachineInstance` objects (VMIs) should behave during node drains. The default setting, `LiveMigrate`, instructs the system to migrate VMIs rather than shutting them down, thereby minimizing service disruption.

- `FeatureGates`:  A map of feature gate flags that enable experimental or optional functionality. The default settings include:  
    - `DownwardMetrics`: Allows a limited set of host metrics to be exposed to virtual machine guests.
    - `EnableCommonBootImageImport`: Enables the automatic delivery and updates of common data import cron templates.

- `HigherWorkloadDensity`: Provides options to increase virtual machine density on nodes.
    - `MemoryOvercommitPercentage`: Specifies the ratio of virtual machine memory allocation relative to the physical memory assigned to the hosting pod (`virt-launcher`). Default: `100%`

- `NodePlacement`:  
  Describes node scheduling preferences and constraints, defaulted to the node labels expected by {{{ docsVersionInfo.k0rdentName }}}. This configuration ensures that VM workloads are scheduled on appropriate nodes based on resource availability and policy.

- `LiveMigrationConfig`:  Sets parameters for live migration operations, ensuring minimal downtime during migration processes:  
    - `ParallelMigrationsPerCluster`: Maximum number of concurrent live migrations across the cluster. Default: `5`
    - `ParallelOutboundMigrationsPerNode`: Maximum number of migrations leaving a single node simultaneously. Default: `2`
    - `CompletionTimeoutPerGiB`: Timeout for migration completion based on guest resource size (RAM and disk). Default: `150`
    - `ProgressTimeout`: Timeout in seconds if no progress is observed during memory copying. Default: `150`

- `ResourceRequirements`:  Specifies resource allocation strategies for workload pods.
    - `VmiCPUAllocationRatio`: Defines the fraction of a physical CPU that is requested per virtual CPU (vCPU) requested by the VMI. Default: `10`

- `UninstallStrategy`: Defines how to proceed on uninstall when workloads (`VirtualMachine`, `DataVolume`, and so on) still exist.  
  Default: `BlockUninstallIfWorkloadsExist`

- `WorkloadUpdateStrategy`: Specifies how to handle disruptions during automated updates to workloads: 
    - `WorkloadUpdateMethods`: Default: `LiveMigrate`
    - `BatchEvictionInterval`: Time interval to wait before issuing the next batch of shutdowns. Default: `1 minute`
    - `BatchEvictionSize`: The number of VMIs that can be forcefully updated per batch. Default: `10`

## Integration with Ceph

Integration with Ceph allows you to seamlessly configure storage backends for your virtual machine workloads. Specific details such as storage class configuration, block or filesystem options, and persistent volume claims can be customized as needed to match your environment's requirements. This integration is designed to ensure that your virtual machines have access to robust, scalable storage solutions managed by Ceph, while remaining within the Kubernetes ecosystem. Details for integrating with Ceph can be configured as needed.

## Integration with StackLight

StackLight integration provides advanced monitoring and logging capabilities for your virtualized workloads. This integration allows you to capture detailed performance metrics and logs, aiding in both troubleshooting and capacity planning. By integrating with StackLight, administrators can gain deeper insights into the behavior of virtual machines and the underlying infrastructure, facilitating proactive management and optimization. Details for integrating with StackLight can be configured as needed.


