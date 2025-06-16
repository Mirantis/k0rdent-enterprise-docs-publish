# Upgrading {{{ docsVersionInfo.k0rdentName }}}

Upgrading {{{ docsVersionInfo.k0rdentName }}} involves making upgrades to the
`Management` object. To do that, you must have the `Global Admin` role. (For
detailed information about {{{ docsVersionInfo.k0rdentName }}} RBAC roles and
permissions, refer to the [RBAC documentation](../access/rbac/index.md).) Follow
these steps to upgrade {{{ docsVersionInfo.k0rdentName }}}:

1. Create a new `Release` object

    Start by creating a `Release` object in the management cluster that points
	to the desired version. You can get `Release` object for the current
	version from the following URL:
	`https://get.mirantis.com/k0rdent-enterprise/{{{extra.docsVersionInfo.k0rdentDotVersion}}}/release.yaml`

	For example, this `Release` object looks like this:

    ```yaml
    apiVersion: k0rdent.mirantis.com/v1alpha1
    kind: Release
    metadata:
      name: k0rdent-enterprise-{{{ extra.docsVersionInfo.k0rdentVersion }}}
      annotations:
        helm.sh/resource-policy: keep
    spec:
      version: {{{ extra.docsVersionInfo.k0rdentDotVersion }}}
      kcm:
        template: k0rdent-enterprise-{{{ extra.docsVersionInfo.k0rdentVersion }}}
      capi:
        template: cluster-api-{{{ extra.docsVersionInfo.k0rdentVersion }}}
      providers:
        - name: cluster-api-provider-k0sproject-k0smotron
          template: cluster-api-provider-k0sproject-k0smotron-{{{ extra.docsVersionInfo.providerVersions.dashVersions.k0smotron }}}
        - name: cluster-api-provider-azure
          template: cluster-api-provider-azure-{{{ extra.docsVersionInfo.providerVersions.dashVersions.clusterApiProviderAzure }}}
        - name: cluster-api-provider-vsphere
          template: cluster-api-provider-vsphere-{{{ extra.docsVersionInfo.providerVersions.dashVersions.clusterApiProviderVsphere }}}
        - name: cluster-api-provider-aws
          template: cluster-api-provider-aws-{{{ extra.docsVersionInfo.providerVersions.dashVersions.clusterApiProviderAws }}}
        - name: cluster-api-provider-openstack
          template: cluster-api-provider-openstack-{{{ extra.docsVersionInfo.providerVersions.dashVersions.clusterApiProviderOpenstack }}}
        - name: cluster-api-provider-docker
          template: cluster-api-provider-docker-{{{ extra.docsVersionInfo.providerVersions.dashVersions.clusterApiProviderDocker }}}
        - name: cluster-api-provider-gcp
          template: cluster-api-provider-gcp-{{{ extra.docsVersionInfo.providerVersions.dashVersions.clusterApiProviderGcp }}}
        - name: cluster-api-provider-ipam
          template: cluster-api-provider-ipam-{{{ extra.docsVersionInfo.providerVersions.dashVersions.clusterApiProviderIpam }}}
        - name: cluster-api-provider-infoblox
          template: cluster-api-provider-infoblox-{{{ extra.docsVersionInfo.providerVersions.dashVersions.clusterApiProviderInfoblox }}}
        - name: projectsveltos
          template: projectsveltos-{{{ extra.docsVersionInfo.providerVersions.dashVersions.sveltosProvider }}}
    ```

    Thankfully, you don't have to build these YAML files yourself. Once you've
    chosen a release, you can go ahead and create the release object by
    referencing the YAML file online, as in:

    ```shell
    kubectl create -f https://get.mirantis.com/k0rdent-enterprise/{{{extra.docsVersionInfo.k0rdentDotVersion}}}/release.yaml
    ```
    ```console
    release.k0rdent.mirantis.com/k0rdent-enterprise-{{{ extra.docsVersionInfo.k0rdentVersion }}} created
    ```

2. List Available `Releases`

    Once you've created the new `Release` you need to update the `Management`
    object to use it. Start by viewing all available `Release`s:

    ```shell
    kubectl get releases
    ```

    ```console
    NAME        AGE
    kcm-0-0-6   71m
    kcm-0-0-7   65m
    kcm-0-1-0   6d9h
    k0rdent-enterprise-{{{ extra.docsVersionInfo.k0rdentVersion }}}   12m
    ```

3. Patch the `Management` object with the new `Release`

    Update the `spec.release` field in the `Management` object to point to the
    new release. Replace `<release-name>` with the name of your desired release:

    ```shell
    RELEASE_NAME=k0rdent-enterprise-{{{ extra.docsVersionInfo.k0rdentVersion }}}
    kubectl patch managements.k0rdent.mirantis.com kcm --patch "{\"spec\":{\"release\":\"${RELEASE_NAME}\"}}" --type=merge
    ```

4. Verify the Upgrade

    Although the change will be made immediately, it will take some time for
	{{{ docsVersionInfo.k0rdentName }}} to update the components it should be
    using. Monitor the readiness of the `Management` object to ensure the
    upgrade was successful. For example:

    ```shell
    kubectl get managements.k0rdent.mirantis.com kcm
    ```
    ```console
    NAME   READY   RELEASE     AGE
    kcm    True    k0rdent-enterprise-{{{ extra.docsVersionInfo.k0rdentVersion }}}   4m34s
    ```
