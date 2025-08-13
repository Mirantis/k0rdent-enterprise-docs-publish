# Download airgap bundles

In an airgapped environment, you must make the artifacts for
{{{docsVersionInfo.k0rdentName }}} and Kubernetes available to install child
clusters.

## Prerequisites

Set your registry hostname:

> WARNING:
> Replace `registry.local` with your actual registry hostname.

```shell
export REGISTRY_HOST="registry.local"
export REGISTRY="${REGISTRY_HOST}/k0rdent-enterprise"
```

## Download the {{{ docsVersionInfo.k0rdentName }}} bundle

Add the {{{ docsVersionInfo.k0rdentName }}} bundle to the registry so that Helm
can install it.

### Download bundle and signature

```shell
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz.sig
```

### Verify the bundle

Verify the downloaded file using `cosign`:

```shell
cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz.sig airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz
```

> NOTE:
> For offline verification, download the public key and transfer it along with
> the bundle and signature to the airgapped environment. Additionally the
> `--private-infrastructure=true` flag must be set to skip online transparency
> log verification.

### Add Bundle to the Registry

Extract the bundle to a temporary directory:

```shell
mkdir airgap-bundle
tar -xf airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz -C airgap-bundle
```

Upload to the registry using `skopeo`:

1. Load `skopeo` image from the airgap bundle:

    ```shell
    docker load -i airgap-bundle/skopeo_v1.17.0.tar
    ```

2. Log in to the registry:

    ```shell
    docker login ${REGISTRY_HOST}
    ```

3. Run the following script:

    ```shell
    cd airgap-bundle
	for file in $(find . -type f ! -name 'skopeo*' | sed -s s~^./~~g); do
	  echo $file; bn=${file%*.tar};
	  docker run -v ${HOME}/.docker/config.json:/config.json skopeo:v1.17.0 copy -a --authfile /config.json oci-archive:${file} docker://${REGISTRY}/${bn%_*}:${bn#*_};
	done
    ```


## Download k0s binaries

`k0s` binaries must be available from the HTTP server inside the airgapped
environment so they can be used when installing child clusters.

Download the binaries and their signatures:

```shell
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.6+k0s.0-amd64
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.6+k0s.0-amd64.sig
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.1+k0s.0-amd64
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.1+k0s.0-amd64.sig
```

### Verify the downloaded binaries

Verify the signature using `cosign`:

```shell
cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature k0s-v1.32.6+k0s.0-amd64.sig k0s-v1.32.6+k0s.0-amd64
```

### Upload k0s binaries to HTTP server

Upload the `k0s` binary file to any HTTP server available from within the
airgapped environment, such as one running in the management cluster.

> WARNING:
> Do not change the name of the `k0s` binary, or the deployment will fail.
