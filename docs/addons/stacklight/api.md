# API Reference

> Note:
> You can find the complete API reference in the `docs/CRD_DESCRIPTION.md` file in the chart package, accessible by using:
>    ```shell
>    helm pull https://binary.mirantis.com/stacklight/helm/stacklight-operator-{{{ docsVersionInfo.addonVersions.dotVersions.stacklightChart }}}.tgz --untar
>    ```
  

## Packages:

- monitoring.mirantis.com/v1alpha1

## Resource Types:

- [StackLight](#stacklight)

## StackLight
<sup><sup>[↩ Parent](#packages)</sup></sup>

`StackLight` is the Schema for the StackLight API.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
      <td><b>apiVersion</b></td>
      <td>string</td>
      <td>monitoring.mirantis.com/v1alpha1</td>
      <td>true</td>
      </tr>
      <tr>
      <td><b>kind</b></td>
      <td>string</td>
      <td>StackLight</td>
      <td>true</td>
      </tr>
      <tr>
      <td><b><a href="https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.27/#objectmeta-v1-meta">metadata</a></b></td>
      <td>object</td>
      <td>Refer to the Kubernetes API documentation for the fields of the `metadata` field.</td>
      <td>true</td>
      </tr><tr>
        <td><b><a href="#stacklightspec">spec</a></b></td>
        <td>object</td>
        <td>
          StackLightSpec defines the desired state of StackLight<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatus">status</a></b></td>
        <td>object</td>
        <td>
          StackLightStatus defines the observed state of StackLight<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec
<sup><sup>[↩ Parent](#stacklight)</sup></sup>



`StackLightSpec` defines the desired state of the `StackLight` object.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecalerta">alerta</a></b></td>
        <td>object</td>
        <td>
          Alerta definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecalertmanager">alertmanager</a></b></td>
        <td>object</td>
        <td>
          Alertmanager definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecblackboxexporter">blackboxExporter</a></b></td>
        <td>object</td>
        <td>
          Blackbox Exporter definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeccadvisor">cadvisor</a></b></td>
        <td>object</td>
        <td>
          cAdvisor definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeccurator">curator</a></b></td>
        <td>object</td>
        <td>
          curator definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>exposeLoadBalancers</b></td>
        <td>boolean</td>
        <td>
          This parameter enables the creation of LoadBalancer services for multiple components,
allowing external access to these components. This setting exposes the services on external IPs.
The following services are exposed:<br />
- alerta<br />
- alertmanager<br />
- grafana<br />
- opensearch-dashboards<br />
- prometheus<br />
WARNING: This option is unsafe as it does not provide any form of authentication or authorization,
making the exposed components accessible to anyone with network access to the service. It is recommended
that you use this setting only in controlled environments or behind an external authentication layer.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecfluentd">fluentd</a></b></td>
        <td>object</td>
        <td>
          Fluentd definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecgrafana">grafana</a></b></td>
        <td>object</td>
        <td>
          Grafana definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>highAvailabilityEnabled</b></td>
        <td>boolean</td>
        <td>
          This parameter controls whether the StackLight is deployed in High Availability (HA) mode
or Non-HA mode. In HA mode, a minimum of 3 nodes is required for StackLight pods.
The differences between HA and Non-HA modes are as follows:<br />
- Alerta: 2 replicas in HA mode (1 replica in Non-HA mode)<br />
- Kube State Metrics: 2 replicas in HA mode (1 replica in Non-HA mode)<br />
- Prometheus: 2 replicas in HA mode (1 replica in Non-HA mode)<br />
- Alertmanager: 2 replicas in HA mode (1 replica in Non-HA mode)<br />
- Spilo: 3 replicas in HA mode (1 replica in Non-HA mode)<br />
- Prometheus Relay: 2 replicas in HA mode (1 replica in Non-HA mode)<br />
- OpenSearch: 3 replicas in HA mode (1 replica in Non-HA mode)<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeckubestatemetrics">kubeStateMetrics</a></b></td>
        <td>object</td>
        <td>
          Kube State Metrics definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeckubernetes">kubernetes</a></b></td>
        <td>object</td>
        <td>
          Parameters specific to the Kubernetes cluster, such as distribution, and other configuration details.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>kubevirtMonitoringEnabled</b></td>
        <td>boolean</td>
        <td>
          Enables or disables monitoring for KubeVirt virtual machines and related components.
Defaults to false.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecnodeexporter">nodeExporter</a></b></td>
        <td>object</td>
        <td>
          Node Exporter definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecopensearch">opensearch</a></b></td>
        <td>object</td>
        <td>
          OpenSearch definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecopensearchdashboards">opensearchDashboards</a></b></td>
        <td>object</td>
        <td>
          OpenSearch Dashboards definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecprometheus">prometheus</a></b></td>
        <td>object</td>
        <td>
          Prometheus definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecprometheusrelay">prometheusRelay</a></b></td>
        <td>object</td>
        <td>
          Prometheus Relay definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>registry</b></td>
        <td>string</td>
        <td>
          The base container registry URL used for all images in StackLight.
This parameter allows you to specify a default registry that will be prepended
to each image's repository. If omitted, a default registry will be used.
Defaults to "mirantis.azurecr.io".<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecsalesforcenotifier">salesforceNotifier</a></b></td>
        <td>object</td>
        <td>
          Salesforce Notifier definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecspilo">spilo</a></b></td>
        <td>object</td>
        <td>
          Spilo definition.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>storageClassName</b></td>
        <td>string</td>
        <td>
          What StorageClass will be used for all StackLight PVCs.
Components can override this by setting their own storageClassName parameter.
If nothing is set, the default StorageClass is used (if it is defined).<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.alerta
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>



Alerta definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Alerta pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecalertaresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the alerta container.
Default values:<br />
- requests.cpu: 50m<br />
- requests.memory: 150Mi<br />
- limits.cpu: -<br />
- limits.memory: 500Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecalertatolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Alerta pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.alerta.resources
<sup><sup>[↩ Parent](#stacklightspecalerta)</sup></sup>



Define resource requests and limits for the alerta container.
Default values:<br />
- requests.cpu: 50m<br />
- requests.memory: 150Mi<br />
- limits.cpu: -<br />
- limits.memory: 500Mi<br />

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecalertaresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.alerta.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecalertaresources)</sup></sup>



`ResourceClaim` references one entry in `PodSpec.ResourceClaims.`

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.alerta.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecalerta)</sup></sup>



The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.alertmanager
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>



Alertmanager definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>extraReceivers</b></td>
        <td>string</td>
        <td>
          Provides the ability to add additional notification receivers to the Alertmanager.
These custom receivers are merged with the default receivers defined by StackLight.
Use this parameter to specify additional receivers that are not included in the default configuration.
The receivers must be provided in a valid YAML list format, following Alertmanager's configuration file syntax.
Example of a sample receiver:<br />

<pre>extraReceivers: |
  - name: sample-slack
    slackConfigs:
    - apiUrl: https://hooks.slack.com/services/...
      channel: "#sample"
      sendResolved: true</pre>


WARNING: Ensure that the notification receivers are valid and properly formatted to avoid configuration issues.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>extraRoutes</b></td>
        <td>string</td>
        <td>
          Provides the ability to add additional notification routes to the Alertmanager.
These custom routes are merged with the default routes defined by StackLight.
Use this parameter to specify additional routes that are not included in the default configuration.
The routes must be provided in a valid YAML list format, following Alertmanager's configuration file syntax.
Example of a sample route:<br />

<pre>extraRoutes: |
  - receiver: sample-slack
    matchers:
    - severity="critical"
    continue: true</pre>


WARNING: Ensure that the routes are valid and properly formatted to avoid configuration issues.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Alertmanager pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecalertmanagerresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the Alertmanager containers.
Default values:<br />

- requests.cpu: 50m<br />
- requests.memory: 50Mi<br />
- limits.cpu: 200m<br />
- limits.memory: 200Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>storageClassName</b></td>
        <td>string</td>
        <td>
          What StorageClass will be used for Alertmanager PVC(s).
Defaults to the storageClassName parameter value defined at the top level.
If nothing is set, the default StorageClass is used (if it is defined).<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecalertmanagertolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Alertmanager pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.alertmanager.resources
<sup><sup>[↩ Parent](#stacklightspecalertmanager)</sup></sup>

Define resource requests and limits for the Alertmanager containers.
Default values:

- `requests.cpu`: 50m
- `requests.memory`: 50Mi
- `limits.cpu`: 200m
- `limits.memory`: 200Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecalertmanagerresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.alertmanager.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecalertmanagerresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims`.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.alertmanager.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecalertmanager)</sup></sup>



The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.blackboxExporter
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Blackbox Exporter definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Blackbox Exporter pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecblackboxexporterresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the Blackbox Exporter containers.
Default values:<br />

- requests.cpu: 50m<br />
- requests.memory: 50Mi<br />
- limits.cpu: 100m<br />
- limits.memory: 100Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecblackboxexportertolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Blackbox Exporter pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.blackboxExporter.resources
<sup><sup>[↩ Parent](#stacklightspecblackboxexporter)</sup></sup>

Define resource requests and limits for the Blackbox Exporter containers.
Default values:

- `requests.cpu`: 50m
- `requests.memory`: 50Mi
- `limits.cpu`: 100m
- `limits.memory`: 100Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecblackboxexporterresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.blackboxExporter.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecblackboxexporterresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims`.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.blackboxExporter.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecblackboxexporter)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.cadvisor
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

cAdvisor definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the cAdvisor pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeccadvisorresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the cAdvisor containers.
Default values:<br />

- requests.cpu: 100m<br />
- requests.memory: 100Mi<br />
- limits.cpu: 500m<br />
- limits.memory: 500Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeccadvisortolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          cAdvisor pod's tolerations.
By default the following taints are tolerated:<br />

- node-role.kubernetes.io/control-plane:NoSchedule<br />
- node-role.kubernetes.io/master:NoSchedule<br />
- com.docker.ucp.manager:NoSchedule<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.cadvisor.resources
<sup><sup>[↩ Parent](#stacklightspeccadvisor)</sup></sup>

Define resource requests and limits for the cAdvisor containers.
Default values:

- `requests.cpu`: 100m
- `requests.memory`: 100Mi
- `limits.cpu`: 500m
- `limits.memory`: 500Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspeccadvisorresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.cadvisor.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspeccadvisorresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims`.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.cadvisor.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspeccadvisor)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.curator
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

curator definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the curator pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeccuratorresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the curator container.
Default values:

- requests.cpu: 20m<br />
- requests.memory: 100Mi<br />
- limits.cpu: -<br />
- limits.memory: 400Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeccuratortolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          curator pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.curator.resources
<sup><sup>[↩ Parent](#stacklightspeccurator)</sup></sup>

Define resource requests and limits for the curator container.
Default values:

- `requests.cpu`: 20m
- `requests.memory`: 100Mi
- `limits.cpu`: -
- `limits.memory`: 400Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspeccuratorresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.curator.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspeccuratorresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims`.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.curator.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspeccurator)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.fluentd
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Fluentd definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Fluentd pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecfluentdresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the fluentd container.
Default values:<br />

- requests.cpu: 500m<br />
- requests.memory: 200Mi<br />
- limits.cpu: 1000m<br />
- limits.memory: 800Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecfluentdtolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Fluentd pod's tolerations.
By default the following taints are tolerated:<br />

- node-role.kubernetes.io/control-plane:NoSchedule<br />
- node-role.kubernetes.io/master:NoSchedule<br />
- com.docker.ucp.manager:NoSchedule<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.fluentd.resources
<sup><sup>[↩ Parent](#stacklightspecfluentd)</sup></sup>

Define resource requests and limits for the fluentd container.
Default values:

- `requests.cpu`: 500m
- `requests.memory`: 200Mi
- `limits.cpu`: 1000m
- `limits.memory`: 800Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecfluentdresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.fluentd.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecfluentdresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims`.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.fluentd.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecfluentd)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.grafana
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Grafana definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Grafana pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecgrafanaresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the grafana container.
Default values:<br />

- requests.cpu: 50m<br />
- requests.memory: 200Mi<br />
- limits.cpu: -<br />
- limits.memory: 400Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecgrafanatolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Grafana pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.grafana.resources
<sup><sup>[↩ Parent](#stacklightspecgrafana)</sup></sup>

Define resource requests and limits for the grafana container.
Default values:

- `requests.cpu`: 50m
- `requests.memory`: 200Mi
- `limits.cpu`: -
- `limits.memory`: 400Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecgrafanaresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.grafana.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecgrafanaresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims`.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.grafana.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecgrafana)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.kubeStateMetrics
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Kube State Metrics definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Kube State Metrics pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeckubestatemetricsresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the Kube State Metrics containers.
Default values:<br />

- requests.cpu: 50m<br />
- requests.memory: 100Mi<br />
- limits.cpu: -<br />
- limits.memory: 800Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspeckubestatemetricstolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Kube State Metrics pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.kubeStateMetrics.resources
<sup><sup>[↩ Parent](#stacklightspeckubestatemetrics)</sup></sup>

Define resource requests and limits for the Kube State Metrics containers.
Default values:

- `requests.cpu`: 50m
- `requests.memory`: 100Mi
- `limits.cpu`: -
- `limits.memory`: 800Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspeckubestatemetricsresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.kubeStateMetrics.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspeckubestatemetricsresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims`.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.kubeStateMetrics.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspeckubestatemetrics)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.kubernetes
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Parameters specific to the Kubernetes cluster, such as distribution, and other configuration details.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>distribution</b></td>
        <td>enum</td>
        <td>
          This parameter specifies the Kubernetes distribution used in the cluster.
This information allows monitoring components to adapt and apply distribution-specific configurations
or metrics collection methods.
Valid values are:<br />

- "MKE3" for Mirantis Kubernetes Engine v3.7+<br />
- "k0s" for k0s
Defaults to MKE3.<br/>
          <br/>
            <i>Enum</i>: MKE3, k0s<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.nodeExporter
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Node Exporter definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>extraCollectors</b></td>
        <td>[]string</td>
        <td>
          Define Node Exporter collectors that have to be enabled in addition to the collectors enabled in StackLight.
Collectors enabled in StackLight out of the box:<br />

- arp<br />
- conntrack<br />
- cpu<br />
- diskstats<br />
- entropy<br />
- filefd<br />
- filesystem<br />
- hwmon<br />
- loadavg<br />
- meminfo<br />
- netclass<br />
- netdev<br />
- netstat<br />
- stat<br />
- sockstat<br />
- textfile<br />
- time<br />
- timex<br />
- uname<br />
- vmstat<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Node Exporter pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>port</b></td>
        <td>integer</td>
        <td>
          Port on which to expose metrics and web interface.
Defaults to 19100.<br/>
          <br/>
            <i>Format</i>: int32<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecnodeexporterresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the Node Exporter containers.
Default values:<br />

- requests.cpu: 50m<br />
- requests.memory: 50Mi<br />
- limits.cpu: -<br />
- limits.memory: 150Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecnodeexportertolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Node Exporter pod's tolerations.
By default the following taints are tolerated:<br />

- node-role.kubernetes.io/control-plane:NoSchedule<br />
- node-role.kubernetes.io/master:NoSchedule<br />
- com.docker.ucp.manager:NoSchedule<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.nodeExporter.resources
<sup><sup>[↩ Parent](#stacklightspecnodeexporter)</sup></sup>

Define resource requests and limits for the Node Exporter containers.
Default values:

- `requests.cpu`: 50m
- `requests.memory`: 50Mi
- `limits.cpu`: -
- `limits.memory`: 150Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecnodeexporterresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.nodeExporter.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecnodeexporterresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims`.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.nodeExporter.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecnodeexporter)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.opensearch
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

OpenSearch definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>editMaxMapCount</b></td>
        <td>boolean</td>
        <td>
          Enables init container that runs "sysctl -w vm.max_map_count=262144"
to satisfy OpenSearch requirements.
It is better have this parameter disabled and preconfigure vm.max_map_count
on the nodes using native kernel parameters modification tools.
Min value of vm.max_map_count for OpenSearch is 262144.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the OpenSearch pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>persistentVolumeClaimSize</b></td>
        <td>string</td>
        <td>
          OpenSearch PersistentVolumeClaim(s) size.
This field is immutable, its value can't be changed once set.
Defaults to 30Gi.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecopensearchresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the OpenSearch containers.
Default values:<br />

- requests.cpu: 500m<br />
- requests.memory: 6Gi<br />
- limits.cpu: 2000m<br />
- limits.memory: 8Gi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>storageClassName</b></td>
        <td>string</td>
        <td>
          What StorageClass will be used for OpenSearch PVC(s).
Defaults to the storageClassName parameter value defined at the top level.
If nothing is set, the default StorageClass is used (if it is defined).<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecopensearchtolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          OpenSearch pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.opensearch.resources
<sup><sup>[↩ Parent](#stacklightspecopensearch)</sup></sup>

Define resource requests and limits for the OpenSearch containers.
Default values:

- `requests.cpu`: 500m
- `requests.memory`: 6Gi
- `limits.cpu`: 2000m
- `limits.memory`: 8Gi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecopensearchresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.opensearch.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecopensearchresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims.`

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.opensearch.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecopensearch)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.opensearchDashboards
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

OpenSearch Dashboards definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the OpenSearch Dashboards pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecopensearchdashboardsresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the OpenSearch Dashboards containers.
Default values:<br />

- requests.cpu: 500m<br />
- requests.memory: 500Mi<br />
- limits.cpu: 1000m<br />
- limits.memory: 1500Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecopensearchdashboardstolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          OpenSearch Dashboards pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.opensearchDashboards.resources
<sup><sup>[↩ Parent](#stacklightspecopensearchdashboards)</sup></sup>

Define resource requests and limits for the OpenSearch Dashboards containers.
Default values:

- `requests.cpu`: 500m
- `requests.memory`: 500Mi
- `limits.cpu`: 1000m
- `limits.memory`: 1500Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecopensearchdashboardsresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.opensearchDashboards.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecopensearchdashboardsresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims.`

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.opensearchDashboards.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecopensearchdashboards)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.prometheus
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Prometheus definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>extraAlertingRules</b></td>
        <td>string</td>
        <td>
          Provides the ability to add additional alerting rules to the Prometheus.
These custom rules are merged with the default alerting rules defined by StackLight.
Use this parameter to specify additional alerts that are not included in the default configuration.
The rules must be provided in a valid YAML list format, following Prometheus' alerting rule syntax.
Example of a sample alerting rule:

<pre>extraAlertingRules: |
  - alert: SampleAlert
    expr: sample_metric > 100
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "Sample alert triggered"
      description: "The sample_metric has exceeded the threshold for more than 10 minutes."</pre>


WARNING: Ensure that the alerting rules are valid and properly formatted to avoid configuration issues.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>extraScrapeConfigs</b></td>
        <td>string</td>
        <td>
          Provides the ability to add additional scrape configurations to the Prometheus.
These configurations are merged with the default scrape configurations defined by StackLight.
Use this parameter to specify custom targets for scraping metrics that are not covered by the default settings.
The scrape configurations must be provided in a valid YAML list format, following Prometheus' scrape
configuration syntax.
Example of a sample scrape configuration:

<pre>extraScrapeConfigs: |
  - job_name: 'sample-scrape-job'
    static_configs:
    - targets: ['localhost:9090']</pre>


WARNING: Ensure that the scrape configurations are valid and properly formatted to avoid configuration issues.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>globalExternalLabels</b></td>
        <td>map[string]string</td>
        <td>
          Labels to add to any time series or alerts when communicating with external systems (such as
federation, remote storage, or Alertmanager).
WARNING: Ensure that the label names are unique enough to avoid conflicts or intersections with labels
that already exist in metrics and alerts, as overlapping labels can lead to unexpected behavior
in metrics aggregation and alert routing.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Prometheus pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>persistentVolumeClaimSize</b></td>
        <td>string</td>
        <td>
          Prometheus PersistentVolumeClaim(s) size.
This field is immutable, its value can't be changed once set.
Defaults to 15Gi.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecprometheusresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the Prometheus containers.
Default values:<br />

- requests.cpu: 500m<br />
- requests.memory: 2Gi<br />
- limits.cpu: 1000m<br />
- limits.memory: 8Gi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>retentionSize</b></td>
        <td>string</td>
        <td>
          The maximum number of bytes of storage blocks to retain.
The value is passed to the --storage.tsdb.retention.size flag.
Defaults to 14GB.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>retentionTime</b></td>
        <td>string</td>
        <td>
          How long to retain samples in storage.
The value is passed to the --storage.tsdb.retention.time flag.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>storageClassName</b></td>
        <td>string</td>
        <td>
          What StorageClass will be used for Prometheus PVC(s).
Defaults to the storageClassName parameter value defined at the top level.
If nothing is set, the default StorageClass is used (if it is defined).<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecprometheustolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Prometheus pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.prometheus.resources
<sup><sup>[↩ Parent](#stacklightspecprometheus)</sup></sup>

Define resource requests and limits for the Prometheus containers.
Default values:

- `requests.cpu`: 500m
- `requests.memory`: 2Gi
- `limits.cpu`: 1000m
- `limits.memory`: 8Gi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecprometheusresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.prometheus.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecprometheusresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims.`

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.prometheus.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecprometheus)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.prometheusRelay
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Prometheus Relay definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Prometheus Relay pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecprometheusrelayresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the Prometheus Relay container.
Default values:<br />

- requests.cpu: 50m<br />
- requests.memory: 100Mi<br />
- limits.cpu: 200m<br />
- limits.memory: 500Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecprometheusrelaytolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Prometheus Relay pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.prometheusRelay.resources
<sup><sup>[↩ Parent](#stacklightspecprometheusrelay)</sup></sup>

Define resource requests and limits for the Prometheus Relay container.
Default values:

- `requests.cpu`: 50m
- `requests.memory`: 100Mi
- `limits.cpu`: 200m
- `limits.memory`: 500Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecprometheusrelayresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.prometheusRelay.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecprometheusrelayresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims.`

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.prometheusRelay.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecprometheusrelay)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.salesforceNotifier
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Salesforce Notifier definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>credentialsSecretName</b></td>
        <td>string</td>
        <td>
          Specifies the name of the Kubernetes Secret that contains the Salesforce authentication details,
such as the authentication URL, username, password, organization ID, and environment ID.
The Secret must be in the same namespace as the custom resource.
Ensure the Secret is created and populated with valid credentials before enabling the Salesforce Notifier.
The Secret's data must contain the following keys with corresponding values:<br />

- SFDC_AUTH_URL<br />
- SFDC_USERNAME<br />
- SFDC_PASSWORD<br />
- SFDC_ORGANIZATION_ID<br />
- SFDC_ENVIRONMENT_ID<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>enabled</b></td>
        <td>boolean</td>
        <td>
          Controls whether the Salesforce Notifier is enabled or disabled. Defaults to false.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Salesforce Notifier pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecsalesforcenotifierresources">resources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the Salesforce Notifier containers.
Default values:

- requests.cpu: 600m<br />
- requests.memory: 300Mi<br />
- limits.cpu: 1200m<br />
- limits.memory: 600Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecsalesforcenotifiertolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Salesforce Notifier pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.salesforceNotifier.resources
<sup><sup>[↩ Parent](#stacklightspecsalesforcenotifier)</sup></sup>

Define resource requests and limits for the Salesforce Notifier containers.
Default values:

- `requests.cpu`: 600m
- `requests.memory`: 300Mi
- `limits.cpu`: 1200m
- `limits.memory`: 600Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecsalesforcenotifierresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.salesforceNotifier.resources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecsalesforcenotifierresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims.`

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.salesforceNotifier.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecsalesforcenotifier)</sup></sup>



The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.spilo
<sup><sup>[↩ Parent](#stacklightspec)</sup></sup>

Spilo definition.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>nodeSelector</b></td>
        <td>map[string]string</td>
        <td>
          Define which nodes the Spilo pods are scheduled on.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecspilopatroniexporterresources">patroniExporterResources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the patroni-exporter container.
Default values:<br />

- requests.cpu: 100m<br />
- requests.memory: 40Mi<br />
- limits.cpu: 150m<br />
- limits.memory: 80Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecspilopostgresexporterresources">postgresExporterResources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the postgres-exporter container.
Default values:<br />

- requests.cpu: 150m<br />
- requests.memory: 40Mi<br />
- limits.cpu: 450m<br />
- limits.memory: 80Mi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecspilospiloresources">spiloResources</a></b></td>
        <td>object</td>
        <td>
          Define resource requests and limits for the spilo container.
Default values:<br />

- requests.cpu: 300m<br />
- requests.memory: 300Mi<br />
- limits.cpu: 600m<br />
- limits.memory: 2Gi<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>storageClassName</b></td>
        <td>string</td>
        <td>
          What StorageClass will be used for Spilo PVC(s).
Defaults to the storageClassName parameter value defined at the top level.
If nothing is set, the default StorageClass is used (if it is defined).<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightspecspilotolerationsindex">tolerations</a></b></td>
        <td>[]object</td>
        <td>
          Spilo pod's tolerations.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.spilo.patroniExporterResources
<sup><sup>[↩ Parent](#stacklightspecspilo)</sup></sup>

Define resource requests and limits for the patroni-exporter container.
Default values:

- `requests.cpu`: 100m
- `requests.memory`: 40Mi
- `limits.cpu`: 150m
- `limits.memory`: 80Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecspilopatroniexporterresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.spilo.patroniExporterResources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecspilopatroniexporterresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims.`

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.spilo.postgresExporterResources
<sup><sup>[↩ Parent](#stacklightspecspilo)</sup></sup>

Define resource requests and limits for the postgres-exporter container.
Default values:

- `requests.cpu`: 150m
- `requests.memory`: 40Mi
- `limits.cpu`: 450m
- `limits.memory`: 80Mi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecspilopostgresexporterresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.spilo.postgresExporterResources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecspilopostgresexporterresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims.`

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.spilo.spiloResources
<sup><sup>[↩ Parent](#stacklightspecspilo)</sup></sup>

Define resource requests and limits for the spilo container.
Default values:

- `requests.cpu`: 300m
- `requests.memory`: 300Mi
- `limits.cpu`: 600m
- `limits.memory`: 2Gi

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightspecspilospiloresourcesclaimsindex">claims</a></b></td>
        <td>[]object</td>
        <td>
          Claims lists the names of resources, defined in spec.resourceClaims,
that are used by this container.


This is an alpha field and requires enabling the
DynamicResourceAllocation feature gate.


This field is immutable. It can only be set for containers.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>limits</b></td>
        <td>map[string]int or string</td>
        <td>
          Limits describes the maximum amount of compute resources allowed.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>requests</b></td>
        <td>map[string]int or string</td>
        <td>
          Requests describes the minimum amount of compute resources required.
If Requests is omitted for a container, it defaults to Limits if that is explicitly specified,
otherwise to an implementation-defined value. Requests cannot exceed Limits.
More info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.spec.spilo.spiloResources.claims[index]
<sup><sup>[↩ Parent](#stacklightspecspilospiloresources)</sup></sup>

`ResourceClaim` references one entry in `PodSpec.ResourceClaims.`

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>name</b></td>
        <td>string</td>
        <td>
          Name must match the name of one entry in pod.spec.resourceClaims of
the Pod where this field is used. It makes that resource available
inside a container.<br/>
        </td>
        <td>true</td>
      </tr></tbody>
</table>


### StackLight.spec.spilo.tolerations[index]
<sup><sup>[↩ Parent](#stacklightspecspilo)</sup></sup>

The pod this `Toleration` is attached to tolerates any taint that matches
the triple <key,value,effect> using the matching operator <operator>.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>effect</b></td>
        <td>string</td>
        <td>
          Effect indicates the taint effect to match. Empty means match all taint effects.
When specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>key</b></td>
        <td>string</td>
        <td>
          Key is the taint key that the toleration applies to. Empty means match all taint keys.
If the key is empty, operator must be Exists; this combination means to match all values and all keys.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>operator</b></td>
        <td>string</td>
        <td>
          Operator represents a key's relationship to the value.
Valid operators are Exists and Equal. Defaults to Equal.
Exists is equivalent to wildcard for value, so that a pod can
tolerate all taints of a particular category.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>tolerationSeconds</b></td>
        <td>integer</td>
        <td>
          TolerationSeconds represents the period of time the toleration (which must be
of effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,
it is not set, which means tolerate the taint forever (do not evict). Zero and
negative values will be treated as 0 (evict immediately) by the system.<br/>
          <br/>
            <i>Format</i>: int64<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b>value</b></td>
        <td>string</td>
        <td>
          Value is the taint value the toleration matches to.
If the operator is Exists, the value should be empty, otherwise just a regular string.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status
<sup><sup>[↩ Parent](#stacklight)</sup></sup>

StackLightStatus defines the observed state of StackLight

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b><a href="#stacklightstatusalerta">alerta</a></b></td>
        <td>object</td>
        <td>
          Alerta status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusalertmanager">alertmanager</a></b></td>
        <td>object</td>
        <td>
          Alertmanager status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusblackboxexporter">blackboxExporter</a></b></td>
        <td>object</td>
        <td>
          Blackbox Exporter status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatuscadvisor">cadvisor</a></b></td>
        <td>object</td>
        <td>
          cAdvisor status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatuscurator">curator</a></b></td>
        <td>object</td>
        <td>
          curator status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusfluentd">fluentd</a></b></td>
        <td>object</td>
        <td>
          Fluentd status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusgrafana">grafana</a></b></td>
        <td>object</td>
        <td>
          Grafana status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatuskubestatemetrics">kubeStateMetrics</a></b></td>
        <td>object</td>
        <td>
          Kube State Metrics status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusnodeexporter">nodeExporter</a></b></td>
        <td>object</td>
        <td>
          Node Exporter status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusopensearch">opensearch</a></b></td>
        <td>object</td>
        <td>
          OpenSearch status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusopensearchdashboards">opensearchDashboards</a></b></td>
        <td>object</td>
        <td>
          OpenSearch Dashboards status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusprometheus">prometheus</a></b></td>
        <td>object</td>
        <td>
          Prometheus status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusprometheusrelay">prometheusRelay</a></b></td>
        <td>object</td>
        <td>
          Prometheus Relay status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatussalesforcenotifier">salesforceNotifier</a></b></td>
        <td>object</td>
        <td>
          Salesforce Notifier status.<br/>
        </td>
        <td>false</td>
      </tr><tr>
        <td><b><a href="#stacklightstatusspilo">spilo</a></b></td>
        <td>object</td>
        <td>
          Spilo status.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.alerta
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Alerta status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Alerta version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.alertmanager
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Alertmanager status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Alertmanager version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.blackboxExporter
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Blackbox Exporter status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Blackbox Exporter version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.cadvisor
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

cAdvisor status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          cAdvisor version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.curator
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

curator status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          curator version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.fluentd
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Fluentd status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Fluentd version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.grafana
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Grafana status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Grafana version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.kubeStateMetrics
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Kube State Metrics status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Kube State Metrics version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.nodeExporter
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Node Exporter status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Node Exporter version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.opensearch
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

OpenSearch status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          OpenSearch version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.opensearchDashboards
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

OpenSearch Dashboards status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          OpenSearch Dashboards version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.prometheus
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Prometheus status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Prometheus version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.prometheusRelay
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Prometheus Relay status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Prometheus Relay version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.salesforceNotifier
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Salesforce Notifier status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Salesforce Notifier version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>


### StackLight.status.spilo
<sup><sup>[↩ Parent](#stacklightstatus)</sup></sup>

Spilo status.

<table>
    <thead>
        <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Description</th>
            <th>Required</th>
        </tr>
    </thead>
    <tbody><tr>
        <td><b>version</b></td>
        <td>string</td>
        <td>
          Spilo version.<br/>
        </td>
        <td>false</td>
      </tr></tbody>
</table>
