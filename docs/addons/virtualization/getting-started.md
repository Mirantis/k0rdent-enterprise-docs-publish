# Getting Started

## System Requirements

HCO is deployed on top of a k0rdent ClusterDeployment. For specific software and hardware requirements, refer to the k0rdent documentation. For worker nodes, the suggested hardware requirements are:

- **Memory:** 64 GB of RAM  
- **CPU:** 16 vCPUs  
- **Storage:** 500 GB available

## Installation

*Installation instructions: [Install Guide](<put link for install guide here>)*

## Managing Virtual Machines

There are several methods to create, update, delete, and migrate Virtual Machines:

- **Web UI (kubevirt-manager)**
- **virtctl:** A command-line tool for advanced VM operations
- **YAML Templates:** The Kubernetes native way

### Kubevirt-manager

Mirantis provides an enhanced kubevirt-manager managed by HCO on k0rdent clusters. To access the kubevirt-manager UI, forward the service port to a local port. For example:

```bash
kubectl -n kubevirt port-forward svc/kubevirt-manager 8080:8080
```

Basic credentials to log in are:  
**Username:** `admin`  
**Password:** `mirantisdemo`

After logging in, you can manage Virtual Machines via the Web UI.

### Virtctl

`virtctl` is a binary utility that offers advanced features such as:

- Serial and graphical console access
- Starting and stopping VirtualMachineInstances
- Live migrating VirtualMachineInstances and canceling live migrations
- Uploading virtual machine disk images

**To install virtctl:**

1. **Download the tool:**  
   Find the appropriate version for your architecture at:  
   [virtctl Artifacts](https://binary.mirantis.com/?prefix=kubevirt/bin/artifacts)

2. **Download using wget:**

   ```bash
   wget https://binary-mirantis-com.s3.amazonaws.com/kubevirt/bin/artifacts/virtctl-1.3.1-20240911005512-<ARCH>-<PLATFORM> -O virtctl
   ```
   Replace `<ARCH>` with either `darwin` or `linux` and `<PLATFORM>` with either `amd64` or `arm64`.

3. **Move the binary:**  
   Place `virtctl` in a directory included in your PATH.

**Usage examples:**

```bash
virtctl start vm-cirros
virtctl console vm-cirros
virtctl restart vm-cirros
```

### Virtual Machine Templates

You can create Virtual Machines using YAML templates with `kubectl`. Below are examples for different distributions.

#### Cirros

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: vm-cirros
  labels:
    kubevirt.io/vm: vm-cirros
spec:
  running: false
  template:
    metadata:
      labels:
        kubevirt.io/vm: vm-cirros
    spec:
      domain:
        devices:
          disks:
            - disk:
                bus: virtio
              name: containerdisk
            - disk:
                bus: virtio
              name: cloudinitdisk
        resources:
          requests:
            memory: 128Mi
      terminationGracePeriodSeconds: 0
      volumes:
        - name: containerdisk
          containerDisk:
            image: mirantis.azurecr.io/kubevirt/cirros-container-disk-demo:1.3.0-alpha.0-20240516192211
        - name: cloudinitdisk
          cloudInitNoCloud:
            userData: |
              #!/bin/sh
              echo 'printed from cloud-init userdata'
```

#### Fedora

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: vm-fedora
  labels:
    kubevirt.io/vm: vm-fedora
spec:
  runStrategy: Always
  template:
    metadata:
      labels:
        kubevirt.io/vm: vm-fedora
    spec:
      domain:
        resources:
          requests:
            memory: 1024M
        devices:
          disks:
            - disk:
                bus: virtio
              name: containerdisk
            - disk:
                bus: virtio
              name: cloudinitdisk
      terminationGracePeriodSeconds: 0
      volumes:
        - name: containerdisk
          containerDisk:
            image: mirantis.azurecr.io/kubevirt/fedora-with-test-tooling-container-disk:1.3.1-20241030114153
        - name: cloudinitdisk
          cloudInitNoCloud:
            userData: |
              #cloud-config
              password: fedora
              chpasswd: { expire: False }
```

Other templates (for Ubuntu and Windows) can be created in a similar manner.
