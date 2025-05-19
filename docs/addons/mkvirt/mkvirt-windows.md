# Running Windows Server

This guide explains how to deploy and run Windows 2022 Server on Mirantis k0rdent Virtualization (KubeVirt). It covers the essential steps—from preparing storage to uploading the Windows image and finally creating the virtual machine (VM). The instructions are aimed at operators who need to set up Windows-based workloads in a Kubernetes-native virtualization environment.

1. Prepare the PVC for Windows

    Before deploying the VM, you must create a Persistent Volume Claim (PVC) to host the Windows OS disk. This PVC provides the required storage for the operating system and ensures that the Windows installation has persistent storage.  Additional customization might be necessary depending on your environment.

2. Expose CDI Upload Proxy and Upload Windows Image

    To upload the Windows installation ISO to your cluster, you first need to expose the Containerized Data Importer (CDI) upload proxy and then use it to transfer the Windows image to a PVC. Follow these steps:

    1. Expose CDI Upload Proxy

        Expose the CDI upload proxy by running the following command. This step makes the upload service accessible on a local port, which is essential for the next step.

        ```bash
        kubectl port-forward -n kubevirt service/cdi-uploadproxy 18443:443
        ```
        
        Port forwarding creates a temporary local endpoint to securely interact with the CDI upload proxy. This is particularly useful in development and testing environments.

    2. Upload Windows Image

        Upload the Windows image to a PVC by running:

        ```bash
        virtctl image-upload --image-path=<path to ISO image>/SERVER_EVAL_x64FRE_en-us.iso \
          --pvc-name=isohd \
          --size=20Gi \
          --storage-class=mirablock-k8s-block-hdd \
          --uploadproxy-url=https://127.0.0.1:18443 \
          --insecure \
          --wait-secs=240
        ```
        This command uploads the Windows image to the PVC named `isohd`. The `--wait-secs` parameter allows sufficient time for the operation to complete, which is critical when dealing with large ISO files.

3. Create the Virtual Machine

    Once the storage and image are in place, the next step is to define and create the VM. This process involves specifying PVCs and VM configuration in YAML format. Follow these steps:

    1. PVC YAML for Windows Hard Drive

        First define a PVC to be used as the Windows hard drive. This PVC stores the operating system and any associated data.

        ```yaml
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: winhd
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 100Gi
          storageClassName: mirablock-k8s-block-hdd
        ```

        Ensure that the PVC size is adequate for your Windows workload. Adjust the storage request if needed.

    2. Virtual Machine YAML

        The VM YAML defines the Windows 2022 Server configuration, including resource allocations, boot order, and device configurations.

        ```yaml
        apiVersion: kubevirt.io/v1
        kind: VirtualMachine
        metadata:
          name: win2022-server
        spec:
          running: true
          template:
            metadata:
              labels:
                kubevirt.io/domain: win2022-server
                kubevirt.io/os: windows
            spec:
              domain:
                clock:
                  utc: {}
                  timer:
                    hpet:
                      present: false
                    pit:
                      tickPolicy: delay
                    rtc:
                      tickPolicy: catchup
                    hyperv: {}
                cpu:
                  cores: 4
                devices:
                  disks:
                    - bootOrder: 1
                      cdrom:
                        bus: sata
                      name: cdromiso
                    - disk:
                        bus: virtio
                      name: harddrive
                      bootOrder: 2
                    - cdrom:
                        bus: sata
                      name: virtiocontainerdisk
                machine:
                  type: q35
                resources:
                  requests:
                    memory: 8G
                features:
                  acpi: {}
                  apic: {}
                  hyperv:
                    relaxed: {}
                    spinlocks:
                      spinlocks: 8191
                    vapic: {}
                  smm: {}
                # firmware:
                #   bootloader:
                #     efi:
                #       secureBoot: true
              volumes:
                - name: cdromiso
                  persistentVolumeClaim:
                    claimName: isohd
                - name: harddrive
                  persistentVolumeClaim:
                    claimName: winhd
                - containerDisk:
                    image: mirantis.azurecr.io/kubevirt/virtio-container-disk:1.4.0-20241128094341
                  name: virtiocontainerdisk
        ```
        This configuration sets up a VM with two storage devices: one for the installation media (ISO) and one for the Windows hard drive. The VM uses a Q35 machine type for improved hardware emulation and performance, with Hyper-V features enabled for better compatibility with Windows.

## Additional Notes

- Connecting to the VM: Once the VM is running, you can connect to it via VNC to interact with the Windows installation process.
- Installing the OS: During the OS installation, if no disks are detected, click the `Load driver` button and provide the necessary drivers for Windows to recognize the storage devices.


