# Installing StackLight

## Prerequisites

Before installing Stacklight, make sure to satisfy these prerequisites:

*   A k0s cluster: The cluster should have at least 1 worker node for non-HA installations, and a minimum of 3 worker nodes for an HA StackLight installation. 
*   Metrics scraping: Deploy k0s with the `--enable-metrics-scraper` feature (as described [here](https://docs.k0sproject.io/stable/system-monitoring/).
*   A configured `StorageClass` in the cluster: StackLight requires persistent volumes for its components. For Mirantis k0rdent Virtualization (KubeVirt), StackLight uses the `kubernetes-hdd` `StorageClass` created by Ceph.
*   An external load balancer provider: If you want StackLight's component UIs to be exposed externally, make sure the cluster has this external load balancer provider configured.
*   Kernel count: The node(s) where StackLight pods will be running should have a `vm.max_map_count` kernel parameter of 262144 or higher. You can also set `opensearch.editMaxMapCount=true` in your StackLight object spec (see [API Documentation](https://docs.google.com/document/d/1YZPEeKGC8u7J_mbSe4vpCphdAMW5N6-10yWYXnV66Rw/edit#heading=h.pplpkjyjv6jh)). This causes `opensearch init container` to set `vm.max_map_count=262144`.
*   Node roles: Only nodes marked as `role=controller+worker` and `role=worker` are monitored by StackLight, as StackLight monitoring agents are running as k8s workloads in the cluster. Make sure all nodes you want monitored are marked accordingly.
  
## Installation Procedure

StackLight has components on both the management and child clusters.

### On the {{{ docsVersionInfo.k0rdentName }}} management cluster

Follow these steps to install Stacklight on the management cluster:

1. Create a `HelmRepository` object in your KCM cluster. Create a YAML file called `stacklight-helm-repo.yaml`:      
  
    ```yaml
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: HelmRepository
    metadata:
      labels:
        k0rdent.mirantis.com/managed: "true"
      name: stacklight
      namespace: kcm-system
    spec:
      interval: 10m0s
      url: https://binary.mirantis.com/stacklight/helm/
    ```

2. Apply the YAML to the management cluster:

    ```shell
    kubectl apply -f stacklight-helm-repo.yaml -n kcm-system
    ```
    ```console
    HelmRepository object created.
    ```

3. Verify the object is created and ready: 

    ```shell   
    kubectl get helmrepo stacklight -n kcm-system
    ```
    ```console
    NAME         URL                                            AGE   READY   STATUS
    stacklight   https://binary.mirantis.com/stacklight/helm/   12d   True    stored artifact: revision 'sha256:1f5fa3f4adbfeffa6ffb929ee4488341f473b3795d9a16da0e5170450631cce4'  
    ```

3.  Create a `ServiceTemplate` object by starting with a YAML file called `stacklight-operator-template.yaml`:
      
    ```yaml
    apiVersion: k0rdent.mirantis.com/v1beta1
    kind: ServiceTemplate
    metadata:
      name: stacklight-operator-{{{ docsVersionInfo.addonVersions.dashVersions.stacklightOperator}}}
      namespace: kcm-system
    spec:
      helm:
        chartSpec:
          chart: stacklight-operator
          interval: 10m0s
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: stacklight
          version: {{{ docsVersionInfo.addonVersions.dotVersions.stacklightChart }}}
    ```

4. Add the YAML to the cluster:

    ```shell
    kubectl apply -f stacklight-operator-template.yaml -n kcm-system
    ```
    ```console
    ServiceTemplate object created.
    ```

4. Verify the object is created and valid:
      
    ```shell
    kubectl get servicetemplate stacklight-operator-{{{ docsVersionInfo.addonVersions.dashVersions.stacklightOperator}}} -n kcm-system
    ```
    ```console
    NAME                        VALID
    stacklight-operator-{{{ docsVersionInfo.addonVersions.dashVersions.stacklightOperator}}}   true
    ```
  

5.  Finally, add the `stacklight-operator` `Service` to the `.spec.serviceSpec.services` list of the targeted `ClusterDeployment` object. You can do this on the initial `ClusterDeployment` creation or by modifying the existing `ClusterDeployment` object, as in:  
      
    ```yaml
    apiVersion: k0rdent.mirantis.com/v1beta1
    kind: ClusterDeployment
    ...
    spec:
      serviceSpec:
        services:
        ...
        - name: stacklight-operator
          namespace: stacklight-system
          template: stacklight-operator-{{{ docsVersionInfo.addonVersions.dashVersions.stacklightOperator}}}
        ...
    ```

### On the targeted KCM Mirantis k0rdent Virtualization managed child cluster

Once you've installed StackLight into the management cluster, you need to install it on the child cluster you want to monitor. Follow these steps, making sure KUBECONFIG points to the proper cluster:

1. Create a separate StackLight namespace:     

    ```shell
    kubectl create ns stacklight
    ```
  
2.  Create a `StackLight` object and configure it according to your needs. Check the available configuration options (see the [API Documentation](./api.md)). For example, create a YAML file called `minimal-stacklight.yaml` with a minimal required configuration:  
      
    ```yaml
    apiVersion: monitoring.mirantis.com/v1alpha1
    kind: StackLight
    metadata:
      name: stacklight
      namespace: stacklight
    spec:
      exposeLoadBalancers: true
      highAvailabilityEnabled: true
      kubernetes:
        distribution: k0s
      kubevirtMonitoringEnabled: true
      opensearch:
        editMaxMapCount: true
        persistentVolumeClaimSize: 50Gi
      prometheus:
        persistentVolumeClaimSize: 50Gi
        retentionSize: 45GB
        retentionTime: 30d
      storageClassName: kubernetes-hdd
    ```

    > NOTE:
    > You must set `kubevirtMonitoringEnabled=true` to enable installation of Mirantis k0rdent Virtualization monitoring-related components.

3. Finally, add the `StackLight` YAML to the cluster:

    ```shell
    kubectl apply -f minimal-stacklight.yaml -n stacklight
    ```
    ```console
    StackLight object created.
    ```