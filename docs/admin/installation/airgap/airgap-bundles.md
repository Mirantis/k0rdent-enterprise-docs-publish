# Download the airgap bundles

In an airgapped environment, the artifacts for {{{ docsVersionInfo.k0rdentName }}} and 
Kubernetes to install child clusters need to be available.

## The {{{ docsVersionInfo.k0rdentName }}} bundle

The {{{ docsVersionInfo.k0rdentName }}} bundle needs to be added to the registry so that
Helm can install it. 

To download the airgap bundle and its signature, use the following commands:

```bash
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz.sig
```

To verify the downloaded file, use `cosign`:

```bash
cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz.sig airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz
```

> NOTE:
> If you need to use offline verification, download the public key downloaded and
> transfer it along with the bundle and signature to the airgapped environment.

Now we'll add it to the registry.

First unpack the bundle to a temporary directory:

```bash
mkdir airgap-bundle
tar -xf airgap-bundle-{{{ extra.docsVersionInfo.k0rdentDotVersion }}}.tar.gz -C airgap-bundle
```

Then upload it to the registry using `skopeo`.

Log in to the registry, then run:

```bash
cd airgap-bundle
export REGISTRY="registry.local/k0rdent-enterprise"
for file in $(find . -type f | sed -s s~^./~~g); do echo $file; bn=${file%*.tar}; skopeo copy -a oci-archive:${file} docker://${REGISTRY}/${bn%_*}:${bn#*_}; done
```

> WARNING: 
> Make sure to replace `registry.local` with the actual registry host name.

## The k0s bundle

The `k0s` binaries, which are a separate, binary artifact, need to be added to 
the HTTP server so they can be used to install child clusters. Start by downloading
the binaries:

```bash
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.5+k0s.1-amd64
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.5+k0s.1-amd64.sig
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.1+k0s.0-amd64
wget https://get.mirantis.com/k0rdent-enterprise/{{{ extra.docsVersionInfo.k0rdentDotVersion }}}/k0s-v1.32.1+k0s.0-amd64.sig
```

Use `cosign` to verify this signature as well:

```bash
cosign verify-blob --key https://get.mirantis.com/k0rdent-enterprise/cosign.pub --signature k0s-v1.32.5+k0s.1-amd64.sig k0s-v1.32.5+k0s.1-amd64
```

Now upload the `k0s` binary file to any HTTP server available from within the
airgapped environment, such as one running in the management cluster. 

> WARNING:
> Do not change the name of the `k0s` binary, or the deployment will fail.
