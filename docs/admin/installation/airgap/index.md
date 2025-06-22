# Install {{{ docsVersionInfo.k0rdentName }}} in the airgapped environment

This section will guide you through {{{ docsVersionInfo.k0rdentName }}} in an
airgapped environment (that is, with absent or restricted internet access).

## Prerequisites

### Tools

All tools must be available on the machine inside the airgapped environment
which will be used for {{{ docsVersionInfo.k0rdentName }}} installation.

> NOTE:
> The following tools will be used in the scripts and examples throughout this
> section. The exact versions are listed for the reference purposes and you may
> be able to run everything on older versions.

- `bash >=4.2`, recommended `>=5.1`
- GNU Coreutils `>=8.32` for basic file manipulations
- `tar 1.34` with gzip support
- `wget` or any other tool to download bundle via HTTP
- `skopeo >=1.16.1`
- `cosign >=2.4.1`
- `helm >= 3.16.3`

### Infrastructure

It is expected that all the following infrastructure is prepared before
installing {{{ docsVersionInfo.k0rdentName }}}:

- Container registry with OCI support (e.g. Harbor). It should be exposed with
  trusted PKI certificate.

      > WARNING:
      > Insecure registries or registries with self-signed certificate are not supported.

- HTTP endpoint to serve k0s binary for child cluster creation (could be plain
  HTTP, but not insecure HTTPS).
- Kubernetes cluster on which k0rdent-enterprise will be installed. With version
  `>=1.30`.
- Working networking with external IPAM (DHCP) and connectivity to all necessary
  resources (like registry and Kubernetes API endpoint).

## Installation process

### Download released airgap bundle

To download airgap bundle and it's signature the following commands may be used:

```bash
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz.sig
```

To verify the downloaded file `cosign` must be used:

```bash
cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz.sig airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz
```

> NOTE:
> If offline verification is needed the public key must be downloaded and
> transferred along with the bundle and signature to the airgapped environment.

`k0s` binaries should be downloaded as well, since currently it's a separate
binary artifact:

```bash
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.5+k0s.1-amd64
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.5+k0s.1-amd64.sig
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.1+k0s.0-amd64
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.1+k0s.0-amd64.sig
```

The signature may be verified in the same way as with airgap bundle:

```bash
cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature k0s-v1.32.5+k0s.1-amd64.sig k0s-v1.32.5+k0s.1-amd64
```

After bundle and k0s binary delivered to the node in the airgapped environment
installation could proceed.

### Unpack and upload airgap bundle

First bundle should be unpacked to the temporary directory:

```bash
mkdir airgap-bundle
tar -xf airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz -C airgap-bundle
```

Then it could be uploaded to the desired registry using `skopeo`.

> WARNING: 
> In the example scripts the `registry.local` is used as an example host name
> for the registry. It should be changed to the actual registry host name.

> NOTE:
> Login to the registry should be done before running the script.

```bash
cd airgap-bundle
export REGISTRY="registry.local/k0rdent-enterprise"
for file in $(find . -type f | sed -s s~^./~~g); do echo $file; bn=${file%*.tar}; skopeo copy -a oci-archive:${file} docker://${REGISTRY}/${bn%_*}:${bn#*_}; done
```

`k0s` binary file could be uploaded to any HTTP server available from withing the
airgapped environment. File name should not be altered.

#### Installing an HTTP server

Fortunately, if you don't have an HTTP server available to your airgapped system, 
you can install one to serve the `k0s` binary right in the
{{{ docsVersionInfo.k0rdentName}}} management cluster.

The following instructions were tested on an "airgapped" AWS instance.

1. Create the `Deployment`

    Start by creating the YAML for the webserver, say, in `k0s-bundle-ag.yaml`:

    ```yaml
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: k0s-ag-image
      labels:
        app: k0s-ag-image
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: k0s-ag-image
      template:
        metadata:
          labels:
            app: k0s-ag-image
        spec:
          containers:
          - name: k0s-ag-image
            image: nginx:1.27.5
            ports:
            - containerPort: 80
            volumeMounts:
            - name: config-volume
              mountPath: /etc/nginx/conf.d
            - name: local-volume
              mountPath: /var/www/html
          volumes:
          - name: config-volume
            configMap:
              name: k0s-ag-config
          - name: local-volume
            hostPath:
              path: /home/ubuntu/k0s
              type: Directory
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: k0s-ag-image
    spec:
      ports:
      - name: http
        port: 80
        protocol: TCP
        targetPort: 80
      selector:
        app: k0s-ag-image
      type: NodePort

    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: k0s-ag-config
    data:
      default.conf: |
        server {
          proxy_max_temp_file_size 0;
          listen       80;
          sendfile        on;
          tcp_nopush     on;
          tcp_nodelay        on;
          server_name localhost;

          keepalive_timeout  70;

          root   /var/www/html;
          location / {
          }

          client_max_body_size 512m;

          location /heathz {
            return 200 'OK';
          }
        }    
    ```

    Apply the YAML to your management cluster:

    ```shell
    kubectl apply -f k0s-bundle-ag.yaml 
    ```

2. Check for the `k0s-ag-image*` pod:

    ```console
    kubectl get pods -A
    NAMESPACE     NAME                             READY   STATUS    RESTARTS   AGE
    default       k0s-ag-image-67d7d95964-drd6h    1/1     Running   0          21h
    kube-system   coredns-58cb98cf9c-8zdph         1/1     Running   0          18h
    kube-system   kube-proxy-vpvk5                 1/1     Running   0          21h
    kube-system   kube-router-zdkvp                1/1     Running   0          21h
    kube-system   metrics-server-7db8586f5-blh6w   1/1     Running   0          21h
    ```

3. The `k0s-ag-image*` pod runs an Nginx HTTP server that serves files from a hostPath volume:

    ```yaml
    hostPath:
      path: /home/ubuntu/k0s
    ```    

4. Place the k0s binary in that directory, as in:

    ```console
    /home/ubuntu/k0s/k0rdent-enterprise/k0s-v1.32.5+k0s.1-amd64
    ```

5. Get the HTTP port:

    ```shell
    sudo k0s kubectl get service -A
    ```
    ```console
    NAMESPACE     NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
    default       k0s-ag-image     NodePort    10.105.121.68    <none>        80:32538/TCP             50m
    default       kubernetes       ClusterIP   10.96.0.1        <none>        443/TCP                  50m
    kube-system   kube-dns         ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   50m
    kube-system   metrics-server   ClusterIP   10.109.193.120   <none>        443/TCP                  50m
    ```

    In this case, files made availabe by the HTTP server are availabe on port `32538`.

6. Test the HTTP server:

    ```shell
    curl -I http://<HOST_IP>:<HOST_PORT>/k0rdent-enterprise/k0s-v1.32.5+k0s.1-amd64
    ```
    ```console
    HTTP/1.1 200 OK
    Server: nginx/1.27.5
    Date: Tue, 17 Jun 2025 21:32:28 GMT
    Content-Type: application/octet-stream
    Content-Length: 268006461
    Last-Modified: Tue, 17 Jun 2025 21:26:59 GMT
    Connection: keep-alive
    ETag: "6851dda3-ff9743d"
    Accept-Ranges: bytes
    ```

Once you have uploaded all the necessary images, you can start the {{{ docsVersionInfo.k0rdentName }}} installation
process.

### Installation

Before installing {{{ docsVersionInfo.k0rdentName }}} special `values.yaml` file
should be prepared to identify registry and k0s binaries URL for main
components.

The following is an example of the `values.yaml` file:

> NOTE:
> In this example `k0s` binaries are placed on the HTTP host
> `binary.local`. Thus it's expected that `k0s` binary will be available on the
> URL `http://binary.local/k0rdent-enterprise/k0s-v1.32.5+k0s.1-amd64`.

```yaml
controller:
  templatesRepoURL: "oci://registry.local/k0rdent-enterprise/charts"
  globalRegistry: "registry.local/k0rdent-enterprise"
  globalK0sURL: "http://binary.local/k0rdent-enterprise"

image:
  repository: registry.local/k0rdent-enterprise/kcm-controller

cert-manager:
  image:
    repository: registry.local/k0rdent-enterprise/jetstack/cert-manager-controller
  webhook:
    image:
      repository: registry.local/k0rdent-enterprise/jetstack/cert-manager-webhook
  cainjector:
    image:
      repository: registry.local/k0rdent-enterprise/jetstack/cert-manager-cainjector
  startupapicheck:
    image:
      repository: registry.local/k0rdent-enterprise/jetstack/cert-manager-startupapicheck

flux2:
  helmController:
    image: registry.local/k0rdent-enterprise/fluxcd/helm-controller
  sourceController:
    image: registry.local/k0rdent-enterprise/fluxcd/source-controller
  cli:
    image: registry.local/k0rdent-enterprise/fluxcd/flux-cli

cluster-api-operator:
  image:
    manager:
      repository: registry.local/k0rdent-enterprise/capi-operator/cluster-api-operator

velero:
  image:
    repository: registry.local/k0rdent-enterprise/velero/velero
```

The installation itself then can be started with the following command:

```bash
helm install kcm oci://registry.local/k0rdent-enterprise/charts/k0rdent-enterprise --version {{{ extra.docsVersionInfo.k0rdentDotVersion }}} -n kcm-system --create-namespace -f kcm-values.yaml
```
