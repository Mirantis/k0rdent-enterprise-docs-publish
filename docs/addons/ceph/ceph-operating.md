# Ceph Cluster Operations

Each change in the Ceph cluster should be reflected in the `MiraCeph` specification. By directly editing the `MiraCeph` object, you ensure that all desired configuration changes are applied consistently across the Ceph cluster managed by Mirantis k0rdent Enterprise.

To update the `MiraCeph` object, use:

```bash
kubectl edit miraceph -n ceph-lcm-mirantis
```

After saving changes, you can verify the current state of the `MiraCeph` object. For example, a non-ready `MiraCeph` object might appear as follows:

```bash
kubectl get miraceph -n ceph-lcm-mirantis
NAME          AGE   VALIDATION   PHASE       CLUSTER VERSION   MESSAGE                
cephcluster   20h   Succeed      Deploying   v18.2.4           Ceph cluster configuration apply is in progress: ceph object storage
```

In contrast, an applied `MiraCeph` object with no pending configuration changes would look like this:

```bash
kubectl get miraceph -n ceph-lcm-mirantis
NAME          AGE     VALIDATION   PHASE   CLUSTER VERSION   MESSAGE                  
cephcluster   2d12h   Succeed      Ready   v18.2.4           Ceph cluster configuration successfully applied
```

This clear status reporting allows operators to quickly assess whether the configuration has been fully applied or if further action is needed. The separation of phases (for example, "Deploying" vs. "Ready") helps in pinpointing any issues during the update process.

## Checking Cluster Health and Secrets

Maintaining visibility into the cluster's operational health is critical. Operators can check the overall health of the Ceph cluster by querying the `MiraCeph`Health object:

```bash
kubectl get miracephhealth -n ceph-lcm-mirantis
NAME          AGE     STATE   LAST CHECK             LAST UPDATE 
cephcluster   6d17h   Ready   2024-07-30T11:05:14Z   2024-07-30T11:05:14Z
```

Similarly, the status of secrets--used for securely storing critical credentials--is accessible via the `MiraCephSecret` object:

```bash
kubectl get miracephsecret -n ceph-lcm-mirantis
NAME          AGE     STATE   LAST CHECK             LAST UPDATE 
cephcluster   6d17h   Ready   2024-07-30T11:09:03Z   2024-07-24T15:56:12Z
```

Regularly monitoring these objects helps operators ensure that both the configuration and the associated security credentials are up-to-date. Quick access to these statuses aids in troubleshooting and provides confidence that the cluster is operating within expected parameters.

## Ceph Controllers and Rook Resources

Ceph controllers play a crucial role in automating the deployment of the Ceph cluster. These controllers are responsible for creating all required Rook resources in the `rook-ceph` namespace. The `rook-ceph-operator` is central to this process as it:

- Spawns all necessary Ceph daemons.
- Manages OSD preparation and deployment.
- Monitors cluster health.
- Handles version upgrades.

For a deeper dive into how these components work together, refer to the [Rook Getting Started Guide](https://rook.io/docs/rook/latest/Getting-Started/intro/).

By delegating the management of underlying Rook resources to the Ceph controllers, operators can focus on high-level configuration without worrying about the lower-level orchestration details.

## Ceph Cluster LCM Operations

Ceph Lifecycle Management (LCM) operations ensure that the cluster remains healthy and that maintenance tasks are carried out in a controlled manner. These operations are performed by several components:

- **Ceph Controller:**  
  Applies changes to the `MiraCeph` spec (excluding OSD removal), ensuring that the overall configuration is consistently enforced across the cluster.

- **`ceph-disk-daemon`:**  
  Collects detailed information from hosts running OSDs—such as disk usage, partition details, and active OSD instances. This information is vital for making informed decisions during maintenance operations.

- **Ceph Request Controller:**  
  Specifically, the `osdremove` container handles the OSD cleanup process. It:

  - Verifies the `CephOsdRemoveRequest` provided by the operator.
  - Utilizes the data collected by the `ceph-disk-daemon`.
  - Executes the removal of OSDs.
  - Updates the `CephOsdRemoveRequest` with the current cleanup status.

For further details, please refer again to the [Rook Getting Started Guide](https://rook.io/docs/rook/latest/Getting-Started/intro/).

Breaking down the LCM operations into dedicated roles (configuration enforcement, data collection, and targeted operations like OSD removal) not only enhances operational transparency but also improves the reliability of cluster maintenance procedures.
