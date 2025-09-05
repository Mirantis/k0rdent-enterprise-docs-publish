# Custom CAPI provider template creation in the airgapped environment

Sometimes it's required to use CAPI provider that is not part of official
{{{ docsVersionInfo.k0rdentName }}} release in the airgapped environment.

For general process regarding BYO templates you can follow [Bring Your Own templates guide](../reference/template/template-byo.md).

This is more in-depth guide regarding custom provider template creation with
airgapped environment specifics.

## Process overview

Implementing your own custom provider template typically involves the following
steps:

- Helm chart creation
- Providing dependencies
- Creation of k0rdent specific objects

This guide will use vsphere infrastructure provider as a concrete example, even
though it's included in the default {{{ docsVersionInfo.k0rdentName }}}
installation.

### Helm chart creation

Helm chart can contain the provider resources directly or use CAPI Operator
objects. It is a convention in {{{ docsVersionInfo.k0rdentName }}} to use CAPI
Operator resources for ease of maintenance and more concise definitions.

#### Chart.yaml and values conventions

For provider templates `global.registry` value is used by the system to pass
global custom registry configuration, it's expected that all templates support
it.

> EXAMPLE: Infrastructure provider definition
> ```yaml
> {{- $global := .Values.global | default dict }}
> {{- $version := .Chart.AppVersion }}
> apiVersion: operator.cluster.x-k8s.io/v1alpha2
> kind: InfrastructureProvider
> metadata:
>   name: vsphere
> spec:
>   version: {{ $version }}
>   fetchConfig:
>     oci: {{ $global.registry }}/capi/cluster-api-provider-vsphere-components:{{ $version }}
>   deployment:
>     containers:
>       - name: manager
>         imageUrl: {{ $global.registry }}/capi/cluster-api-vsphere-controller:{{ $version }}
> ```

`Chart.yaml` must include annotations for [Compatibility Attributes](../reference/template/template-byo.md#compatibility-attributes)

> EXAMPLE: `Chart.yaml` definition
> ```yaml
> apiVersion: v2
> name: cluster-api-provider-vsphere
> description: A Helm chart for Cluster API provider vSphere
> type: application
> version: 1.0.0
> appVersion: "v1.13.0"
> annotations:
>   cluster.x-k8s.io/provider: infrastructure-vsphere
>   cluster.x-k8s.io/v1beta1: v1beta1
> ```

After chart is created it should be packaged using:

```bash
helm package cluster-api-provider-vsphere
```

The resulting file `cluster-api-provider-vsphere-1.0.0.tgz` should be transferred
to the airgapped environment.

After transferred it should be uploaded to the registry where all the rest of
artifacts are uploaded (e.g. `registry.local/k0rdent-enterprise`):

```bash
export REGISTRY="registry.local/k0rdent-enterprise"
helm push cluster-api-provider-vsphere-1.0.0.tgz oci://${REGISTRY}/charts
```

### Providing dependencies

To install provider in the airgapped environment its dependencies must be also
present in the environment. In our case it's a vsphere controller image and CAPI
Provider components.

The controller image can be copied in any convenient way, the CAPI components
require a separate process which is explained in the following section.

#### Preparing CAPI components image

The CAPI Operator expects provider's components in [several places](https://cluster-api-operator.sigs.k8s.io/03_topics/02_configuration/01_air-gapped-environtment)
but the OCI images are used conventionally in {{{ docsVersionInfo.k0rdentName }}}.

To prepare the image you must download provider components (such as
`infrastructure-components.yaml`) and `metadata.yaml`. You can download these
from official provider release page.

After downloaded these files must be transferred to the airgapped environment,
where they could be uploaded to the registry using `oras`.

> NOTE:
> In the following example we have directory `vsphere-components` which contains
> only `infrastructure-components.yaml` and `metadata.yaml` which were
> downloaded from [vsphere provider releases page](https://github.com/kubernetes-sigs/cluster-api-provider-vsphere/releases)
> Also note that path matches the one defined in the chart.

```bash
cd vsphere-components
oras push ${REGISTRY}/capi/cluster-api-provider-vsphere-components:v1.13.0 *
```


### Creation k0rdent-specific objects

Several k0rdent objects must be edited/created before custom provider template
can be used.

#### Provider template

When all charts and components are uploaded `ProviderTemplate` object must be
created:

```yaml
apiVersion: k0rdent.mirantis.com/v1beta1
kind: ProviderTemplate
metadata:
  name: cluster-api-provider-vsphere-1-0-0
  namespace: kcm-system
spec:
  helm:
    chartSpec:
      chart: cluster-api-provider-vsphere
      interval: 10m0s
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: HelmRepository
        name: kcm-templates
      version: 1.0.0
```

After the above object is applied check that it is valid:

```console
kubectl -n kcm-system get providertemplate cluster-api-provider-vsphere-1-0-0
NAME                                 VALID
cluster-api-provider-vsphere-1-0-0   true
```

#### Management

When template is ready the `Management` object must be edited to specify that
custom provider template must be used instead the one that defined in the
`Release`. To do so edit the `Management` object using

```bash
kubectl edit mgmt kcm
```

Then under `.spec.providers` edit the provider you want to use custom template
for and add the template name there:

```yaml
apiVersion: k0rdent.mirantis.com/v1beta1
kind: Management
metadata:
  name: kcm
spec:
  providers:
  - name: cluster-api-provider-vsphere
    template: cluster-api-provider-vsphere-1-0-0
```

After that check that `Management` transitioned to Ready status:

```console
kubectl get mgmt
NAME   READY   RELEASE                    AGE
kcm    True    k0rdent-enterprise-1-1-0   53m
```
