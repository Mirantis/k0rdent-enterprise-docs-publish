
# StackLight

Mirantis StackLight LMA is a comprehensive Logging, Monitoring, and Alerting software 
suite designed to provide a unified operational view, or "single pane of glass," for 
managing cloud environments. By leveraging integrated open-source tools such as Prometheus 
for time-series metrics and monitoring, and OpenSearch for log aggregation and analysis, 
StackLight delivers critical insights into the health and performance of the cloud 
infrastructure and its services, supporting effective day-to-day operations and maintenance 
activities. 

This centralized approach significantly speeds up troubleshooting and enables proactive 
identification of potential issues before they impact end-users. Consequently, it enhances 
overall system reliability and simplifies the complexities of cloud management.

In {{{ docsVersionInfo.k0rdentName }}}, StackLight is distributed as Kubernetes Operator--a `CustomResourceDefinition` 
(`stacklights.monitoring.mirantis.com`) and corresponding controller--and is installed as a Helm chart. 
For Mirantis k0rdent Virtualzation (KubeVirt) as part of {{{ docsVersionInfo.k0rdentName }}}, StackLight is distributed as a `ServiceTemplate` object. 

StackLight consists of the following components:

-   **Prometheus:** Provides a time-series database
-   **Prometheus Relay:** Prometheus API High Availability proxy
-   **Grafana:** For timeseries visualization
-   **AlertManager:** Notifications system
-   **Alerta:** Provides alerts visualization
-   **cAdvisor:** Exports metrics
-   **Node Exporter:** OS metrics collector
-   **Blackbox exporter:** Provides endpoint probes
-   **Kube-state-metrics:** K8s objects metrics collector
-   **OpenSearch:** A database for system and audit logs
-   **OpenSearch Dashboards:** Provides logs visualization
-   **Fluentd:** A tool for logs collecting and processing
-   **Spilo:** A High Availability Postgresql solution using Patroni (as a backend for Alerta and Grafana)
