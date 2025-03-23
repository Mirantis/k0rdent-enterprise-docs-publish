# Ceph: A Unified Storage Solution

Ceph is an open‐source, distributed storage platform that offers unified block, file, and object storage. When run under Kubernetes, it provides scalable, resilient, and self-healing data management using commodity hardware.

In the context of k0rdent, Ceph’s benefits become even clearer. k0rdent simplifies deploying and managing Ceph on your own clusters. This means you can take advantage of dynamic persistent volume provisioning, unified storage for varied workloads, and robust, fault-tolerant data distribution—all without the need for complex manual setup.

By integrating Ceph with k0rdent, you get a straightforward way to manage stateful applications in Kubernetes while ensuring efficient, high-availability storage across your environment.

In {{{ docsVersionInfo.k0rdentName}}}, Ceph is installed on a Kubernetes cluster by creating a `ServiceTemplate` and enabling the service on a `ClusterDeployment` that represents it.
