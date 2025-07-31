# Configuring the UI

The {{{ docsVersionInfo.k0rdentName }}} UI can assist in performing actions and getting visibility into what's happening, but there are certain resources that need to be created ahead of time.

## Enable / Disable the UI

You don't need to install the {{{ docsVersionInfo.k0rdentName }}} UI because it's already included with k0rdent-enterprise, but you can enable or disable it by editing the `Management` object:

```shell
kubectl edit management kcm -n kcm-system
```
```console
...
spec:
  core:
    capi: {}
    kcm:
      config:
        k0rdent-ui:
          auth:
            basic:
              password: mypassword
          enabled: false
  providers:
  - name: cluster-api-provider-k0sproject-k0smotron
...
```

This opens a text editor with the YAML for `kcm`.  Set the value of `spec.core.kcm.config.k0rdent-ui.enabled` to `true` or `false` and save the document.

It will take a few minutes for the `Management` object to become ready:

```shell
kubectl get management
```
```console
NAME   READY   RELEASE                        AGE
kcm    False   k0rdent-enterprise-1-1-0-rc9   46m
```
```shell
kubectl get management
```
```console
NAME   READY   RELEASE                        AGE
kcm    True    k0rdent-enterprise-1-1-0-rc9   46m
```

Once the `Management` object is ready, the changes take effect.

## Signing into the UI

The {{{ docsVersionInfo.k0rdentName }}} UI can handle authentication via Basic Authentication or OIDC.

### Basic Authentication

For security reasons, you **MUST** change the UI password immediately after installation (if you didn't change it as part of the installation process itself).  To do that, edit the `Management` object. This is the same process as [enabling/disabling the UI](#enable--disable-the-ui).


```
...
spec:
  core:
    capi: {}
    kcm:
      config:
        k0rdent-ui:
          auth:
            basic:
              password: myNEWpassword
  providers:
...
```

Edit the value of `spec.core.kcm.config.k0rdent-ui.auth.basic.password` to your new password, and save the
document.  The new password will take effect as soon as the `Management` object is ready.

```shell
kubectl get management
```
```console
NAME   READY   RELEASE                        AGE
kcm    True    k0rdent-enterprise-1-1-0-rc9   46m
```

### OIDC

As of version 1.1.0, {{{ docsVersionInfo.k0rdentName }}} supports OIDC using Google.  To set it up, follow these steps:

1. Start by going to the [Google Developer site](https://developers.google.com/identity/protocols/oauth2) and getting a client ID and secret. 


2. Edit the `Management` object:

    ```shell
    kubectl edit management kcm -n kcm-system
    ```
    ```console
    ...
    spec:
    core:
      capi: {}
      kcm:
        config:
          k0rdent-ui:
            auth:
              google:
                secretKeyRef:
                  name: oidc-secret
                  clientIDKey: client-id
                  clientSecretKey: client-secret
              basic:
                password: myNEWpassword
            nextAuth:
              secretKeyRef:
              name: nextauth-secret
              key: nextauth-secret
    providers:
    ...
    ```

    The `clientIdKey` and `clientSecretKey` are what you got from Google, but the `nextAuth` secret is an arbitrary value to keep the user from being logged out when the pod is restarted.

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

## Credentials

{{{ docsVersionInfo.k0rdentName }}} requires permissions to perform actions. You provide these permissions by creating `Credential` objects.

### Infrastructure credentials

Because {{{ docsVersionInfo.k0rdentName }}} can work with multiple infrastructures, the `Credential` created will depend on the infrastructure on which the target cluster runs. You can get more information [here](../../admin/access/credentials/credentials-process.md). Create a `Credential` for every infrastructure on which you intend to work.

### Cluster credentials

While {{{ docsVersionInfo.k0rdentName }}} can be used to create and manage new clusters, it can also "adopt" existing clusters. To adopt a cluster, it needs login access to the cluster via a valid `KUBECONFIG`, just as you would use with `kubectl`. To make this available to {{{ docsVersionInfo.k0rdentName }}}, you can create a `Credential` that includes the `KUBECONFIG`. See the documentation for [adopting clusters](../../admin/clusters/admin-adopting-clusters.md) for more information.

## Make the UI avaiable

To make the UI available to users, create an `Ingress` that points to the `k0rdent-ui-*` `Pod`.

Alternatively, you can also create local access to the UI by following these steps:

1. Install `kubectl` and set the `KUBECONFIG` to point to the {{{ docsVersionInfo.k0rdentName }}} management cluster.

2. Forward the UI `Pod` to the local machine:

    ```shell
    kubectl port-forward svc/kcm-k0rdent-ui 3000:3000 -n kcm-system
    ```
    ```console
    Forwarding from 127.0.0.1:3000 -> 3000
    Forwarding from [::1]:3000 -> 3000
    ```

3. Access the UI at <a href="http://localhost:3000" target="_blank">http://localhost:3000</a>.

## Catalog Repository

In order to use the Addons catalog, you'll need to add the `k0rdent-catalog` Helm repository.  To do that, create a file, such as `helmrepo.yaml` and add the following:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: k0rdent-catalog
  namespace: kcm-system  
spec:
  type: oci
  url: oci://ghcr.io/k0rdent/catalog/charts
```

Then add the object to your {{{ docsVersionInfo.k0rdentName }}} management cluster:

```shell
kubectl apply -f helmrepo.yaml
```
```console
helmrepository.source.toolkit.fluxcd.io/k0rdent-catalog created
```