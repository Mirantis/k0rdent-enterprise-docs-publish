# Using MiraCeph Instead of KaasCephCluster

A typical **KaaSCephCluster** specification looks like this:
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

The same approach applies when the operator creates CephOsdRemoveRequest and CephPerfTestRequest objects. Instead of creating a **KaasCephOperationRequest**, the operator should create the corresponding object.

### For Ceph OSD Removal

Replace the following KaasCephOperationRequest:
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

With a CephOsdRemoveRequest:
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

Replace the following KaasCephOperationRequest:
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

With a CephPerfTestRequest:
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

For more details, please refer to the official documentation:  
[Mirantis MOSK Ceph Operations](https://docs.mirantis.com/mosk/latest/ops/ceph-operations.html)

