# Ceph Cluster Operating

Each change in the Ceph cluster should be reflected in the MiraCeph specification. To update the MiraCeph object, use:

```bash
kubectl edit miraceph -n ceph-lcm-mirantis
```

After saving changes, the operator can verify the current state of the MiraCeph object. For example, a non-ready MiraCeph object might appear as follows:

```bash
kubectl get miraceph -n ceph-lcm-mirantis
NAME          AGE   VALIDATION   PHASE       CLUSTER VERSION   MESSAGE                
cephcluster   20h   Succeed      Deploying   v18.2.4           Ceph cluster configuration apply is in progress: ceph object storage
```

An applied MiraCeph object with no configuration changes would look like this:

```bash
kubectl get miraceph -n ceph-lcm-mirantis
NAME          AGE     VALIDATION   PHASE   CLUSTER VERSION   MESSAGE                  
cephcluster   2d12h   Succeed      Ready   v18.2.4           Ceph cluster configuration successfully applied
```

---

## Checking Cluster Health and Secrets

Operators can check cluster health by querying the MiraCephHealth object:

```bash
kubectl get miracephhealth -n ceph-lcm-mirantis
NAME          AGE     STATE   LAST CHECK             LAST UPDATE 
cephcluster   6d17h   Ready   2024-07-30T11:05:14Z   2024-07-30T11:05:14Z
```

To view the status of secrets managed by MiraCephSecret:

```bash
kubectl get miracephsecret -n ceph-lcm-mirantis
NAME          AGE     STATE   LAST CHECK             LAST UPDATE 
cephcluster   6d17h   Ready   2024-07-30T11:09:03Z   2024-07-24T15:56:12Z
```

---

## Ceph Controllers and Rook Resources

Ceph controllers are responsible for creating all required Rook resources in the `rook-ceph` namespace. These resources are managed by the **rook-ceph-operator**, which spawns all Ceph daemons and handles OSD preparation, health monitoring, and Ceph cluster version upgrades. For more details, see the [Rook Getting Started Guide](https://rook.io/docs/rook/latest/Getting-Started/intro/).

---

## Ceph Cluster LCM Operations

Ceph Lifecycle Management (LCM) operations are performed by a combination of:

- **Ceph Controller:**  
  Handles the application of spec changes (excluding OSD removal).

- **ceph-disk-daemon:**  
  Collects information from hosts where OSDs are running (e.g., used disks, partitions, LVMs, running OSD daemons).

- **Ceph Request Controller:**  
  (The osdremove container) Handles the OSD cleanup process. It:
  - Verifies the CephOsdRemoveRequest specified by the operator.
  - Uses information collected by the ceph-disk-daemon.
  - Executes the actual removal of OSDs.
  - Updates the CephOsdRemoveRequest with cleanup status at each stage.

For additional information, please refer to the [Rook Getting Started Guide](https://rook.io/docs/rook/latest/Getting-Started/intro/).
