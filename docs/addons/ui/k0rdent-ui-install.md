# Installing the UI

The {{{ docsVersionInfo.k0rdentName }}} UI has built-in authentication to protect administrative and user resources, and the installation method depends on whether you choose Basic Authentication or OIDC (OpenID Connect) using Google. 

In either case, you will need to prepare the {{{ docsVersionInfo.k0rdentName }}} management cluster for the installation.

## Preparing the Management Cluster

The {{{ docsVersionInfo.k0rdentName }}} UI is deployed from the Github Container Registry, so you will need to first authenticate to the registry before deployment. Follow these steps:

1. Create a secret with your Github credentials:

    ```shell
    kubectl create secret docker-registry ghcr-pull-secret \
    --docker-server=ghcr.io \
    --docker-username=<github-username> \
    --docker-password=<github-personal-access-token> \
    -n kcm-system
    ```

    You can create a [Github Personal Access Token](https://github.com/settings/tokens) on the Github site.

2. Login to the repository using Helm:

    ```shell
    echo <github-personal-access-token> | helm registry login ghcr.io -u <github-username> --password-stdin
    ```
    ```console
    Login Succeeded
    ```

3. Create an internal `Secret` used for authentication so the UI doesn't log out when the UI pod restarts. This `Secret` won't be user-facing.

    ```sh
    kubectl create secret generic nextauth-secret -n kcm-system --from-literal=nextauth-secret=$(openssl rand -base64 32)
    ```

Now you're ready to do the actual installation.

## Install the UI with Basic Authentication

While we recommend [OIDC authentication](#install-the-ui-with-oidc-authentication) for production use, there are some situations, such as testing or local development, in which Basic Authentication is appropriate.

Use Helm to install the {{{ docsVersionInfo.k0rdentName }}} UI:

```shell
helm install k0rdent-ui oci://ghcr.io/k0rdent/k0rdent-ui/k0rdent-ui --version {{{ docsVersionInfo.addonVersions.dotVersions.k0rdentUI }}} -n kcm-system \
--set auth.basic.enabled=true \
--set auth.basic.username=admin \
--set auth.basic.password=password \
--set nextAuth.secretKeyRef.name=nextauth-secret \
--set nextAuth.secretKeyRef.key=nextauth-secret \
--set "image.pullSecrets[0].name=ghcr-pull-secret"
```
```console
Pulled: ghcr.io/k0rdent/k0rdent-ui/k0rdent-ui:{{{ docsVersionInfo.addonVersions.dotVersions.k0rdentUI }}}
Digest: {{{ docsVersionInfo.addonVersions.digests.k0rdentUI }}}
NAME: k0rdent-ui
LAST DEPLOYED: {{{ docsVersionInfo.addonVersions.digests.k0rdentUIDate }}}
NAMESPACE: kcm-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

## Install the UI with OIDC Authentication

{{{ docsVersionInfo.k0rdentName }}} supports the use of OIDC authentication using Google. (Other providers will be supported in the future.)  To install it for OIDC, follow these steps:

1. Create a Google OAuth client ID and secret using [Google Identity](https://developers.google.com/identity/protocols/oauth2)

2. Configure the mothership cluster to use the client ID and secret. How you do this will depend on the distribution you used for the Kubernetes cluster itself.  For example, if you created a multi-cluster k0s cluster, 
edit your k0s config (`/etc/k0s/config.yaml` -- create it using `k0s default-config > k0s.yaml` if necessary) to tell the API server to use these extra values:

    ```yaml
    ...
    spec:
      api:
        extraArgs:
        oidc-issuer-url: "https://accounts.google.com"
        oidc-client-id: "XXXXXXXXX-xxxxxx.apps.googleusercontent.com"
        oidc-username-claim: "email"
    ...
    ```

    Then restart the controller:

    ```shell
    sudo systemctl restart k0scontroller
    ```

3. Add role bindings for the users to whom you want to grant access to the {{{ docsVersionInfo.k0rdentName }}} UI:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
        name: kcm-oidc-admin
    roleRef:
        kind: ClusterRole
        name: kcm-k0rdent-enterprise-global-admin-role
        apiGroup: rbac.authorization.k8s.io
    subjects:
    - kind: User
        name: <user-email>
        apiGroup: rbac.authorization.k8s.io
    ```

4. Create a Kubernetes `Secret` that contains the Google OAuth client ID and secret. This `Secret` will be used by the UI to authenticate users:

    ```sh
    kubectl -n kcm-system create secret generic oidc-secret \
    --from-literal=client-id=xxxxxxxxxx-xxxxxxxxxxxx.apps.googleusercontent.com \
    --from-literal=client-secret=XXXXXX-XX-XXXXXXXXXXXX
    ```

5. Deploy the k0rdent-ui to the cluster using Helm:

    ```sh
    helm install k0rdent-ui oci://ghcr.io/k0rdent/k0rdent-ui/k0rdent-ui --version 1.0.0-rc.5 -n kcm-system \
    --set auth.google.enabled=true \
    --set auth.google.secretKeyRef.name=oidc-secret \
    --set auth.google.secretKeyRef.clientIDKey=client-id \
    --set auth.google.secretKeyRef.clientSecretKey=client-secret \
    --set nextAuth.secretKeyRef.name=nextauth-secret \
    --set nextAuth.secretKeyRef.key=nextauth-secret 
    ```

## Make the UI avaiable

To make the UI available to users, create an `Ingress` that points to the `k0rdent-ui-*` `Pod`.

Alternatively, you can also create local access to the UI by following these steps:

1. Install `kubectl` and set the `KUBECONFIG` to point to the {{{ docsVersionInfo.k0rdentName }}} management cluster.

2. Forward the UI `Pod` to the local machine:

    ```shell
    kubectl port-forward svc/k0rdent-ui 3000:3000 -n kcm-system
    ```
    ```console
    Forwarding from 127.0.0.1:3000 -> 3000
    Forwarding from [::1]:3000 -> 3000
    ```

3. Access the UI at <a href="http://localhost:3000" target="_blank">http://localhost:3000</a>.

Before using the UI to [perform operations on {{{ docsVersionInfo.k0rdentName}}}](k0rdent-ui-usage.md), complete the [UI configuration](k0rdent-ui-config.md).

