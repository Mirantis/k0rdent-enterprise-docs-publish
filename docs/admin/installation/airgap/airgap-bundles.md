# Download airgap bundles

In an airgapped environment, you must make the artifacts for {{{ docsVersionInfo.k0rdentName }}} and Kubernetes available to install child clusters.

## Prerequisites

Set your registry hostname:

```bash
export REGISTRY_HOST="registry.local"
export REGISTRY="${REGISTRY_HOST}/k0rdent-enterprise"
```

{{< warning >}}
Replace `registry.local` with your actual registry hostname.
{{< /warning >}}

## Download the {{{ docsVersionInfo.k0rdentName }}} bundle

Add the {{{ docsVersionInfo.k0rdentName }}} bundle to the registry so that Helm can install it.

### Download bundle and signature

```bash
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz.sig
```

### Verify the bundle

Verify the downloaded file using `cosign`:

```bash
cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz.sig airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz
```

{{< note >}}
For offline verification, download the public key and transfer it along with the bundle and signature to the airgapped environment.
{{< /note >}}

### Add bundle to registry

Extract the bundle to a temporary directory:

```bash
mkdir airgap-bundle
tar -xf airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz -C airgap-bundle
```

Upload to the registry using `skopeo`:

1. Log in to the registry:

```bash
skopeo login ${REGISTRY_HOST}
```

2. Run the following commands:

```bash
cd airgap-bundle
for file in $(find . -type f | sed -s s~^./~~g); do echo $file; bn=${file%*.tar}; skopeo copy -a oci-archive:${file} docker://${REGISTRY}/${bn%_*}:${bn#*_}; done
```


## Download the k0s bundle

Add the `k0s` binaries to the HTTP server to use them for installing child clusters.

### Download k0s binaries

Download the binaries and their signatures:

```bash
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.5+k0s.1-amd64
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.5+k0s.1-amd64.sig
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.1+k0s.0-amd64
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.1+k0s.0-amd64.sig
```

### Verify k0s binaries

Verify the signature using `cosign`:

```bash
cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature k0s-v1.32.5+k0s.1-amd64.sig k0s-v1.32.5+k0s.1-amd64
```

### Upload to HTTP server

Upload the `k0s` binary file to any HTTP server available from within the airgapped environment, such as one running in the management cluster.

{{< warning >}}
Do not change the name of the `k0s` binary. The deployment will fail if you rename it.
{{< /warning >}}
