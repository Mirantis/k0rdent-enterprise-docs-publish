# How-To Deploy HCO on k0rdent Environment

This guide outlines the step-by-step process for deploying the Hyperconverged Cluster Operator (HCO) on a {{{ docsVersionInfo.k0rdentName}}} child cluster. The HCO simplifies the deployment of virtualization components such as KubeVirt, CDI, networking, and kubevirt-manager, providing a unified method to manage virtual machine workloads on Kubernetes.

## Prerequisites

Before proceeding, ensure you have the following in place:

- A deployed k0rdent child cluster.
- The `kubectl` utility installed and configured.
- kubeconfig files for both the KCM (k0rdent Control Manager) and the child clusters.

## Manifests

Deploying HCO in a {{{ docsVersionInfo.k0rdentName }}} child environment relies on two key manifests, which need to be added to the **management** cluster. The first defines the Helm repository, and the second specifies the `ServiceTemplate` used to deploy HCO.

1. Helm Repository Manifest

      This manifest sets up the Helm repository from which the HCO chart will be pulled:

      ```yaml
      apiVersion: source.toolkit.fluxcd.io/v1
      kind: HelmRepository
      metadata:
        labels:
          k0rdent.mirantis.com/managed: 'true'
        name: kubevirt-repo
        namespace: kcm-system
      spec:
        interval: 10m0s
        url: https://binary.mirantis.com/kubevirt/helm/
      ```

      Defining the Helm repository ensures that you always pull the correct version of the HCO chart, and the label indicates that this resource is managed by the k0rdent system.

2. `ServiceTemplate` Manifest

      The `ServiceTemplate` manifest directs the deployment of HCO using the Helm chart:

      ```yaml
      apiVersion: k0rdent.mirantis.com/v1alpha1
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

1. Apply Manifests on the KCM Cluster

    Apply the pre-created manifests (see [Manifests](#manifests), above) to the `kcm-system` namespace on the management cluster. Then verify that the HCO `ServiceTemplate` has been added and is in a `VALID` state by listing the servicetemplate objects, as in:

    ```bash
    $ kubectl -n kcm-system get servicetemplate
    NAME                     VALID
    cert-manager-{{{ docsVersionInfo.servicesVersions.dashVersions.certManager }}}      true
    external-secrets-{{{ docsVersionInfo.servicesVersions.dashVersions.externalSecrets }}}  true
    hco-{{{ docsVersionInfo.addonVersions.dashVersions.hco}}}          true
    ingress-nginx-4-11-0     true
    ingress-nginx-{{{ docsVersionInfo.servicesVersions.dashVersions.ingressNginx }}}     true
    kyverno-{{{ docsVersionInfo.servicesVersions.dashVersions.kyverno }}}            true
    velero-{{{ docsVersionInfo.servicesVersions.dashVersions.velero }}}             true
    ```

2. Add HCO Service Definitions to the `Clusterdeployment`

    Integrate HCO into your existing {{{ docsVersionInfo.k0rdentName}}} child cluster or include it when creating a new `Clusterdeployment` object by updating the `spec.serviceSpec.services` array with the following definition:

    ```yaml
    spec:
      ...
      serviceSpec:
        services:
        - name: hco
          namespace: kubevirt
          template: hco-{{{ docsVersionInfo.addonVersions.dashVersions.hco}}}
          values: |
            admission:
              enabled: false
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

    Once the HCO operator is ready, apply the HCO `CustomResource` to the child cluster to activate KubeVirt and its subcomponents (such as network and storage plugins):

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
      platform: mke4
    ```

    > NOTE: 
    > Currently, you must specify `platform: mke4` in the HCO CR to properly set up the KubeVirt component on a k0rdent environment. This option's value may be renamed in the future.

    Applying the HCO CR is the final step that triggers the deployment of all virtualization components, ensuring that your cluster is fully equipped to handle VM workloads.
