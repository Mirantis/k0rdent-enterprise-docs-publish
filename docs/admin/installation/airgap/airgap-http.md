# Installing an HTTP server

Optionally, if you don't have an HTTP server available to your airgapped
system, you can install one to serve the `k0s` binary right in the
{{{docsVersionInfo.k0rdentName}}} management cluster.

The following instructions were tested on an "airgapped" AWS instance.

> WARNING:
> Images used in the following example (such as `nginx:1.27.5`) aren't part
> of the airgap bundle and must be downloaded separately.

1. Create the `Deployment`:

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

3. The `k0s-ag-image*` pod runs an Nginx HTTP server that serves files from a `hostPath` volume:

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

Once you have uploaded all the necessary images, you can start the
{{{ docsVersionInfo.k0rdentName }}} installation process.
