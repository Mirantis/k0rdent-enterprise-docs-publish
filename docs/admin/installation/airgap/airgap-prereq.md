# Airgapped Install Prerequisites

Before starting an airgapped install of {{{ docsVersionInfo.k0rdentName }}}, make
sure the following tools and infrastructure are in place.

## Tools

The following tools will be needed on the machine inside the airgapped environment
that will be used for {{{ docsVersionInfo.k0rdentName }}} installation.

> NOTE:
> The following tools will be used in the scripts and examples throughout this
> section. The exact versions are listed for reference purposes; you may
> be able to run everything on older versions.

- `bash >=4.2`, recommended `>=5.1`
- GNU Coreutils `>=8.32` for basic file manipulations
- `tar 1.34` with gzip support
- `wget` or any other tool to download bundle via HTTP
- `skopeo >=1.16.1`
- `cosign >=2.4.1`
- `helm >= 3.16.3`

You will also need an [HTTP server](airgap-http.md) that is hosted by or
can be reached from the airgapped machine.

## Infrastructure

Prepare all of the following infrastructure before installing {{{ docsVersionInfo.k0rdentName }}}:

- A container registry with OCI support, such as Harbor. It should be exposed with a
  trusted PKI certificate.

    > WARNING:
    > {{{ docsVersionInfo.k0rdentName }}} airgapped installation doesn't support insecure registries 
    > or registries with self-signed certificate.

- An [HTTP endpoint](airgap-http.md) to serve the k0s binary to enable child cluster creation. This can be plain
  HTTP, but not insecure HTTPS.
- A [Kubernetes cluster](../create-mgmt-clusters/index.md) on which to install {{{ docsVersionInfo.k0rdentName }}} This management cluster should be using Kubernetes version `>=1.30`.
- Working networking with external IPAM (DHCP) and connectivity to all necessary
  resources (like the registry and Kubernetes API endpoint).

