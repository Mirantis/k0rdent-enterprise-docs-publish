# Getting Started

This guide provides an introduction to setting up and managing Mirantis k0rdent Virtualization (KubeVirt). It covers system requirements, installation steps, and multiple methods for managing virtual machines, ensuring you have the necessary context to deploy and operate virtualization components efficiently.

## System Requirements

HCO is deployed on top of a {{{ docsVersionInfo.k0rdentName }}} `ClusterDeployment`. For specific software and hardware requirements, refer to the {{{ docsVersionInfo.k0rdentName }}} documentation. For worker nodes, the suggested hardware requirements are:

- `Memory`: 64 GB of RAM  
- `CPU`: 16 vCPUs  
- `Storage`: 500 GB available

These requirements are designed to provide sufficient resources for running virtual machine workloads reliably while accommodating the overhead of Kubernetes and virtualization management components.

## Installation

Before beginning, ensure that HCO has been [installed](./mkvirt-install.md) and [configured](./configuration.md).

## Managing Virtual Machines

Once your environment is set up, you have several options to create, update, delete, and migrate Virtual Machines. The available methods include:

- Web UI (`kubevirt-manager`)
- `virtctl`: A command-line tool for advanced VM operations
- YAML Templates: The Kubernetes native approach for managing resources

Each method provides its own advantages depending on your workflow and requirements.

### kubevirt-manager

Mirantis provides an enhanced version of `kubevirt-manager` that is managed by HCO on {{{ docsVersionInfo.k0rdentName }}} clusters. This Web UI offers an intuitive interface for managing virtual machines. To access the `kubevirt-manager` UI, forward the service port to your local machine using the following command:

```bash
kubectl -n kubevirt port-forward svc/kubevirt-manager 8080:8080
```

Default credentials to log in (be sure to change them!) are:  
`Username`: `admin`  
`Password`: `mirantisdemo`

The `kubevirt-manager` Web UI simplifies day-to-day operations, making it easier for operators to monitor and manage virtual machines without relying solely on command-line tools or YAML files.

### Virtctl

`virtctl` is a command-line utility that provides advanced operations for `VirtualMachineInstance` objects (VMIs). Its features include:

- Accessing serial and graphical consoles
- Starting and stopping VMIs
- Live migrating VMIs and canceling live migrations
- Uploading virtual machine disk images

To install virtctl:

1. Download the tool:

    Choose the appropriate version for your architecture from the [virtctl Artifacts](https://binary.mirantis.com/?prefix=kubevirt/bin/artifacts) page.

2. Download using `wget`:

    ```bash
    wget https://binary-mirantis-com.s3.amazonaws.com/kubevirt/bin/artifacts/virtctl-1.3.1-20240911005512-<ARCH>-<PLATFORM> -O virtctl
    ```
    Replace `<ARCH>` with either `darwin` or `linux` and `<PLATFORM>` with either `amd64` or `arm64`.

3. Move the binary:

    Place `virtctl` in a directory included in your `PATH`.

4. Use the `virtctl` binary:

    Some examples of using the `virtctl` binary include:

    ```bash
    virtctl start vm-cirros
    virtctl console vm-cirros
    virtctl restart vm-cirros
    ```

### Virtual Machine Templates

Kubernetes YAML templates offer a native method for creating and managing virtual machines. Below are examples of templates for different distributions, which you can apply to a child cluster using `kubectl`.

#### Cirros

This template creates a lightweight virtual machine using the Cirros image:

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

This template demonstrates a configuration for a Fedora-based virtual machine:

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

Other templates (for Ubuntu or [Windows](mkvirt-windows.md), for example) can be created in a similar manner.

Using YAML templates allows for version-controlled and reproducible VM deployments, enabling infrastructure as code practices. This method is particularly useful in automated and CI/CD workflows.
