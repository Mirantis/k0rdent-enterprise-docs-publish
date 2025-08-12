# Bare Metal

{{{ docsVersionInfo.k0rdentName }}} can deploy managed clusters on bare metal servers using the Metal3 infrastructure provider. This implementation is based on the bare metal Cluster API Provider, [Metal3 CAPM3](https://github.com/metal3-io), and provides out-of-tree (OOT) bare metal provisioning capabilities. 

CAPM3 works by enabling you to add a representation of each bare metal server as a Kubernetes object. {{{ docsVersionInfo.k0rdentName }}} can then assemble these machine objects into a cluster.

## Structure

The bare metal infrastructure provider is represented as a set of Helm charts. It includes the following charts:

* `baremetal-operator` installs the [Bare Metal Operator](https://github.com/metal3-io/baremetal-operator)
* `capm3-crds` installs the `CustomResourceDefinition` objects for the Metal3 CAPM3 and IPAM components
* `cluster-api-provider-metal3` installs the [Metal3 CAPM3 provider](https://github.com/metal3-io/cluster-api-provider-metal3) and [Metal3 IP Address Manager](https://github.com/metal3-io/ip-address-manager)
* `ironic` installs [OpenStack Ironic](https://github.com/metal3-io/ironic-image) and accompanying components needed for management of bare metal machines:
      MariaDB, keepalived, HTTP server, DHCP server, TFTP server, NTP server, dynamic-IPXE controller, resource controller. 

## Prerequisites

- An installed {{{ docsVersionInfo.k0rdentName }}} management cluster. Follow the instructions in [Install {{{ docsVersionInfo.k0rdentName }}}](../install-k0rdent.md) to create a management cluster with {{{ docsVersionInfo.k0rdentName }}} running. Prepare this cluster according to the [Metal3 host configuration guide](https://book.metal3.io/baremetal/guide#configure-host).
- Supported hardware as documented in the [Metal3 hardware compatibility guide](https://book.metal3.io/bmo/supported_hardware)
- You should still have [Helm](https://helm.sh/docs/intro/install/) installed from your installation of {{{ docsVersionInfo.k0rdentName }}}. If not, install it again.

## Prepare {{{ docsVersionInfo.k0rdentName }}} for Bare Metal clusters

Follow these instructions to make {{{ docsVersionInfo.k0rdentName }}} capable of deploying bare metal clusters:

1. Create the required objects for the OOT CAPM3 provider

    Create the necessary Kubernetes objects to install the out-of-tree CAPM3 provider. Just as with other
    providers, these include a `HelmRepository`, `ProviderTemplate`, and `ClusterTemplate`.

    ```shell
    kubectl create -f - <<EOF
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: HelmRepository
    metadata:
      name: oot-capm3-repo
      namespace: kcm-system
      labels:
        k0rdent.mirantis.com/managed: "true"
    spec:
      type: oci
      url: 'oci://registry.mirantis.com/k0rdent-bm/charts/'
      interval: 10m0s
    ---
    apiVersion: k0rdent.mirantis.com/v1beta1
    kind: ProviderTemplate
    metadata:
      name: cluster-api-provider-metal3-{{{ docsVersionInfo.addonVersions.dashVersions.clusterApiProviderCapm3 }}}
      annotations:
        helm.sh/resource-policy: keep
    spec:
      helm:
        chartSpec:
          chart: cluster-api-provider-metal3
          version: {{{ docsVersionInfo.addonVersions.dotVersions.clusterApiProviderCapm3 }}}
          interval: 10m0s
          sourceRef:
            kind: HelmRepository
            name: oot-capm3-repo
    ---
    apiVersion: k0rdent.mirantis.com/v1beta1
    kind: ClusterTemplate
    metadata:
      annotations:
        helm.sh/resource-policy: keep
      labels:
        k0rdent.mirantis.com/component: kcm
      name: capm3-standalone-cp-{{{ docsVersionInfo.addonVersions.dashVersions.capm3StandaloneCpCluster }}}
      namespace: kcm-system
    spec:
      helm:
        chartSpec:
          chart: capm3-standalone-cp
          version: {{{ docsVersionInfo.addonVersions.dotVersions.capm3StandaloneCpCluster }}}
          interval: 10m0s
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: oot-capm3-repo
    EOF
    ```

2. Verify the `ProviderTemplate` is valid

    Check that the `ProviderTemplate` has been created successfully:

    ```shell
    kubectl get providertemplates cluster-api-provider-metal3-{{{ docsVersionInfo.addonVersions.dashVersions.clusterApiProviderCapm3 }}}
    ```
    ```console
    NAME                              VALID
    cluster-api-provider-metal3-{{{ docsVersionInfo.addonVersions.dashVersions.clusterApiProviderCapm3 }}} true
    ```

3. Configure the `Management` object

    Edit the `Management` object to add the CAPM3 provider configuration:

    ```shell
    kubectl edit managements.k0rdent.mirantis.com
    ```

    Add the following configuration to the `providers` section:

    ```yaml
    - name: cluster-api-provider-metal3
      template: cluster-api-provider-metal3-{{{ docsVersionInfo.addonVersions.dashVersions.clusterApiProviderCapm3 }}}
      config:
        global:
          ironic:
            enabled: true # networking configuration ("ironic.networking" section) should be defined prior to enabling ironic
        ironic:
          networking:
            dhcp: # used by DHCP server to assign IPs to hosts during PXE boot
              rangeBegin: <DHCP_RANGE_START>      # e.g., 10.0.1.51
              rangeEnd: <DHCP_RANGE_END>          # e.g., 10.0.1.55
              netmask: <DHCP_SUBNET_MASK>         # e.g., 255.255.255.192 (default is 255.255.255.0)
              options:                            # DHCP options, used during PXE boot and by IPA
                - "option:router,<ROUTER_IP>"     # e.g., 10.0.1.1. It's a mandatory option. 
                - "option:dns-server,<DNS_IP[,DNS2_IP...]>" # can be set to KEEPALIVED_VIP (dnsmasq can serve as a DNS server with user-defined DNS records) or to IP of your preferred server. Optional.
                - "option:ntp-server,<NTP_IP>"    # can be set to KEEPALIVED_VIP (internal ntp server) or to IP of your preferred server. That ntp server will be used on PXE boot stage then. Optional.
            interface: <PROVISION_INTERFACE>      # e.g., bond0 - interface of the management cluster node connected to BM hosts provision network
            ipAddress: <KEEPALIVED_VIP>          # e.g., 10.0.1.50 - keepalived VIP for DHCP server and Ironic services. This VIP will be configured on the <PROVISION_INTERFACE>, it must be in the same L3 network as DHCP range if no dhcp-relay used between management cluster and child cluster hosts.
        # By default, "ubuntu-noble-hwe-2025-05-15-15-22-56.qcow2" is the only image available.
        # You can define custom OS images here if needed by adding new resources:
        # resources:
        #   images_target:
        #     - name: ubuntu-noble-hwe-2025-05-15-15-22-56.qcow2
        #       url: https://get.mirantis.com/k0rdent-bm/targetimages/ubuntu-noble-hwe-2025-05-15-15-22-56.qcow2
        #       checksum: 581a672e494fcda3297cc8917a91d827157ddcfa3997ad552a914f207b3603c3
    ```

4. Wait for the `Management` object to be ready

    Monitor the `Management` object status:

    ```shell
    kubectl get managements.k0rdent.mirantis.com -w
    ```

    This process usually takes up to 5 minutes. If the `Management` object doesn't become `Ready`, refer to the [Troubleshooting](#troubleshooting) section.

5. Verify the `ClusterTemplate` is valid

    Check that the `ClusterTemplate` has been created successfully:

    ```shell
    kubectl -n kcm-system get clustertemplates capm3-standalone-cp-{{{ docsVersionInfo.addonVersions.dashVersions.capm3StandaloneCpCluster }}}
    ```
    ```console
    NAME                        VALID
    capm3-standalone-cp-{{{ docsVersionInfo.addonVersions.dotVersions.capm3StandaloneCpCluster }}}   true
    ```

6. Optional. Tune the DHCP server.

   > NOTE:
   > Modification of this configuration should be done with special care.
   > It's not recommended to change it during provisioning/deprovisioning of bare metal machines.

   After CAPM3 provider is deployed, you can reconfigure DHCP server.

   1. Using `dnsmasq` object, you can change configuration of the DHCP server and monitor DHCP leases related to your bare metal machines.

      > NOTE:
      > Modification of this configuration requires good knowledge of DHCP basics.

      ```shell
      kubectl -n kcm-system edit dnsmasq
      ```

## Enroll bare metal machines

The next step is to create `BareMetalHost` objects to represent your bare metal machines so {{{ docsVersionInfo.k0rdentName }}} can manage them.
For each bare metal machine, create two objects: a `Secret` and a `BareMetalHost`.
For detailed instructions, see the [Metal3 BareMetalHost enrollment guide](https://book.metal3.io/bmo/introduction.html#enrolling-baremetalhosts) (just `Enrolling`, not `Provisioning`), or follow these instructions.

> NOTE: 
> You don't need to provision bare metal hosts at this stage. Provisioning should happen later as part of a cluster deployment.

1. Create credential `Secret` objects

    You need to provide BMC credentials for every `BareMetalHost` using `Secret` objects. For example:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: <BMH_NAME>-bmc-secret
      namespace: <NAMESPACE>
    type: Opaque
    data:
      username: <BASE64_ENCODED_BMC_USERNAME>
      password: <BASE64_ENCODED_BMC_PASSWORD>
    ```

   > NOTE:
   > `namespace` of all the objects used to describe bare metal machines and corresponding cluster must be equal to
   > the `namespace` of the `ClusterTemplate` object used for deployment of that cluster.

2. Create `BareMetalHost` objects

    A `BareMetalHost` object represents the physical machine. It contains a reference to the `Secret` created above. For example:

    ```yaml
    apiVersion: metal3.io/v1alpha1
    kind: BareMetalHost
    metadata:
      name: <BMH_NAME>
      namespace: <NAMESPACE>
    spec:
      online: true
      bmc:
        address: <BMC_ADDRESS>  # e.g., ipmi://192.168.1.100:623
        credentialsName: <BMH_NAME>-bmc-secret
        #disableCertificateVerification: true # only needed when using redfish protocol
      bootMACAddress: <MAC_ADDRESS> # MAC address that is used for booting. It’s a MAC address of an actual NIC of the host, not the BMC MAC address.
      #bootMode: legacy # UEFI or legacy BIOS. UEFI is the default and should be used unless there are serious reasons not to.
    ```

3. Wait for `BareMetalHost` objects to complete enrollment

    Monitor your `BareMetalHost` objects until they are `available`:

    ```shell
    kubectl get bmh -n <NAMESPACE>
    ```
    ```console
    NAME      STATE       CONSUMER   ONLINE   ERROR   AGE
    child-1   available              true             4d17h
    child-2   available              true             4d17h
    child-3   available              true             4d17h
    ```

    For more information about `BareMetalHost` states, see the [Metal3 state machine documentation](https://book.metal3.io/bmo/state_machine).

### Support for RAID disk arrays on baremetal hosts

The Ironic python agent (IPA) provides limited functionality for software RAID arrays. These limits do not allow  creating a RAID disk as `rootfs`. One limit is the requirement to use a whole block device as a RAID array part. During RAID initialization, IPA creates a single partition on target disks and uses it as part of the RAID array. For example, the RAID array will be assembled not from the raw block device, but from the full disk partition on this block device.

The disk layout looks something like this:

```
disk0 -> part0 -,
disk1 -> part0 -+-> RAID -> [ p0, p1, p2 ... ]
```

So UEFI/BIOS has access only to the "root" partition, and it cannot access the EFI/boot partition defined in the
"nested" partition table--that is, the partition table created inside `part0` (inside the RAID array). So if the RAID array is defined as the [root device](https://book.metal3.io/bmo/root_device_hints), the system will be unbootable.

Consider this example of a `BareMetalHost` object that declares the RAID1 array:

```yaml
---
apiVersion: metal3.io/v1alpha1
kind: BareMetalHost
metadata:
  name: child-master-1
spec:
  bmc:
    address: ipmi://10.0.1.1:6234
    credentialsName: child-master-1.ipmi-auth
  bootMACAddress: 52:54:1f:8b:19:15
  # bootMode: legacy
  online: true
  raid:
    softwareRAIDVolumes:
      - level: "1"
        physicalDisks:
          - deviceName: /dev/disk/by-path/pci-0000:00:07.0-scsi-0:0:0:1
          - deviceName: /dev/disk/by-path/pci-0000:00:07.0-scsi-0:0:0:2
  rootDeviceHints:
    deviceName: /dev/disk/by-path/pci-0000:00:07.0-scsi-0:0:0:0
```

The host has three hard disks. The first one will be used as the root device, and the second and third disks will be assembled into the 
RAID1 array. The `rootDeviceHint` in the `BareMetalHost` `spec` must be defined, because if it has a RAID definition and doesn't have the 
`rootDeviceHint`, the first RAID array will be marked as the root device [automatically](https://github.com/metal3-io/baremetal-operator/blob/v0.9.2/pkg/provisioner/ironic/raid.go#L39).

For more information about software RAID support in IPA, see the [Ironic documentation](https://docs.openstack.org/ironic/latest/admin/raid.html#software-raid).

## Create the cluster

You need to create several objects before {{{ docsVersionInfo.k0rdentName }}} can create a bare metal cluster.

1. Create the credential objects

    Since CAPM3 doesn't require cloud credentials, create dummy `Secret` and `Credential` objects to satisfy `ClusterDeployment` requirements:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: capm3-cluster-secret
      namespace: <NAMESPACE>
      labels:
        k0rdent.mirantis.com/component: "kcm"
    type: Opaque
    ---
    apiVersion: k0rdent.mirantis.com/v1beta1
    kind: Credential
    metadata:
      name: capm3-stub-credential
      namespace: <NAMESPACE>
    spec:
      description: CAPM3 Credentials
      identityRef:
        apiVersion: v1
        kind: Secret
        name: capm3-cluster-secret
        namespace: <NAMESPACE>
    ```

2. Create the `ConfigMap` resource-template

    Create an empty `ConfigMap` resource-template:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: capm3-cluster-credential-resource-template
      namespace: <NAMESPACE>
      labels:
        k0rdent.mirantis.com/component: "kcm"
      annotations:
        projectsveltos.io/template: "true"
    ```

3. Deploy a test cluster

    Create a `ClusterDeployment` template to deploy a cluster using your bare metal machines.
    Start with a `capm3-example.yaml` file. This one creates a cluster with 1 control node and 2 workers:

    ```yaml
    apiVersion: k0rdent.mirantis.com/v1beta1
    kind: ClusterDeployment
    metadata:
      name: capm3-example
      namespace: <NAMESPACE>
    spec:
      template: capm3-standalone-cp-{{{ docsVersionInfo.addonVersions.dashVersions.capm3StandaloneCpCluster }}}
      credential: capm3-stub-credential
      dryRun: false
      config:
        clusterAnnotations: {}
        clusterLabels: {}
        clusterNetwork:
          pods:
            cidrBlocks:
              - 10.243.0.0/16
          services:
            cidrBlocks:
              - 10.95.0.0/16
        controlPlane:
          # the image that was uploaded by default
          checksum: 581a672e494fcda3297cc8917a91d827157ddcfa3997ad552a914f207b3603c3
          image: http://<IRONIC_HTTP_ENDPOINT>:6180/images/ubuntu-noble-hwe-2025-05-15-15-22-56.qcow2
          keepalived:
            authPass: <VRRP_PASSWORD> # optional, from 4 to 8 letters
            enabled: true
            virtualIP: <CLUSTER_API_VIP>/<SUBNET_PREFIX>  # e.g., 10.0.1.70/24. must match k0s.api.externalAddress
          preStartCommands:
            - sudo useradd -G sudo -s /bin/bash -d /home/user1 -p $(openssl passwd -1 myuserpass) user1 # define your user here. it can be used e.g. for debugging.
            - sudo apt update # for Ubuntu
            - sudo apt install jq -y # for Ubuntu
            #- sudo dnf makecache # for RedHat
            #- sudo dnf install jq -y # for RedHat
            # jq is used in K0sControlPlane object to parse cloud-init data that is required for Metal3 provider
          files:
            - path: /home/user1/.ssh/authorized_keys
              permissions: "0644"
              content: "<SSH_PUBLIC_KEY>"
        controlPlaneNumber: 1
        dataTemplate:
          metaData:
            ipAddressesFromIPPool:
              - key: provisioningIP
                name: pool-pxe
            objectNames:
              - key: name
                object: machine
              - key: local-hostname
                object: machine
              - key: local_hostname
                object: machine
            prefixesFromIPPool:
              - key: provisioningCIDR
                name: pool-pxe
          networkData:
            links:
              ethernets:
                - id: <INTERFACE_NAME>  # e.g., ens3
                  type: phy
                  macAddress:
                    fromHostInterface: <INTERFACE_NAME>
            networks:
              ipv4:
                - id: pxe
                  ipAddressFromIPPool: pool-pxe
                  link: <INTERFACE_NAME>
                  routes:
                  - gateway:
                      fromIPPool: pool-pxe
                    network: 0.0.0.0
                    prefix: 0
            services:
              dns:
                - <DNS_SERVER_IP>   # e.g., 8.8.8.8
        ipPools:
          - name: pool-pxe
            pools:
              - end: <IP_POOL_END>      # e.g., 10.0.1.65
                gateway: <GATEWAY_IP>   # e.g., 10.0.1.1
                prefix: <SUBNET_PREFIX> # e.g, "/24"
                start: <IP_POOL_START>  # e.g., 10.0.1.61
        k0s:
          api:
            externalAddress: <CLUSTER_API_VIP>  # e.g., 10.0.1.70
          telemetry:
            enabled: false
          version: v1.32.3+k0s.0
        worker:
          # the image that was uploaded by default
          checksum: 581a672e494fcda3297cc8917a91d827157ddcfa3997ad552a914f207b3603c3
          image: http://<IRONIC_HTTP_ENDPOINT>:6180/images/ubuntu-noble-hwe-2025-05-15-15-22-56.qcow2
          preStartCommands:
            - sudo useradd -G sudo -s /bin/bash -d /home/user1 -p $(openssl passwd -1 myuserpass) user1 # define your user here. it can be used e.g. for debugging.
            - sudo apt update # for Ubuntu
            - sudo apt install jq -y # for Ubuntu
            #- sudo dnf makecache # for RedHat
            #- sudo dnf install jq -y # for RedHat
            # jq is used in K0sControlPlane object to parse cloud-init data that is required for Metal3 provider
          files:
            - path: /home/user1/.ssh/authorized_keys
              permissions: "0644"
              content: "<SSH_PUBLIC_KEY>"
        workersNumber: 2
    ```

    Create a `ClusterDeployment` object on your management cluster from the YAML file:

    ```shell
    kubectl create -f capm3-example.yaml
    ```

4. Monitor the provisioning process

    Watch the `BareMetalHost` objects as they transition through provisioning states:

    ```shell
    kubectl -n <NAMESPACE> get bmh -w
    ```

    You should see the hosts transition from `available` to `provisioning` to `provisioned`:

    ```console
    NAME      STATE         CONSUMER                     ONLINE   ERROR   AGE
    child-1   available                                  true             16m
    child-2   available                                  true             16m
    child-3   available                                  true             16m
    child-2   provisioning  capm3-example-cp-templ-0     true             16m
    child-2   provisioned   capm3-example-cp-templ-0     true             18m
    child-1   provisioning  capm3-example-md-txr9f-k8z9d true             18m
    child-3   provisioning  capm3-example-md-txr9f-lkc5c true             18m
    child-3   provisioned   capm3-example-md-txr9f-lkc5c true             21m
    child-1   provisioned   capm3-example-md-txr9f-k8z9d true             21m
    ```

    Also monitor the `Metal3Machine` objects that are part of the cluster:

    ```shell
    kubectl -n <NAMESPACE> get metal3machine -w
    ```
    ```console
    NAME                           AGE     PROVIDERID                                               READY   CLUSTER        PHASE
    capm3-example-cp-templ-0       5m17s   metal3://kcm-system/child-2/capm3-example-cp-templ-0     true    capm3-example
    capm3-example-md-txr9f-k8z9d   2m40s   metal3://kcm-system/child-1/capm3-example-md-txr9f-k8z9d true    capm3-example
    capm3-example-md-txr9f-lkc5c   2m40s   metal3://kcm-system/child-3/capm3-example-md-txr9f-lkc5c true    capm3-example
    ```

5. Access the deployed cluster

    Once the first control plane machine is ready, retrieve the `KUBECONFIG` for your new cluster:

    ```shell
    kubectl get secret -n <NAMESPACE> capm3-example-kubeconfig -o jsonpath='{.data.value}' | base64 -d > capm3-example-kubeconfig
    KUBECONFIG="capm3-example-kubeconfig" kubectl get pods -A
    ```

6. Cleanup

    To clean up bare metal resources, delete the child cluster by deleting the `ClusterDeployment`:

    ```shell
    kubectl get clusterdeployments -A
    ```
    ```console
    NAMESPACE    NAME            READY   STATUS
    bm-example   capm3-example   True    ClusterDeployment is ready
    ```
    ```shell
    kubectl delete clusterdeployments capm3-example -n <NAMESPACE>
    ```
    ```console
    clusterdeployment.k0rdent.mirantis.com "capm3-example" deleted
    ```

    Cluster deletion may take several minutes. Bare metal machines are deprovisioned at this time. 

    Watch the `BareMetalHost` objects as they transition through provisioning states:

    ```shell
    kubectl -n <NAMESPACE> get bmh -w
    ```

    You should see the hosts transition from `provisioned` to `available`:

    ```console
    NAME      STATE          CONSUMER                     ONLINE   ERROR   AGE
    child-1   deprovisioning capm3-example-md-txr9f-k8z9d true             31m
    child-2   provisioned    capm3-example-cp-templ-0     true             31m
    child-3   deprovisioning capm3-example-md-txr9f-lkc5c true             31m
    child-1   available                                   true             36m
    child-3   available                                   true             37m
    child-2   deprovisioning capm3-example-cp-templ-0     true             37m
    child-2   available                                   true             43m
    ```

    Then, the available bare metal machines can be used to deploy another cluster,
    using the same `BareMetalHost` objects.

## The OOT CAPM3 provider upgrade notes

To upgrade the OOT CAPM3 provider from v0.1.x to v0.2.0, you need to proceed through the same steps as you do in case
of installing the provider from scratch.
Pay attention to the parameters that are defined in the `management` object:

* the following parameters are new to v0.2.0 and `"option:router,<ROUTER_IP>"` is a required one:
   ```yaml
     config:
       ironic:
         networking:
           dhcp: # used by DHCP server to assign IPs to hosts during PXE boot
             netmask: <DHCP_SUBNET_MASK>         # e.g., 255.255.255.192 (default is 255.255.255.0)
             options:                            # DHCP options, used during PXE boot and by IPA
               - "option:router,<ROUTER_IP>"     # e.g., 10.0.1.1. It's a mandatory option. 
               - "option:dns-server,<DNS_IP[,DNS2_IP...]>" # can be set to KEEPALIVED_VIP (dnsmasq can serve as a DNS server with user-defined DNS records) or to IP of your preferred server. Optional.
               - "option:ntp-server,<NTP_IP>"    # can be set to KEEPALIVED_VIP (internal ntp server) or to IP of your preferred server. That ntp server will be used on PXE boot stage then. Optional.
   ```

* if you changed the set of OS images used for provisioning of bare metal machines, ensure that the new format is used:
```yaml
  # v0.1.x
  config:
    ironic:
      resources:
        static:
          images:
            ubuntu-noble-hwe-2025-05-15-15-22-56.qcow2:
              sha256sum: 581a672e494fcda3297cc8917a91d827157ddcfa3997ad552a914f207b3603c3
              url: https://get.mirantis.com/k0rdent-bm/targetimages/ubuntu-noble-hwe-2025-05-15-15-22-56.qcow2
  # v0.2.0
  config:
    ironic:
      resources:
        images_target:
          - name: ubuntu-noble-hwe-2025-05-15-15-22-56.qcow2
            url: https://get.mirantis.com/k0rdent-bm/targetimages/ubuntu-noble-hwe-2025-05-15-15-22-56.qcow2
            checksum: 581a672e494fcda3297cc8917a91d827157ddcfa3997ad552a914f207b3603c3
```

## Troubleshooting

If you run into difficulties, you might find the solution here.

### `ProviderTemplate` is not valid

If the `ProviderTemplate` shows as invalid, inspect the object for error messages:

```shell
kubectl get providertemplates cluster-api-provider-metal3-{{{ docsVersionInfo.addonVersions.dashVersions.clusterApiProviderCapm3 }}} -oyaml
```

Common issues include incorrect credentials for accessing artifacts or connection problems.

### `Management` object does not become ready

If the `Management` object remains in a non-ready state, inspect it for error messages:

```shell
kubectl get managements.k0rdent.mirantis.com -oyaml
```

If you see Ironic-related errors, check the Ironic deployment:

```shell
kubectl -n kcm-system get deployment/cluster-api-provider-metal3-ironic
```

If Ironic is not ready, verify its configuration:

```shell
kubectl -n kcm-system get cm ironic-bmo-config -oyaml
```

Ensure the configuration matches your network environment, particularly the `PROVISIONING_INTERFACE`, `PROVISIONING_IP`, and `DHCP_RANGE` settings.

### The `HelmRelease` does not become ready

Check to see if the `HelmRelease` object is `Ready`, and if not, why:

```shell
kubectl -n kcm-system get helmrelease cluster-api-provider-metal3
```
```console
NAME                          AGE    READY   STATUS
cluster-api-provider-metal3   164m   False   Helm install failed for release kcm-system/cluster-api-provider-metal3 with chart cluster-api-provider-metal3@0.1.0-9d6d9c8: context deadline exceeded
```

If you see this error, delete the `HelmRelease`:

```shell
kubectl -n kcm-system delete helmrelease cluster-api-provider-metal3
```

Kubernetes will automatically reinstall the `HelmRelease`.


### Useful resources

For additional troubleshooting guidance, refer to the [Metal3 troubleshooting documentation](https://book.metal3.io/troubleshooting).

For more information about bare metal cluster configuration options, see:

- [CAPM3 ClusterTemplate reference](https://github.com/k0rdent/baremetal-charts/tree/main/charts/capm3-standalone-cp)
- [k0s configuration documentation](https://docs.k0sproject.io/head/configuration/)
- [CAPM3 API reference](https://github.com/metal3-io/cluster-api-provider-metal3/blob/main/docs/api.md)
- [Metal3 network configuration guides](https://book.metal3.io/bmo/instance_customization#networkdata)
- [Metal3 IPAM documentation](https://book.metal3.io/ipam/introduction)
