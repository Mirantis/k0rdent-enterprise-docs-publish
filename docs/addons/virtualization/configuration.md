# Configuration

## HCO Custom Resource

Administrators can adjust the configuration of MKE virtualization by updating the HyperConverged custom resource. The default configuration includes:

- **CertConfig:**  
  Rotation policy for internal, self-signed certificates, including duration and renewBefore settings.
  - **Ca:**
    - Duration: `48h0m0s`
    - Renew Before: `24h0m0s`
  - **Server:**
    - Duration: `24h0m0s`
    - Renew Before: `12h0m0s`

- **EvictionStrategy:**  
  Defines whether a VirtualMachineInstance should be migrated instead of being shut off during a node drain.  
  **Default:** LiveMigrate

- **FeatureGates:**  
  A map of feature gate flags with enabled defaults:
  - `DownwardMetrics` – Allows exposing a limited set of host metrics to guests.
  - `EnableCommonBootImageImport` – Enables automatic delivery/updates of common data import cron templates.

- **HigherWorkloadDensity:**  
  Configuration aimed at increasing virtual machine density.
  - **MemoryOvercommitPercentage:** The percentage of memory allocated to VMIs compared to the amount given to the hosting pod (`virt-launcher`). **Default:** 100%

- **NodePlacement:**  
  Describes node scheduling configuration, defaulted to k0rdent expected node labels.

- **LiveMigrationConfig:**  
  Sets live migration limits and timeouts:
  - **ParallelMigrationsPerCluster:** Maximum number of parallel migrations in the cluster. **Default:** 5
  - **ParallelOutboundMigrationsPerNode:** Maximum number of outbound migrations per node. **Default:** 2
  - **CompletionTimeoutPerGiB:** Timeout for migration completion based on guest size (RAM and disks). **Default:** 150
  - **ProgressTimeout:** Timeout in seconds if the memory copy fails to make progress. **Default:** 150

- **ResourceRequirements:**  
  Defines resource requirements for workload pods.
  - **VmiCPUAllocationRatio:** The fraction of a physical CPU to request per virtual CPU requested by the VMI. **Default:** 10

- **UninstallStrategy:**  
  Defines how to proceed on uninstall when workloads (VirtualMachines, DataVolumes) still exist.  
  **Default:** BlockUninstallIfWorkloadsExist

- **WorkloadUpdateStrategy:**  
  Specifies methods for disrupting workloads during automated updates:
  - **WorkloadUpdateMethods:** **Default:** LiveMigrate
  - **BatchEvictionInterval:** Time interval to wait before issuing the next batch of shutdowns. **Default:** 1 minute
  - **BatchEvictionSize:** The number of VMIs that can be forcefully updated per batch. **Default:** 10

## Integration with Ceph

Details for integrating with Ceph can be configured as needed.

## Integration with StackLight

Details for integrating with StackLight can be configured as needed.


