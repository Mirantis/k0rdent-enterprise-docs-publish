# Virtualization Best Practices

This document outlines best practices to ensure stable performance and effective management of virtual machines running on Mirantis k0rdent Virtualization. Here, “VM” refers to Virtual Machines and also covers VMIs and VMI ReplicaSets. The guidelines provided help ensure that VMs remain live-migratable and recoverable, even under challenging conditions.

> **Note:** All recovery procedures required for VMs to be LiveMigratable.

## Run Strategy

The `runStrategy` parameter determines how VMs are started and restarted after failures. For rapid recovery, set `runStrategy` to either `Always` or `RerunOnFailure`.

```yaml
runStrategy: Always
```

Using an aggressive run strategy ensures that VMs are automatically restarted in the event of a failure, reducing downtime and maintaining service continuity.

For further details, refer to the [KubeVirt run strategies guide](https://kubevirt.io/user-guide/compute/run_strategies/).

## Common Practices

To avoid issues with resource consumption (CPU, memory), specify resources for virtual machines via the VM template:

To manage resource consumption effectively and prevent performance bottlenecks, it is important to define resource requests and limits within your VM templates. This can be done directly in the YAML specification:

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

Explicit resource specifications help ensure that VMs are scheduled efficiently across the cluster. Additionally, using instance types simplifies resource allocation and promotes consistency in workload management. It is also possible to schedule a VM to specific nodes or racks by setting `nodeSelector`:

```yaml
nodeSelector:
  nodeLabel: labelValue
```

Or specify the node when creating a VM via the UI. In such cases, ensure that available resources are checked beforehand—note that some memory and CPU are reserved for other processes running on the nodes.

## Maintenance of Node Handling

During node maintenance, it is critical to migrate all running VMs from the affected node. Update the VM specification to set the `evictionStrategy` to `LiveMigrate`:

> NOTE: 
> By default, the `EvictionStrategy` is defined at the cluster level by HCO, with the default set to `LiveMigrate` for all VMIs.

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

Migrating VMs prior to node maintenance minimizes service disruption and ensures that workload capacity is maintained throughout the process.

## Accident Recovery

For VMs running on heavily loaded nodes, or in the event of unexpected evictions (for example, due to an OOM event), setting the `evictionStrategy` to `LiveMigrate` ensures that VMs are migrated to healthier nodes. This practice, combined with a proactive run strategy, allows for smooth recovery and continued operation.

Specifying an eviction strategy helps prevent VMs from being terminated abruptly without a chance to migrate, which could lead to extended downtime.

## Node Overload

For nodes running VMs under heavy load (especially when VMs are executing resource-intensive workloads), it is recommended to set the eviction strategy for such VMs:

```yaml
evictionStrategy: LiveMigrate
```

Refer to these guides for more information:  
- [Node Overcommit](https://kubevirt.io/user-guide/compute/node_overcommit/)  
- [Node Maintenance](https://kubevirt.io/user-guide/cluster_admin/node_maintenance/)

This configuration allows kubelet to evict a VM from an overloaded node (for example, in the case of an OOM event) using live migration. Without specifying an eviction strategy, a VM may be evicted without migration, potentially leading to VM unavailability until resources become available. Again, the successful recovery of a VM after eviction depends on the `runStrategy` specified in the VM spec.

## Node Shutdown

If a node shuts down or becomes unreachable/unavailable, it is possible to recover a VM that was running on that node using live migration. First, verify that there are available nodes for the VM to migrate to and that nodeSelector labels permit migration. Then, perform migration of the VM using either `virtctl` or the Mirantis k0rdent Virtualization (Kubevirt) UI:

```bash
virtctl migrate <VM Name>
```

Live migration in node shutdown scenarios helps ensure that VMs are quickly re-assigned to available nodes, although some pods may remain in a Terminating state until the node recovers.



## Virtual Machine Crash

If a VM shuts down unexpectedly, Mirantis k0rdent Virtualization will automatically restart it. No administrator action is required.

## Detecting Broken State

Configuring a `LivenessProbe` in the VM specification ensures that VMs are continuously monitored and automatically recreated if they enter a failed state. For example:

```yaml
livenessProbe:
  initialDelaySeconds: 120
  periodSeconds: 20
  tcpSocket:
    port: 1500
  timeoutSeconds: 10
```

This probe verifies that the service is running and that port 1500 is available. If the port is unavailable, the VM will be automatically recreated.

Liveness (and optionally, readiness) probes help maintain a healthy VM environment by detecting and remedying issues before they impact service availability. More information is available in the [KubeVirt user guide on probes](https://kubevirt.io/user-guide/user_workloads/liveness_and_readiness_probes/).

