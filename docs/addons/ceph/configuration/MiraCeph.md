# MiraCeph

This document describes how to configure a Ceph cluster using the `MiraCeph` object. `MiraCeph` must always be created under the `ceph-lcm-mirantis` namespace—the base controllers namespace—and is processed by the Ceph Controller pod and its ceph-controller container.

`MiraCeph` represents a declarative approach to defining your Ceph cluster configuration. It give syou precise control over the storage cluster while integrating with Kubernetes operational patterns.

`MiraCeph` consists of two main sections: `spec` and `status`.  

## Spec

The `spec` section defines the desired configuration of the Ceph cluster and its associated resources.
This section is intentionally comprehensive, enabling you to tailor every aspect of the cluster's behavior.
It includes the following:

### Clients *(Optional)*  

A list of Ceph clients used for cluster connection by consumer services.
Each `Client` includes:

- `name`: Client name.
- `caps`: Short for "capabilities", this is a key-value mapping of authorization capabilities. It includes:
    - `mon`: Specifies monitor-related permissions. A value like allow `r` grants read-only access, while additional 
            commands (for example, `allow command "osd blacklist"`) let you enable specific actions.
    - `osd`: Controls what the client can do with object storage daemons. For example, `profile rbd pool=images` 
            might grant a predefined set of operations optimized for RBD interactions on a specific pool. 
            *(For details, see [Ceph Authorization Capabilities](https://docs.ceph.com/en/latest/rados/operations/user-management/#authorization-capabilities))*

Example:
```yaml
clients:
  - caps:
      mon: allow r, allow command "osd blacklist"
      osd: profile rbd pool=images
    name: glance
  - caps:
      mon: allow r, allow command "osd blacklist"
      osd: profile rbd pool=volumes, profile rbd-read-only pool=images, profile rbd pool=backups
    name: cinder
  - caps:
      mon: allow r, allow command "osd blacklist"
      osd: profile rbd pool=vms, profile rbd-read-only pool=images
    name: nova
```

By defining clients explicitly, you control access permissions at a granular level, helping to ensure that each service 
interacts with the cluster only in the manner intended by its role.

### Data Directory

Customizing the data directory path can help align storage paths with local policies or performance tuning considerations.

- `dataDirHostPath`: Default hostPath directory where Ceph daemons store data.  This value defaults to `/var/lib/rook`.

### External Cluster Configuration *(Optional)*

By customizing the external cluster configuration, you can bridge an externally managed Ceph cluster with your Kubernetes environment, offering flexibility in scenarios where storage infrastructure is already in place.

- `external`: Enables use of an external Ceph cluster connected to the internal MKE cluster.  
  - `connectionString`: An encrypted structure with all required connection parameters.  
  

### Extra Options

The `extraOpts` values help in fine-tuning and safeguarding the cluster. For example, `preventClusterDestroy` is a simple yet effective guard against unintended operations that could lead to data loss.

- `extraOpts`: Extra options for managing the Ceph cluster.  
  Contains fields such as:
  - `customDeviceClasses`: List of custom device classes (besides the default ssd, hdd, nvme).
  - `deviceLabels`: Labels for devices to aid in node configuration and grouping.
  - `enableProgressEvents`: Flag to enable progress events (disabled by default due to CPU overhead).
  - `preventClusterDestroy`: Prevents accidental cluster removal.

Example:
```yaml
extraOpts:
  deviceLabels:
    node-a:
      disk-1: /dev/disk/by-id/<unique_ID>
  customDeviceClasses:
    - nvme-separate-class
  enableProgressEvents: true
  preventClusterDestroy: true
```

### Health Check

The `healthCheck` object provides settings for internal daemon healthchecks and liveness probes for monitors (`mon`), managers (`mgr`), and OSDs. It includes values such as:

- `startupProbe`: Configuration for the startup probe, with options such as:
    - `timeoutSeconds`
    - `periodSeconds`
    - `successThreshold`
    - `failureThreshold`
- `livenessProbe`: Configuration for the liveness probe, with options such as:
    - `initialDelaySeconds`
    - `timeoutSeconds`
    - `periodSeconds`
    - `successThreshold`
    - `failureThreshold`
- `daemonHealth`: Settings for overall health checks for daemon types, including:
    - `mon`
    - `osd`
    - `status`

Example:
```yaml
healthCheck:
  daemonHealth:
    mon:
      disabled: false
      interval: 45s
      timeout: 600s
    osd:
      disabled: false
      interval: 60s
    status:
      disabled: true
  livenessProbe:
    mon:
      disabled: false
      probe:
        timeoutSeconds: 10
        periodSeconds: 3
        successThreshold: 3
    mgr:
      disabled: false
      probe:
        timeoutSeconds: 5
        failureThreshold: 5
    osd:
      probe:
        initialDelaySeconds: 5
        timeoutSeconds: 10
        failureThreshold: 7
  startupProbe:
    mon:
      disabled: true
    mgr:
      probe:
        successThreshold: 3
```

Properly configured probes not only support operational stability but also provide early warnings of potential issues, enabling proactive remediation.

### Hyperconverge

Configures resource requests and limits for Ceph daemons and enables scheduling on tainted nodes.

- `tolerations`: Tolerations for tainted nodes (see [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)).
- `resources`: Specifies resource requests or limits (see [Manage Resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)).

Example:
```yaml
hyperconverge:
  tolerations:
    mon:
      rules:
      - effect: NoSchedule
        key: node-role.kubernetes.io/controlplane
        operator: Exists
  resources:
    mon:
      requests:
        memory: 1Gi
        cpu: 2
      limits:
        memory: 2Gi
        cpu: 3
```

This section lets you optimize daemon performance relative to your cluster's overall workload while ensuring that Ceph daemons can coexist with other system components on shared nodes.

### Ingress Configuration

Ceph on k0rdent enables you to provide the configuration of custom ingress rules for external access, 
such as setting a public endpoint for the RADOS Gateway (RGW).

- `tlsConfig`: TLS configuration including:
    - `publicDomain`: Domain name for public endpoints.
    - `tlsSecretRefName`: Name of the secret holding TLS certs.
    - `certs`: TLS certificate details (`cacert`, `tlsCert`, `tlsKey`).
- `annotations`: Extra key-value annotations.
- `controllerClassName`: Name of the ingress controller.

Example:
```yaml
ingressConfig:
  annotations:
    "nginx.ingress.kubernetes.io/proxy-body-size": "0"
  tlsConfig:
    publicDomain: domain.example.com
    certs: |
      cacert: |
        <cacert>
      tlsKey: |
        <tlsKey>
      tlsCert: |
        <tlsCert>
```

Or perhaps:
```yaml
ingressConfig:
  controllerClassName: custom-ingress-controller
  tlsConfig:
    publicDomain: domain.example.com
    tlsSecretRefName: ingress-custom-certs
```

Configuring ingress in this way allows controlled exposure of services (such as RGW) with security parameters defined as needed. This approach integrates well with standard Kubernetes practices without adding unnecessary layers of abstraction.

### Manager Modules (mgr)

Enabling specific manager modules helps streamline cluster operations by offloading workload balancing and pool autoscaling, all configured directly within the Ceph management interface.

Example:
```yaml
mgr:
  mgrModules:
  - name: balancer
    enabled: true
  - name: pg_autoscaler
    enabled: true
```

### Network

The `network` object defines ranges for daemon communication.

- `clusterNet`: CIDR for OSD replication network.
- `publicNet`: CIDR for service-to-operator communication.
  
Example:
```yaml
network:
  publicNet: "10.12.0.0/24,10.13.0.0/24"
  clusterNet: "10.10.0.0/24,10.11.0.0/24"
```

Separating network traffic based on purpose—replication versus external communication—supports better network hygiene and easier troubleshooting.

### Nodes

The `node` object includes the full configuration for Ceph nodes.

Each node entry includes:

- `name`: Kubernetes node name.
- `roles`: List of daemons to spawn (e.g., `mon`, `mgr`, `rgw`, `mds`).
- `crush`: Explicit key-value CRUSH topology (see [CRUSH Maps](https://docs.ceph.com/en/latest/rados/operations/crush-map/)).
- `config`: General Ceph node configuration.
- `nodeGroup / nodesByLabel`: For grouping nodes.
- `resources`: Kubernetes resource requirements.
- `devices`: List of devices with:
    - `name`: Device name.
    - `fullpath`: Device symlink.
    - `config`: Device configuration (must include `deviceClass` and may include `metadataDevice` or `osdsPerDevice`).

Example:
```yaml
nodes:
  - name: mon-1
    roles:
      - mon
      - mgr
      - rgw
      - mds
  - name: mon-2
    roles:
      - mon
  - name: mon-3
    roles:
      - mon
  - devices:
      - config:
          deviceClass: nvme-separate-class
        name: disk-1
```

Detailed node configuration—including CRUSH maps and resource definitions—allows operators to align the cluster layout with existing infrastructure and performance requirements.

### Object Storage

Full configuration for RadosGW and multisite features. This section provides a unified method for configuring both object storage and multi-zone capabilities, ensuring that settings remain consistent and traceable.

Includes:

- `rgw`: RADOS Gateway settings such as:
    - `name`
    - `dataPool`
    - `metadataPool`
    - `preservePoolsOnDelete`
    - `gateway`
    - `externalRgwEndpoints`
    - `resources`
- `objectUsers`: A list of object storage users. Each includes:
    - `name`
    - `displayName`
    - `capabilities`
    - `quotas`

- `buckets`: List of bucket names.
- `skipAutoZoneGroupHostnameUpdate`: Flag to disable auto-update of allowed hostnames.
- `zone`: Specifies the Ceph Multisite zone.
- `SSLCert / SSLCertInRef`: TLS certificate configuration for RGW.

### Pools

The `pools` object lets you define Ceph RBD pools. Pool configuration is where you define data redundancy and performance characteristics. The ability to choose between replication and erasure coding provides flexibility to match different workload requirements.

Each pool includes:

- `name`: Pool name prefix (final name is `<name>-<deviceClass>` unless `useAsFullName` is true).
- `useAsFullName`: If true, use the pool name as-is.
- `role`: Pool role.
- `default`: Indicates if this pool (and its StorageClass) is the default.
- `deviceClass`: Device class (HDD, SSD, NVMe).
- `replicated`: Replication settings (for example, `size` or `targetSizeRatio`).
- `erasureCoded`: Erasure coding settings (for example, `codingChunks`, `dataChunks`, `algorithm`).
- `failureDomain`: The domain for data replication (default: host).
- `allowVolumeExpansion`
- `rbdDeviceMapOptions`
- `parameters`
- `reclaimPolicy`

Example:
```yaml
pools:
  - name: kubernetes
    role: kubernetes
    deviceClass: hdd
    replicated:
      - size: 3
      - targetSizeRatio: 10.0
    default: true
  - name: datapool
    failureDomain: rack
    role: custom-pool
    deviceClass: hdd
    erasureCoded:
      - codingChunks: 1
      - dataChunks: 2
```

### Rook Config

The `rookConfig` object is a key-value map for Ceph configuration parameters. You can specify 
the config section with a delimiter (`|`). For example:

```yaml
rookConfig:
  mon|mon_warn_on_insecure_global_id_reclaim: true
  mon_target_pg_per_osd: 300
  osd.100|bluestore_allocator: hybrid
```

Fine-tuning through the Rook configuration helps in aligning Ceph's behavior with both operational policies and the underlying hardware characteristics.

### Rook Namespace

- `rookNamespace`: Should be set to `rook-ceph`.

### Shared Filesystem (CephFS)

Enables CephFS with a list of CephFS configurations. Each entry includes:

- `name`: CephFS instance name.
- `dataPools`: List of data pool specifications (first pool is the default and must be replicated).
- `metadataPool`: CephFS metadata pool (replicated only).
- `preserveFilesystemOnDelete`: Whether to delete the filesystem when CephFS is removed.
- `metadataServer`: Configuration for the metadata server (e.g., `activeCount`, `activeStandby`).

Example of a simple `MiraCeph` configuration that includes both RGW and CephFS:
```yaml
apiVersion: lcm.mirantis.com/v1alpha1
kind: MiraCeph
metadata:
  name: ceph-cluster
  namespace: ceph-lcm-mirantis
spec:
  network:
    publicNet: 10.10.0.0/24
    clusterNet: 10.11.0.0/24
  nodes:
    mon-1:
      roles:
      - mon
      - mgr
    mon-2:
      roles:
      - mon
      - mgr
    mon-3:
      roles:
      - mon
      - mgr
    osd-1:
      devices:
      - fullPath: dev/disk/by-id/scsi-1ATA_WDC_WDS100T2B0A-00SM50_200231443409
        config:
          deviceClass: ssd
    osd-2:
      devices:
      - fullPath: /dev/disk/by-id/scsi-1ATA_WDC_WDS100T2B0A-00SM50_200231440912
        config:
          deviceClass: ssd
    osd-3:
      devices:
      - fullPath: /dev/disk/by-id/scsi-1ATA_WDC_WDS100T2B0A-00SM50_200231434939
        config:
          deviceClass: ssd
  pools:
  - name: kubernetes
    role: kubernetes
    deviceClass: ssd
    replicated:
      size: 3
      targetSizeRatio: 10.0
    default: true
  objectStorage:
    rgw:
      dataPool:
        deviceClass: ssd
        erasureCoded:
          codingChunks: 1
          dataChunks: 2
        failureDomain: host
      gateway:
        instances: 3
        port: 80
        securePort: 8443
      metadataPool:
        deviceClass: ssd
        failureDomain: host
        replicated:
          size: 3
      name: object-store
      preservePoolsOnDelete: false
    sharedFilesystem:
      cephFS:
      - name: cephfs-store
        dataPools:
        - name: cephfs-pool-1
          deviceClass: ssd
          replicated:
            size: 3
          failureDomain: host
        metadataPool:
          deviceClass: ssd
          replicated:
            size: 3
          failureDomain: host
        metadataServer:
          activeCount: 1
          activeStandby: false
```

## Status

The `status` section of `MiraCeph` reflects the current state of the Ceph cluster configuration as processed by the Ceph controller.

Key fields include:
- `clusterVersion`: Current Ceph cluster version.
- `phase`: Current `MiraCeph` phase.
- `message`: Description of the current phase.
- `validation`: Contains the last validated generation and the result of validation.

Example:
```yaml
status:
  clusterVersion: v18.2.4
  message: Ceph cluster configuration successfully applied
  phase: Ready
  validation:
    lastValidatedGeneration: 2
    result: Succeed
```

Regular status reporting through this section provides operators with a clear, technical view of cluster health and configuration state, aiding in troubleshooting and routine maintenance.
