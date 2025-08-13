# Installation

Before installing {{{ docsVersionInfo.k0rdentName }}} prepare a special
`values.yaml` file to identify the registry and k0s binaries URL for the main
components.

The following is an example of the `values.yaml` file. In this example, the `k0s` binaries are placed on the HTTP host
`binary.local`. Thus it's expected that the `k0s` binary will be available on
the URL `http://binary.local/k0rdent-enterprise/k0s-v1.32.6+k0s.0-amd64` In
addition, the registry is assumed to be at `registry.local`. Adjust your
`values.yaml` file accordingly.

> WARNING:
> If you're using a registry with a self-signed certificate you must first create a
> secret with `ca.crt` with the value of the CA certificate used to sign the registry's
> certificate. The name of this secret must be set in the
> `.controller.registryCertSecret` value. You can find more details in the
> [Configuring a Custom OCI Registry](../../../appendix/appendix-extend-mgmt.md#configuring-a-custom-oci-registry-for-kcm-components)
> section.

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

Start the installation itself with the following command:

```bash
helm install kcm oci://registry.local/k0rdent-enterprise/charts/k0rdent-enterprise --version {{{ extra.docsVersionInfo.k0rdentDotVersion }}} -n kcm-system --create-namespace -f kcm-values.yaml
```

From here you can [verify the installation](../verify-install.md) as normal.
