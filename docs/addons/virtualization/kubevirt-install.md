# How-To Deploy HCO on k0rdent Environment

## Prerequisites

- A deployed k0rdent child cluster
- `kubectl` utility
- kubeconfig files for both the KCM and child clusters

## Manifests

HCO deployment on a k0rdent child environment uses two manifests:

### 1. Helm Repository Manifest

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

### 2. Service Template Manifest

```yaml
apiVersion: k0rdent.mirantis.com/v1alpha1
kind: ServiceTemplate
metadata:
  name: hco-1-14-1-mira
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
      version: 1.14.1-mira
```

---

## Steps

1. **Apply Manifests on the KCM Cluster**

   Apply the pre-created manifests (Helm Repository and Service Template) in the `kcm-system` namespace on the KCM cluster. Then verify that the HCO service template is added and in a VALID state. For example, the output should resemble:

   ```bash
   $ kubectl -n kcm-system get servicetemplate
   NAME                     VALID
   cert-manager-1-16-2      true
   dex-0-19-1               true
   external-secrets-0-11-0  true
   hco-1-14-1-mira          true
   ingress-nginx-4-11-0     true
   ingress-nginx-4-11-3     true
   kyverno-3-2-6            true
   velero-8-1-0             true
   ```

2. **Add HCO Service Definitions to the Clusterdeployment**

   HCO can be added to an existing k0rdent child cluster or defined as part of a k0rdent Clusterdeployment object from scratch. The structure of the Clusterdeployment object remains the same in both cases.  
   Add the following HCO service definition to the `spec.serviceSpec.services` array on the KCM cluster:

   ```yaml
   spec:
     ...
     serviceSpec:
       services:
       - name: hco
         namespace: kubevirt
         template: hco-1-14-1-mira
         values: |
           admission:
             enabled: false
     ...
   ```

   This configuration deploys the HCO operator on the k0rdent child cluster.

3. **Verify HCO Deployment on the Child Cluster**

   Next, switch context to the k0rdent child cluster and verify the HCO deployment. For example, run:

   ```bash
   kubectl -n kubevirt get pods
   ```

   Wait until the pod named similar to `hyperconverged-cluster-operator-xxxxxxxxxx-xxxxx` is in the **Ready** state.

4. **Apply the HCO Custom Resource (CR)**

   Once the HCO operator is ready, apply the HCO CR to deploy KubeVirt and its subcomponents (such as network and storage plugins):

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

   > **Note:** Currently, you must specify `platform: mke4` in the HCO CR to properly set up the KubeVirt component on a k0rdent environment. This option’s value may be renamed in the future.
