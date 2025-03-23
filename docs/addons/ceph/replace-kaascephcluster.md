# MiraCeph Instead of KaasCephCluster

In some scenarios, operators prefer to use MiraCeph because it provides a more direct and decoupled way to manage Ceph clusters. With `MiraCeph`, the Ceph cluster configuration is applied directly under the `ceph-lcm-mirantis` namespace, avoiding the extra layer of indirection introduced by the `KaasCephCluster` object. This can simplify troubleshooting and provide a clearer view of the storage configuration.

A typical `KaaSCephCluster` specification looks like this:
```yaml
apiVersion: kaas.mirantis.com/v1alpha1
kind: KaaSCephCluster
metadata:
  name: test-child-req
  namespace: child-ns
spec:
  cephClusterSpec:
    … 
    {ceph-cluster-spec}
    … 
  kaasCephCluster:
    name: ceph-cluster-child-cluster
    namespace: child-ns
```

To configure MiraCeph, the operator should apply the `{ceph-cluster-spec}` block directly in the MiraCeph spec field:
```yaml
apiVersion: lcm.mirantis.com/v1alpha1
kind: MiraCeph
metadata:
  name: ceph-cluster
  namespace: ceph-lcm-mirantis
spec:
  … 
  {ceph-cluster-spec}
  … 
```

## Replacing KaasCephOperationRequest

The same approach applies when the operator creates CephOsdRemoveRequest and CephPerfTestRequest objects. Instead of creating a `KaasCephOperationRequest`, the operator should create the corresponding object. By using dedicated objects for 
each operation, such as CephOsdRemoveRequest and CephPerfTestRequest, the configuration becomes more modular and transparent.

### For Ceph OSD Removal

For example, to remove a Ceph Object Storage Daemon, replace the following `KaasCephOperationRequest`...

```yaml
apiVersion: kaas.mirantis.com/v1alpha1
kind: KaaSCephOperationRequest
metadata:
  name: lcm-req
  namespace: child-ns
spec:
  kaasCephCluster:
    name: ceph-cluster-child-cluster
    namespace: child-ns
  osdRemove:
    … 
    {osd-request-spec}
    … 
```

... with a `CephOsdRemoveRequest`:

```yaml
apiVersion: lcm.mirantis.com/v1alpha1
kind: CephOsdRemoveRequest
metadata:
  name: lcm-req
  namespace: ceph-lcm-mirantis
spec:
  … 
  {osd-request-spec}
  … 
```

### For Ceph Performance Testing

To engage in performance testing, replace the following `KaasCephOperationRequest`...
```yaml
apiVersion: kaas.mirantis.com/v1alpha1
kind: KaaSCephOperationRequest
metadata:
  name: perf-req
  namespace: child-ns
spec:
  kaasCephCluster:
    name: ceph-cluster-child-cluster
    namespace: child-ns
  perfTest:
    … 
    {perftest-request-spec}
    … 
```

... with a `CephPerfTestRequest`:

```yaml
apiVersion: lcm.mirantis.com/v1alpha1
kind: CephPerfTestRequest
metadata:
  name: perftest-req
  namespace: ceph-lcm-mirantis
spec:
  … 
  {perftest-request-spec}
  … 
```

## Additional Considerations

There are several reasons to consider `MiraCeph` instead of `KaasCephCluster`, including:

- **Direct Configuration:** MiraCeph enables you to inject the Ceph cluster specification directly, which can simplify management by removing the extra abstraction layer found in KaasCephCluster.
- **Namespace Isolation:** Deploying MiraCeph in the `ceph-lcm-mirantis` namespace centralizes Ceph operations, making it easier to monitor and maintain.
- **Focused Operations:** Replacing the general KaasCephOperationRequest with dedicated operation requests (e.g., for OSD removal or performance testing) leads to clearer, purpose-built configurations.
- **Flexibility:** For operators who need fine-grained control or who prefer a more transparent view of their Ceph cluster’s configuration, MiraCeph is a straightforward alternative.

For more details, please refer to the official documentation:  
[Mirantis MOSK Ceph Operations](https://docs.mirantis.com/mosk/latest/ops/ceph-operations.html)

