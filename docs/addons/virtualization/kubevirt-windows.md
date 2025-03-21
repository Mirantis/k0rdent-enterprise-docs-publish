# How to run Windows 2022 Server on Kubevirt

This guide explains how to run Windows 2022 Server on Kubevirt. The process involves preparing persistent volume claims (PVCs), exposing the CDI upload proxy, uploading the Windows image, and creating the virtual machine.

---

## 1. Prepare the PVC for Windows

Prepare the following PVC for Windows. *(Additional details may be required based on your environment.)*

---

## 2. Expose CDI Upload Proxy and Upload Windows Image

Expose the CDI upload proxy via port-forward and upload the Windows image to a PVC.

### a. Expose CDI Upload Proxy

Run the following command to expose the CDI upload proxy:

```bash
kubectl port-forward -n kubevirt service/cdi-uploadproxy 18443:443
```

### b. Upload Windows Image

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

---

## 3. Create the Virtual Machine

Create the VM using the following YAML configurations.

### PVC YAML for Windows Hard Drive

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

### Virtual Machine YAML

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

---

## Additional Notes

- **Connecting to the VM:** Once the VM is started, connect to it via VNC.
- **Installing the OS:** When you get to the screen to install the OS on a disk, you may see no disks. To resolve this, click the **"Load driver"** button and provide the necessary drivers.
