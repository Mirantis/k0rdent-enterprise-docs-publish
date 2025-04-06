# Operations

Some operations require extra prerequisites and have limitations. 

## Salesforce Notifier

The Salesforce notification system alerts users to important updates, assigned tasks, approval requests, mentions, and other relevant activities within the platform. These alerts are typically delivered via the bell icon in the desktop interface or as push notifications on the Salesforce mobile app, helping users stay informed and take timely action.

Integrating StackLight with Salesforce's notification system typically involves configuring StackLight alerts (from Prometheus/Alertmanager) to trigger webhooks, which can then use the Salesforce API (potentially via middleware) to create custom notifications, Chatter posts, or Cases, ensuring critical cloud infrastructure issues are visible to relevant teams within their Salesforce environment.

To do that, create a `Secret` (`salesforce-credentials` in this example) in the selected namespace (`stacklight` in this example) before enabling the Salesforce Notifier, then use the `Secret` name as the value for the `salesforceNotifier.credentialsSecretName` parameter:

```shell
kubectl -n stacklight create secret generic salesforce-credentials \
    --from-literal=SFDC_AUTH_URL="SFDC_AUTH_URL" \
    --from-literal=SFDC_USERNAME="SFDC_USERNAME" \
    --from-literal=SFDC_PASSWORD="SFDC_PASSWORD" \
    --from-literal=SFDC_ORGANIZATION_ID="SFDC_ORGANIZATION_ID" \
    --from-literal=SFDC_ENVIRONMENT_ID="SFDC_ENVIRONMENT_ID"
```
  
Don't forget to substitute in your actual values!

> NOTE:
> - Enabling the Salesforce Notifier causes duplicate metrics to be generated. This is not a problem, but be aware that it will cause Prometheus'  `PrometheusTargetScrapesDuplicate` alert to fire constantly, so you'll want to configure the alert accordingly. 

## StackLight Deinstallation

Removing the `StackLight` `CustomResource` doesn't remove everything installed in the cluster.  Remaining objects, which 
exist in both the namespace and cluster-wide, need to be removed manually, particularly if you are going to re-install StackLight.
These objects include:

### Cluster-wide

-   `clusterrole.rbac.authorization.k8s.io/stacklight-fluentd`
-   `clusterrole.rbac.authorization.k8s.io/stacklight-kube-state-metrics`
-   `clusterrole.rbac.authorization.k8s.io/stacklight-prometheus`
-   `clusterrolebinding.rbac.authorization.k8s.io/stacklight-fluentd`
-   `clusterrolebinding.rbac.authorization.k8s.io/stacklight-kube-state-metrics`
-   `clusterrolebinding.rbac.authorization.k8s.io/stacklight-prometheus`

### Namespace-local

-   `persistentvolumeclaim/data-alertmanager-0`
-   `persistentvolumeclaim/data-alertmanager-1`
-   `persistentvolumeclaim/data-volume-opensearch-0`
-   `persistentvolumeclaim/data-volume-opensearch-1`
-   `persistentvolumeclaim/data-volume-opensearch-2`
-   `persistentvolumeclaim/data-volume-prometheus-0`
-   `persistentvolumeclaim/data-volume-prometheus-1`
-   `persistentvolumeclaim/data-volume-spilo-0`
-   `persistentvolumeclaim/data-volume-spilo-1`
-   `persistentvolumeclaim/data-volume-spilo-2`
-   `service/spilo-config`
-   `endpoints/spilo-config`
-   `endpoints/spilo-sync`
    