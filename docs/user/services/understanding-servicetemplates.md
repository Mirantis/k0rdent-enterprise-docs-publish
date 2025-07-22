# Understanding ServiceTemplates

`ServiceTemplate` objects are meant to let {{{ docsVersionInfo.k0rdentName }}} know where to find a Helm chart with instructions for installing
an application. In many cases, these charts will be in a private repository.  For example, consider this template for
installing Nginx Ingress:

```yaml
apiVersion: k0rdent.mirantis.com/v1beta1
kind: ServiceTemplate
metadata:
  name: project-ingress-nginx-4.11.0
  namespace: tenant42
spec:
  helm:
    chartSpec:
      chart: demo-ingress-nginx
      version: 4.11.0
      interval: 10m0s
      sourceRef:
        kind: HelmRepository
        name: k0rdent-demos
---
apiVersion: k0rdent.mirantis.com/v1beta1
kind: ServiceTemplateChain
metadata:
  name: project-ingre`ServiceTemplate` objects are a representation of the source where {{{ docsVersionInfo.k0rdentName }}} can find a resource or set of resources to
be deployed as a complete application.

`ServiceTemplate` supports the following types as a source:

- [`HelmChart`](https://fluxcd.io/flux/components/source/helmcharts/)
- [`GitRepository`](https://fluxcd.io/flux/components/source/gitrepositories/)
- [`Bucket`](https://fluxcd.io/flux/components/source/buckets/)
- [`OCIRepository`](https://fluxcd.io/flux/components/source/ocirepositories/)
- `Secret`
- `ConfigMap`

### Helm-based ServiceTemplate

Helm-based `ServiceTemplate` can be created in two ways:

- by defining Helm chart right in the template object

  ```yaml
  apiVersion: k0rdent.mirantis.com/v1beta1
  kind: ServiceTemplate
  metadata:
    name: foo
    namespace: bar
  spec:
    helm:
      chartSpec:
        chart: ingress-nginx
        version: 4.11.0
        interval: 10m
        sourceRef:
          kind: HelmRepository
          name: foo-repository
  ```
  
  In this case the corresponding `HelmChart` object will be created by the controller.

- by referring the existing Helm chart

  ```yaml
  apiVersion: k0rdent.mirantis.com/v1beta1
  kind: ServiceTemplate
  metadata:
    name: foo
    namespace: bar
  spec:
    helm:
      chartRef:
        kind: HelmChart
        name: foo-chart
  ```

### Kustomize-based ServiceTemplate

Kustomize-based `ServiceTemplate` can be created with either local or remote source:

- by using existing flux source object - `GitRepository`, `Bucket` or `OCIRepository` - or using existing `ConfigMap` or `Secret`

  ```yaml
  apiVersion: k0rdent.mirantis.com/v1beta1
  kind: ServiceTemplate
  metadata:
    name: foo
    namespace: bar
  spec:
    kustomize:
      localSourceRef:
        kind: Bucket  # also can be GitRepository, OCIRepository, ConfigMap or Secret
        name: foo-bar
      deploymentType: Remote
      path: "./base"
  ```

  `ConfigMap` or `Secret` in this case must embed the tar-gzipped archive containing the kustomization files. This can be done by the following command, assuming the the archive was already created:

  ```shell
  kubectl create configmap foo-bar --from-file=/path/to/kustomization/archive.tar.gz
  ```

- by defining remote source right in the template object

  ```yaml
  apiVersion: k0rdent.mirantis.com/v1beta1
  kind: ServiceTemplate
  metadata:
    name: kustomization-app
    namespace: kcm-system
  spec:
    kustomize:
      remoteSourceSpec:
        oci:
          url: oci://ghcr.io/org/project-x
          reference:
            tag: latest
          interval: 10m
      deploymentType: Remote
      path: "./overlays"
  ```

  `.spec.kustomize.remoteSourceSpec` has mutual exclusive fields `.git`, `.bucket` and `.oci` which inline `GitRepositorySpec`, `BucketSpec` and `OCIRepositorySpec` respectively.

### Raw-resources-based ServiceTemplate

Similar to kustomize-based `ServiceTemplate`, raw-resources-based `ServiceTemplate` can be created with either local or remote source. Using the remote source has no difference with
kustomize-based `ServiceTemplate`, however using local source slightly differ in case `ConfigMap` or `Secret` object is referred as a source:

- `spec.resources.localSourceRef.path` will be ignored
- referred `ConfigMap` or `Secret` must contain inlined resources' definitions instead of embedding tar-gzipped archive. 
ss-nginx-4.11.0
  namespace: tenant42
spec:
  supportedTemplates:
    - name: project-ingress-nginx-4.11.0
    - name: project-ingress-nginx-4.10.0
      availableUpgrades:
        - name: project-ingress-nginx-4.11.0
```

Here you see a template called `project-ingress-nginx-4.11.0` that is meant to be deployed in the `tenant42` namespace.
The `.spec.helm.chartSpec` specifies the name of the Helm chart and where to find it, as well as the version and other 
important information. The `ServiceTemplateChain` shows that this template is also an upgrade path from version 4.10.0.

If you wanted to deploy this as an application, you would first go ahead and add the template to the cluster in which you were working, so if you were to save this YAML to a file called `project-ingress.yaml` you could run this command on the management cluster:

```shell
kubectl apply -f project-ingress.yaml -n tenant42
```
