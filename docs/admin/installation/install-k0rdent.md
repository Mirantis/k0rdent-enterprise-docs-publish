# Installation

This section assumes that you already have a kubernetes cluster installed. If you need to setup a cluster you can follow the [Create and prepare a Kubernetes cluster with k0s](./create-mgmt-clusters/mgmt-create-k0s-single.md) to create a test cluster, or [Create and prepare a production grade Kubernetes cluster with EKS](./create-mgmt-clusters/mgmt-create-eks-multi.md) to create something more substantial. 

The actual management cluster is a Kubernetes cluster with the {{{ docsVersionInfo.k0rdentName }}} application installed. The simplest way to install {{{ docsVersionInfo.k0rdentName }}} is through its Helm chart.  You can find the latest release [here]({{{ docsVersionInfo.k0rdentTagList }}}), and from there you can deploy the Helm chart, as in:

> NOTE:
> Don't forget to [verify the installation files](sbom.md).

## Configure the UI

By default, {{{ docsVersionInfo.k0rdentName }}} installs and enables the UI with a pre-determined password. Please change the password (or disable the UI) when installing {{{ docsVersionInfo.k0rdentName }}}. If you do not, anyone with access to the management cluster's network can log into the UI and deploy or affect resources in the {{{ docsVersionInfo.k0rdentName }}} environment.

To change the password, add the following to the installation command below:

```shell
--set k0rdent-ui.auth.basic.password='<NEW_PASSWORD>'
```

To disable the UI, use:

```shell
--set kordent-ui.enabled=false
```

## Install {{{ docsVersionInfo.k0rdentName }}}

You install {{{ docsVersionInfo.k0rdentName }}} via  Helm chart:

```shell
helm install kcm {{{ extra.docsVersionInfo.ociRegistry }}} --version {{{ extra.docsVersionInfo.k0rdentDotVersion }}} -n kcm-system --create-namespace <UI_CONFIG>
```
> IMPORTANT:
> Don't forget to set the UI configuration to modify the default username and password or disable the UI before deploying, as noted [above](#configure-the-ui). If you do not, the UI will be enabled with a default username and password, potentially leaving the management cluster open to attack by anyone able to access the network it's on.

```console
Pulled: registry.mirantis.com/k0rdent-enterprise/charts/k0rdent-enterprise:{{{ extra.docsVersionInfo.k0rdentDotVersion }}}
Digest: {{{ extra.docsVersionInfo.k0rdentDigestValue }}}
NAME: kcm
LAST DEPLOYED: {{{ extra.docsVersionInfo.k0rdentDigestDate }}}
NAMESPACE: kcm-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
k0rdent enterprise chart has been installed.
Please make sure to change the auth method or set a new password for basic auth by
creating a secret and referencing it in `k0rdent-ui.auth.basic.secretKeyRef`
```

The helm chart deploys the KCM operator and prepares the environment, and KCM then proceeds to deploy the various subcomponents, including CAPI. The entire process takes a few minutes.

## Cleanup: Uninstall {{{ docsVersionInfo.k0rdentName }}}

And of course when you need to clean up, you can use helm as well. Follow these steps:

1. Remove any `ClusterDeployment` objects in the cluster.

2. Delete the `Management` object:

    ```shell
    kubectl delete management.k0rdent kcm
    ```

3. Remove the kcm Helm release:

    ```shell
    helm uninstall kcm -n kcm-system
    ```

4. Finally, remove the kcm-system namespace:

    ```shell
    kubectl delete ns kcm-system
    ```