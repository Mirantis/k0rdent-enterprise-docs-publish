# How-To Deploy HCO on a {{{ docsVersionInfo.k0rdentName }}} Environment

This guide outlines the step-by-step process for using {{{ docsVersionInfo.k0rdentName}}} to deploy the components of Mirantis k0rdent Virtualization on child clusters.

The first step in this process is to deploy the Hyperconverged Cluster Operator (HCO) on the target cluster. The HCO simplifies deployment of additional Mirantis k0rdent Virtualization components such as KubeVirt, CDI, networking, and `kubevirt-manager`, providing a unified method to manage virtual machine workloads on that child cluster.

## Prerequisites

Before proceeding, ensure you have the following in place:

- A deployed k0rdent child cluster with `cert-manager` installed.
- The `kubectl` utility installed and configured.
- kubeconfig files for both the KCM (k0rdent Control Manager) and the child clusters.

## cert-manager

In order for the HCO webhook service to function properly, you need to have `cert-manager` deployed and enabled on the target child cluster.

To determine whether `cert-manager` is deployed, `describe` the `ClusterDeployment`, as in:

```shell
kubectl describe ClusterDeployment <CLUSTER-NAME> -n <CLUSTER-NAMESPACE> 
```

For example, if you've created a `ClusterDeployment` named `ksi-managed-cluster` in the `kcm-system` namespace, you'd use:

```shell
kubectl describe ClusterDeployment ksi-managed-cluster -n kcm-system
```
```console
...
      - name: cert-manager
        namespace: cert-manager
        template: cert-manager-{{{ docsVersionInfo.servicesVersions.dashVersions.certManager}}}
        values: |
          cert-manager:
            crds:
              enabled: true
...
```

If you don't see the `cert-manager` service, you can go ahead and add it.  Start by adding the new
spec in a file called `clusterdeployment-patch.yaml`:

```yaml
spec:
  serviceSpec:
    services:
      - name: cert-manager
        namespace: cert-manager
        template: cert-manager-{{{ docsVersionInfo.servicesVersions.dashVersions.certManager }}}
        values: |
          cert-manager:
            crds:
              enabled: true
    # continueOnError: true  # uncomment for troubleshooting
```

Then, with the `KUBECONFIG` pointing at the **management** cluster, apply the patch to the cluster to
tell it to add this service to the `ClusterDeployment`:

```shell
kubectl patch clusterdeployment ksi-managed-cluster -n kcm-system --type=merge --patch-file clusterdeployment-patch.yaml
```

Wait for the `ClusterDeployment` to be ready:

```shell
kubectl get clusterdeployments -A
```

## Install HCO

Deploying HCO in a {{{ docsVersionInfo.k0rdentName }}} child environment relies on the HCO `ServiceTemplate`, which you can 
install from the {{{ docsVersionInfo.k0rdentName }}} Catalog:

```shell
helm install  hco-service-template oci://registry.mirantis.com/k0rdent-enterprise/hco-service-template --version {{{ docsVersionInfo.addonVersions.dotVersions.hco }}} -n kcm-system
```

Verify that the HCO `ServiceTemplate` has been added and is `VALID`:

```shell
kubectl -n kcm-system get servicetemplate
```
```console
NAME                      VALID
cert-manager-{{{ docsVersionInfo.servicesVersions.dashVersions.certManager }}}       true
dex-{{{ docsVersionInfo.addonVersions.dashVersions.dex }}}                true
external-secrets-{{{ docsVersionInfo.servicesVersions.dashVersions.externalSecrets }}}   true
hco-{{{ docsVersionInfo.addonVersions.dashVersions.hco }}}           true
ingress-nginx-4-11-0      true
ingress-nginx-{{{ docsVersionInfo.servicesVersions.dashVersions.ingressNginx }}}      true
kyverno-{{{ docsVersionInfo.servicesVersions.dashVersions.kyverno }}}             true
velero-{{{ docsVersionInfo.servicesVersions.dashVersions.velero }}}              true
```

The `ServiceTemplate` manifest directs the deployment of HCO using the Helm chart:

```yaml
apiVersion: k0rdent.mirantis.com/v1beta1
kind: ServiceTemplate
metadata:
  name: hco-{{{ docsVersionInfo.addonVersions.dashVersions.hco }}}
  namespace: kcm-system
spec:
  helm:
    chartSpec:
      chart: hco
      interval: 10m0s
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: HelmRepository
        name: kubevirt-repo
      version: {{{ docsVersionInfo.addonVersions.dotVersions.hco }}}
```

By specifying the chart version and the reconcile strategy, this template ensures that HCO remains up to date with minimal manual intervention.

## Steps

To deploy HCO, you will add the relevant templates and changes to the management cluster. These
changes will then affect the relevant child cluster. To install and verify HCO, follow these steps:

1. Add HCO Service Definitions to the `Clusterdeployment`

    Integrate HCO into your existing {{{ docsVersionInfo.k0rdentName}}} child cluster or include it when creating a new `Clusterdeployment` object by updating the `spec.serviceSpec.services` array with the following definition:

    ```yaml
    spec:
      ...
      serviceSpec:
        services:
        - name: hco
          namespace: kubevirt
          template: hco-{{{ docsVersionInfo.addonVersions.dashVersions.hco}}}
      ...
    ```

    This step links the HCO service definition to the {{{ docsVersionInfo.k0rdentName}}} cluster, instructing it to deploy the HCO operator in the `kubevirt` namespace on the child cluster represented by the `ClusterDeployment`.

3. Verify HCO Deployment on the Child Cluster

    To verify the installation, switch your KUBECONFIG context to the {{{ docsVersionInfo.k0rdentName }}} child cluster and verify the HCO deployment. For example, run:

    ```bash
    kubectl -n kubevirt get pods
    ```

    Wait until the pod named `hyperconverged-cluster-operator-xxxxxxxxxx-xxxxx` is in the `Ready` state. 

    Monitoring pod status on the child cluster is critical to ensure that the operator is running and ready to manage virtualization components.

4. Apply the HCO Custom Resource (CR)

    Once the HCO operator is ready, apply the HCO `CustomResource` to the child cluster to activate Mirantis k0rdent Virtualization and its subcomponents (such as network and storage plugins):

    ```yaml
    apiVersion: hco.kubevirt.io/v1beta1
    kind: HyperConverged
    metadata:
      name: kubevirt-hyperconverged
      namespace: kubevirt
    spec:
      featureGates:
        downwardMetrics: true
      infra:
        nodePlacement:
          nodeSelector:
            kubernetes.io/os: linux
      platform: k0s
    ```

    Applying the HCO CR is the final step that triggers the deployment of all virtualization components, ensuring that your cluster is fully equipped to handle VM workloads.

## Known Issue

# Create DataVolume Error

You may experience a problem in which the DataVolume cannot be created with the specified data source. If so, the cause is a failure in the importer image, due to the following error:

```console
blockdev: cannot open /dev/cdi-block-volume: Permission denied
```

For more information on this problem, see the [CDI project documentation](https://github.com/kubevirt/containerized-data-importer/blob/main/doc/block_cri_ownership_config.md).