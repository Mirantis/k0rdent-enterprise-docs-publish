# Configurating the UI

The {{{ docsVersionInfo.k0rdentName }}} UI can assist in performing actions and getting visibility into what's happening, but there are certain resources that need to be created ahead of time.

## Credentials

In order to take action, {{{ docsVersionInfo.k0rdentName }}} must have the appropriate permissions.  In this case, that means creating `Credential` objects. 

### Infrastructure credentials

Because {{{ docsVersionInfo.k0rdentName }}} can work with multiple infrastructures, the `Credential` created will depend on the infrastructure on which the target cluster runs. You can get more information [here](../../admin/access/credentials/credentials-process.md). Create a `Credential` for every infrastructure on which you intend to work.

### Cluster credentials

While {{{ docsVersionInfo.k0rdentName }}} can be used to create and manage new clusters, it can also "adopt" existing clusters. Do do that, {{{ docsVersionInfo.k0rdentName }}} needs the ability to log into the cluster and perform actions. From the command line using `kubectl` you'd use the `KUBECONFIG`, and it's the same thing for {{{ docsVersionInfo.k0rdentName }}}. You need to create a `Credential` that includes the `KUBECONFIG`. You can get instructions in the documentation on [adopting clusters](../../admin/clusters/admin-adopting-clusters.md).
