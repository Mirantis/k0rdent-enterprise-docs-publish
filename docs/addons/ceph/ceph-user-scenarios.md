# Ceph User Scenarios

This section describes basic user scenarios for Ceph usage in Kubernetes workloads. It also covers Ceph usage as the underlying storage system for KubeVirt.

---

## Ceph Block PVC Creation

The Ceph solution allows creating Block Ceph-based PVCs without any additional steps. The Ceph Controller automatically creates a corresponding StorageClass for every Ceph Block pool defined in the `spec.pools` section of the MiraCeph specification.

For example, if there is a pool named `block-pool` defined as:

```yaml
spec:
  pools:
  - name: block-pool
    useAsFullName: true
    deviceClass: hdd
    default: true
    replicated:
      size: 3
    role: block-pool
```

Then a corresponding StorageClass will be created along with the pool’s creation:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
  creationTimestamp: "2025-02-28T11:12:21Z"
  labels:
    rook-ceph-storage-class: "true"
  name: block-pool
  resourceVersion: "20460"
  uid: c58f11db-645f-4c45-9dd8-b009f828a058
parameters:
  clusterID: rook-ceph
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
  csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
  imageFeatures: layering
  imageFormat: "2"
  pool: block-pool
provisioner: rook-ceph.rbd.csi.ceph.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

Ceph RADOS Block Device supports creating Persistent Volumes (PVs) with:
- **Block volumeMode:** for access modes such as Read-Write-Once (RWO), Read-Only-Many (ROX), and Read-Write-Many (RWX).
- **Filesystem volumeMode:** for RWO and ROX access modes.

For the full support matrix, see:  
[Ceph CSI Support Matrix](https://github.com/ceph/ceph-csi?tab=readme-ov-file#support-matrix).

To create a Ceph-based Block PV, define a PVC manifest on the Block pool StorageClass:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-block-volume
  namespace: default
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 20Gi
  storageClassName: block-pool
  volumeMode: Block
```

This PVC can now be attached as a volume to any Kubernetes workload (e.g., Deployments, StatefulSets, Pods).

---

## Ceph Filesystem PVC Creation

The Ceph solution also supports creating Filesystem Ceph-based PVCs without additional steps. The Ceph Controller automatically creates a corresponding StorageClass for every CephFS data pool defined in the `spec.sharedFilesystem.cephFS[].dataPools` section of the MiraCeph specification.

For example, if there is a data pool named `filesystem-pool` defined as:

```yaml
sharedFilesystem:
  cephFS:
  - name: cephfs-store
    dataPools:
    - name: filesystem-pool
      deviceClass: hdd
      replicated:
        size: 3
    metadataPool:
      deviceClass: hdd
      replicated:
        size: 3
    metadataServer:
      activeCount: 1
      activeStandby: false
```

Then a corresponding StorageClass will be created along with the pool’s creation (the StorageClass parameters are similar to those used for Block PVCs).

To create a Ceph-based Filesystem PV, define a PVC manifest using the appropriate StorageClass.

---

## Ceph Usage in KubeVirt VMs

KubeVirt can use Ceph-based StorageClasses to provide persistent storage for Virtual Machines.

> **Note:** It is recommended to enable the `device_ownership_from_security_context` functionality in the container runtime (CRI) for correct handling of Block volumes by KubeVirt. More details are available at:  
> [Block CRI Ownership Configuration](https://github.com/kubevirt/containerized-data-importer/blob/main/doc/block_cri_ownership_config.md).

Ceph-based persistent volumes can be defined in a KubeVirt VirtualMachine manifest. For example:

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  labels:
    kubevirt.io/vm: vm-cirros-datavolume
  name: vm-cirros-datavolume-ceph
spec:
  dataVolumeTemplates:
  - metadata:
      name: cirros-dv
    spec:
      pvc:
        accessModes:
        - ReadWriteMany
        resources:
          requests:
            storage: 2Gi
        storageClassName: cephfs-store-filesystem-pool
        volumeMode: Filesystem
      source:
        registry:
          url: docker://docker-dev-kaas-local.docker.mirantis.net/kubevirt/cirros-container-disk-demo:1.4.0-20250217075514
  - metadata:
      name: additional-dev
    spec:
      storage:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 10Gi
        storageClassName: block-pool
        volumeMode: Block
      source:
        pvc:
          name: cirros-dv-add-vol
          namespace: default
  running: true
  template:
    metadata:
      labels:
        kubevirt.io/vm: vm-cirros-datavolume
    spec:
      domain:
        devices:
          disks:
          - disk:
              bus: virtio
            name: datavolumedisk1
          - disk:
              bus: virtio
            name: datavolumedisk2
        resources:
          requests:
            memory: 128Mi
      terminationGracePeriodSeconds: 0
      volumes:
      - dataVolume:
          name: cirros-dv
        name: datavolumedisk1
      - dataVolume:
          name: additional-dev
        name: datavolumedisk2
```

In this example, two different Ceph-based PVCs are used as DataVolumes for the Virtual Machine:
- A **Filesystem RWX volume** based on the CephFS StorageClass (`cephfs-store-filesystem-pool`) used as the root disk.
- A **Block RWO volume** based on an already created PVC (`cirros-dv-add-vol`) using the Block StorageClass (`block-pool`).

The underlying Block PVC manifest for `cirros-dv-add-vol` is as follows:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cirros-dv-add-vol
  namespace: default
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: block-pool
  volumeMode: Block
```

This manifest creates the additional Block PVC, which can then be attached to the Virtual Machine as an extra DataVolume.
