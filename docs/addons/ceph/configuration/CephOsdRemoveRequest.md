# CephOsdRemoveRequest

The `CephOsdRemoveRequest` object is used for Ceph Object Storage Daemon (OSD) lifecycle management (LCM). It allows the operator to manage the removal of OSDs from the cluster.

## Spec

The `spec` section describes what should be cleaned up:

- `nodes:` A mapping of node names with specifications:
    - `completeCleanUp:` Boolean flag for full node cleanup (including removal from the CRUSH map).
    - `dropFromClusterOnly:` Remove the OSD from the cluster without cleaning devices.
    - `cleanupStrayPartitionsOnly:` Clean only stray partitions.
    - `cleanupByOsdId:` List of OSD IDs to remove.
    - `cleanupByDevice:` List of devices to clean (by name or path).
- Additional fields include `approve`, `keepOnFail`, `resolved`, `resumeFailed`, and `resumeFailedStep`.

Example:
```yaml
apiVersion: lcm.mirantis.com/v1alpha1
kind: CephOsdRemoveRequest
metadata:
  name: lcm-req
  namespace: ceph-lcm-mirantis
spec:
  nodes:
    node-a:
      completeCleanUp: true
    node-b:
      cleanupByDevice:
      - name: sdb
      - path: "/dev/disk/by-path/pci-0000:00:0x.0"
    node-c:
      cleanupByOsdId:
      - 5
      - 10
```

## Status
The `status` section provides:
- `phase:` Current phase of the request (e.g., Pending, Processing, CompletedWithWarnings).
- `phaseInfo:` Additional information about the phase.
- `removeInfo:` Detailed mapping of what is scheduled for removal.
- `failedStepID:` Identifier of any failed step.
- `messages:` List of messages regarding request progress.
- `conditions:` Historical record of phase transitions and status changes.

*(A full example is provided in the document.)*
