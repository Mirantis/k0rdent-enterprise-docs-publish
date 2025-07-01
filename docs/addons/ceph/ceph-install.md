# Ceph Install

This document describes the Ceph storage reference architecture for Kubernetes clusters and details how to deploy and manage Ceph on clusters deployed and managed with {{{ docsVersionInfo.k0rdentName }}}. Ceph is a distributed storage system that can be deployed on a Kubernetes cluster using OSS Rook. Deploying Ceph with {{{ docsVersionInfo.k0rdentName }}} enables its delivery as a `ServiceTemplate`. Although Ceph is primarily targeted at supporting [Mirantis k0rdent Virtualization (Kubevirt)](../mkvirt/index.md) (i.e., providing storage for virtual machines), it is also well suited for providing persistent block and filesystem storage for any Kubernetes workload. Rook Ceph integrates with Kubernetes as a CSI driver and supports the deployment of StorageClasses based on Ceph RBD (block volumes) and CephFS (filesystem volumes) in both Read-Write-Once and Read-Write-Many modes.

## Prerequisites and Requirements

1. **Deployed, healthy Kubernetes cluster**: In the context of {{{ docsVersionInfo.k0rdentName }}}, this is typically a deployed `ClusterDeployment`.

2. **Networking**  
     Two subnets should be defined and configured for Ceph:
     - **Storage Access Subnet(s):**  
       Provides IP addresses (allocated statically via IPAM) for Ceph nodes. Ceph OSD services bind to these addresses and serve access traffic to and from storage clients. This is considered the public network in Ceph terms.
     - **Storage Replication Subnet(s):**  
       Provides IP addresses for Ceph nodes that are used for internal replication traffic. This is considered the cluster network in Ceph terms.

     For more details, refer to the [Ceph Network Configuration Reference](https://docs.ceph.com/en/latest/rados/configuration/network-config-ref/).

3. **Hardware**  
     Please refer to the official Ceph minimal recommendations for hardware requirements. Note that based on your running applications, the hardware requirements (CPU, RAM, disks) might need to be increased for better performance:  
     - [Minimum Hardware Recommendations](https://docs.ceph.com/en/quincy/start/hardware-recommendations/#minimum-hardware-recommendations)  
     - [Overall Hardware Recommendations](https://docs.ceph.com/en/quincy/start/hardware-recommendations/#hardware-recommendations)

4. **Nodes Count**

     - **Ceph MON Nodes:**  
        These nodes host all control daemons including:
        - **Ceph Monitor:** Stores the health and log information for the cluster.
        - **Ceph Manager:** Provides an endpoint for monitoring, orchestration, and plug-in modules.
        - **Ceph Object Gateway (RGW) Daemon:** Offers a RESTful gateway (S3-compatible or Swift) between applications and the Ceph cluster.
        - **Ceph Metadata Server (MDS):** Manages file metadata when using CephFS.

        A minimum of 3 monitor nodes is required to maintain cluster quorum in production.

     - **Ceph OSD Nodes:**  
        These nodes run data daemons (OSDs) which provide the storage capacity of the cluster. Typically, at least 1 OSD per device is deployed. For NVMe devices, it is recommended to run no more than two OSDs per device. By default, Ceph uses a replication factor of 3. If fewer than 3 Ceph OSD daemons are running, the cluster enters a degraded state with restrictions on write operations until the required number of OSDs is restored. For fault tolerance and recovery operations (such as disk or node replacement), it is advisable to have more than 3 Ceph OSD nodes.

## Ceph Deployment on k0rdent

Deploying Ceph on k0rdent follows these steps:

1. Ceph is installed from the [Ceph docpage](https://catalog.k0rdent.io/v1.0.0/apps/ceph/#install) on k0rdent Enterprise Catalog. Once it's installed, you can add it to child clusters.

3. Edit the `ClusterDeployment` to Enable Ceph.

    Modify the `ClusterDeployment` to enable Ceph as a service:

    ```yaml
    ...
    spec:
      serviceSpec:
        services:
        ...
        - name: ceph
          namespace: ceph-lcm-mirantis
          template: ceph-{{{ docsVersionInfo.addonVersions.dashVersions.ceph }}}
          values: |
            ceph-operator:
              rookExtraConfig:
                csiKubeletPath: /var/lib/k0s/kubelet
              controllers:
                cephMaintenance:
                  enabled: false
              installNamespaces: false
    ```

4. Post-Deployment Steps

    After the Ceph Rook infrastructure is ready, perform the following tasks:

    1. Enable Snapshot Controller for Mirantis k0rdent Virtualization Integration

        According to your environment’s guidelines, update the ClusterDeployment’s `spec.serviceSpec.services[ceph].values` to enable the snapshot-controller. This step should be done after the initial Ceph chart has been deployed.

    2. Configure and Apply MiraCeph

        Create a `MiraCeph` resource to configure the Ceph cluster. Below is a simple example of a minimal `MiraCeph` configuration:

        ```yaml
        apiVersion: lcm.mirantis.com/v1alpha1
        kind: MiraCeph
        metadata:
          name: rook-ceph
          namespace: ceph-lcm-mirantis
        spec:
          rookNamespace: rook-ceph
          dashboard: false
          network:
            publicNet: 10.6.0.0/24
            clusterNet: 10.6.0.0/24
          hyperconverge:
            tolerations:
              mon:
                rules:
                - key: node-role.kubernetes.io/master
                  effect: NoSchedule
                  operator: Exists
              mgr:
                rules:
                - key: node-role.kubernetes.io/master
                  effect: NoSchedule
                  operator: Exists
              mds:
                rules:
                - key: node-role.kubernetes.io/master
                  effect: NoSchedule
                  operator: Exists
              rgw:
                rules:
                - key: node-role.kubernetes.io/master
                  effect: NoSchedule
                  operator: Exists
            services:
            - name: ceph
              namespace: ceph-lcm-mirantis
              template: ceph-1-0-3
              values: |
                global:
                  dockerBaseUrl: docker-dev-kaas-local.docker.mirantis.net
                rookExtraConfig:
                  csiKubeletPath: /var/lib/k0s/kubelet
                controllers:
                  cephMaintenance:
                    enabled: false
                installNamespaces: false
                snapshotController:
                  enabled: true
          nodes:
          - name: pr-k0rdent-env-cp-0
            roles: [ "mon", "mgr", "mds" ]
            monitorIP: <IP address of ceph public iface from the node>
          - name: pr-k0rdent-env-cp-1
            roles: [ "mon", "mgr", "mds" ]
            monitorIP: <IP address of ceph public iface from the node>
          - name: pr-k0rdent-env-cp-2
            roles: [ "mon", "mgr", "mds" ]
            monitorIP: <IP address of ceph public iface from the node>
          - name: pr-k0rdent-env-md-8b7t7-2tnxw
            roles: []
            monitorIP: <IP address of ceph public iface from the node>
            devices:
            - name: vdb
              config:
                deviceClass: hdd
          - name: pr-k0rdent-env-md-8b7t7-nml9d
            roles: []
            devices:
            monitorIP: <IP address of ceph public iface from the node>
            - name: vdb
              config:
                deviceClass: hdd
          - name: pr-k0rdent-env-md-8b7t7-pz46v
            roles: []
            monitorIP: <IP address of ceph public iface from the node>
            devices:
            - name: vdb
              config:
                deviceClass: hdd
          pools:
          - name: block-pool
            useAsFullName: true
            deviceClass: hdd
            default: true
            replicated:
              size: 3
            role: block-pool
          objectStorage:
            rgw:
              name: rgw-store
              dataPool:
                deviceClass: hdd
                replicated:
                  size: 3
              metadataPool:
                deviceClass: hdd
                replicated:
                  size: 3
              gateway:
                allNodes: false
                instances: 3
                port: 8080
                securePort: 8443
              preservePoolsOnDelete: false
          sharedFilesystem:
            cephFS:
            - name: cephfs-store
              dataPools:
              - name: filesystem-pool
                deviceClass: hdd
                replicated:
                  size: 3
              metadataPool:
                deviceClass: hdd
                replicated:
                  size: 3
              metadataServer:
                activeCount: 1
                activeStandby: false
        ```

*References:*  
For further details on network configuration and hardware requirements, please refer to:  
- [Ceph Network Configuration Reference](https://docs.ceph.com/en/latest/rados/configuration/network-config-ref/)  
- [Ceph Hardware Recommendations – Minimum](https://docs.ceph.com/en/quincy/start/hardware-recommendations/#minimum-hardware-recommendations)  
- [Ceph Hardware Recommendations – Overall](https://docs.ceph.com/en/quincy/start/hardware-recommendations/#hardware-recommendations)
