# AddOns

{{{ docsVersionInfo.k0rdentName }}} is composable by design. The open source community around k0rdent has created a host of composable components that can be leveraged by {{{ docsVersionInfo.k0rdentName }}} users -- available through the [k0rdent Catalog](https://catalog.k0rdent.io). Mirantis and partners have also created a growing list of complete functional subsystems for {{{ docsVersionInfo.k0rdentName }}}, available as AddOns.

Several of these AddOns are documented in this section. These include:

* [**Mirantis k0rdent Virtualization (kubevirt)**](mkvirt/index.md) extends Kubernetes to run virtual machine workloads alongside containers. By introducing native resource types for virtual machines, it allows you to manage VMs using the same operational tools and workflows you already use for Kubernetes resources. Features such as live migration and flexible scheduling ensure that virtualized workloads can be maintained with minimal disruption.

* [**Ceph**](ceph/index.md) provides a unified storage solution that supports block, file, and object storage within a single system. It simplifies the management of persistent volumes by automating key processes like data replication and recovery, thereby reducing the manual overhead typically associated with enterprise storage.

* [**StackLight**](stacklight/install.md) delivers comprehensive observability, integrating a suite of powerful open-source tools. It includes Prometheus for monitoring and alerting, Elasticsearch for scalable log aggregation and search, and Grafana and Kibana for rich data visualization. In {{{ docsVersionInfo.k0rdentName }}}, it also provides operators with deep insights into system health, performance metrics, and centralized logging, enabling proactive issue detection, and faster troubleshooting.

Together, these add-ons increase the utility of {{{ docsVersionInfo.k0rdentName }}}, enabling you to tailor your cluster with the additional functionality you need—all while keeping the management process straightforward and consistent.
