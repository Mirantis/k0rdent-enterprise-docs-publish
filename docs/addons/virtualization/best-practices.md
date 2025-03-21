# Kubevirt Virtual Machines Best Practices

The current document covers basic practices that will guarantee stable performance of Kubevirt virtual machines. In this document, "VM" refers to Virtual Machines, which also applies to VMI and VMI ReplicaSets.

> **Note:** All recovery procedures required for VMs to be LiveMigradable.

---

## Run Strategy

For VMs, the configurable `runStrategy` spec parameter determines how VMs will be started. In order to immediately restore VMs after failure, `runStrategy` should be set to `Always` or `RerunOnFailure`.

```yaml
runStrategy: Always
```

More information about run strategies can be found in the [user guide](https://kubevirt.io/user-guide/compute/run_strategies/).

---

## Common Practices

To avoid issues with resource consumption (CPU, memory), specify resources for virtual machines via the VM template:

```yaml
resources:
  requests:
    memory: 10Gi
    cpu: 8
  limits:
    memory: 12Gi
    cpu: 10
```

Alternatively, you can use instance types:

```yaml
instancetype:
  kind: VirtualMachineInstancetype
  name: clarge
```

By default, Kubevirt schedules VMs across the cluster to guarantee even resource utilization. It is also possible to schedule a VM to specific nodes or racks by setting `nodeSelector`:

```yaml
nodeSelector:
  nodeLabel: labelValue
```

Or specify the node when creating a VM via the UI. In such cases, ensure that available resources are checked beforehand—note that some memory and CPU are reserved for other processes running on the nodes.

Additional configuration details can be found in the Kubevirt user guide.

---

## Maintenance of Node Handling

> **Note:** By default, the `EvictionStrategy` is defined at the cluster level by HCO, with the default set to `LiveMigrate` for all VMIs.

In the event of node maintenance, all VMs should be migrated from the node before maintenance begins. Update the VM spec and specify the eviction strategy:

```yaml
evictionStrategy: LiveMigrate
```

This setting allows you to initiate migration of all running VMs from the node using the `kubectl drain` command:

```bash
kubectl drain <nodeName> --ignore-daemonsets=true --force --delete-emptydir-data
```

Before running the drain command, verify that VMs can be scheduled on other nodes (i.e., ensure there are no restrictions in the node selector and that sufficient resources are available). Note that a successful VM run after eviction depends on the `runStrategy` specified in the VM spec. If the VM is part of a VM ReplicaSet, only VMs scheduled on the drained node will be migrated.

After completing node maintenance, run the following command to make the node schedulable again:

```bash
kubectl uncordon <nodeName>
```

More information about node maintenance can be found in the user guide.

---

## Accidents Recovery

> **Note:** As with maintenance, by default the `EvictionStrategy` is defined at the cluster level by HCO and the default is `LiveMigrate` for all VMIs.

---

## Node Overload

For nodes running VMs under heavy load (especially when VMs are executing resource-intensive workloads), it is recommended to set the eviction strategy for such VMs:

```yaml
evictionStrategy: LiveMigrate
```

Refer to these guides for more information:  
- [Node Overcommit](https://kubevirt.io/user-guide/compute/node_overcommit/)  
- [Node Maintenance](https://kubevirt.io/user-guide/cluster_admin/node_maintenance/)

This configuration allows kubelet to evict a VM from an overloaded node (for example, in the case of an OOM event) using live migration. Without specifying an eviction strategy, a VM may be evicted without migration, potentially leading to VM unavailability until resources become available. Again, the successful recovery of a VM after eviction depends on the `runStrategy` specified in the VM spec.

---

## Node Shutdown

If a node shuts down or becomes unreachable/unavailable, it is possible to recover a VM that was running on that node using live migration. First, verify that there are available nodes for the VM to migrate to and that nodeSelector labels permit migration. Then, perform migration of the VM using either `virtctl` or the Kubevirt UI:

```bash
virtctl migrate <VM Name>
```

It is expected that until the node is recovered, some pods may remain in the Terminating state.

---

## Virtual Machine Crash

If a VM shuts down unexpectedly, Kubevirt will automatically restart the VM—no administrator action is required.

---

## Detecting Broken State

It is possible to configure **LivenessProbes** for VMs in a manner similar to Kubernetes containers. This ensures that the VM is in a running state. Liveness probes are configured in the VM spec as follows:

```yaml
livenessProbe:
  initialDelaySeconds: 120
  periodSeconds: 20
  tcpSocket:
    port: 1500
  timeoutSeconds: 10
```

This probe verifies that the service is running and that port 1500 is available. If the port is unavailable, the VM will be automatically recreated. In addition to liveness probes, **ReadinessProbes** can also be configured. More information about configuring probes is available in the [Kubevirt user guide](https://kubevirt.io/user-guide/user_workloads/liveness_and_readiness_probes/).

