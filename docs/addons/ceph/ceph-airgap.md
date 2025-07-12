# Ceph in an Airgapped Environment

If you are operating in an airgapped environment, you cannot use the typical k0rdent Enterprise Catalog installation, but you can install Ceph manually by following these instructions.

## Prerequisites

Make sure you have the following software installed before beginning Ceph installation:

* skopeo 1.6.1 or later 
* Offline registry for uploading/downloading images. This offline registry must use HTTPS, and the TLS certificates should be trusted on all nodes. The registry must be accessible from the airgapped environment.

## Preparation

Follow these steps to prepare for Ceph installation.

1. From a non-airgapped system, download the offline Ceph bundle:

    ```shell
    curl -L https://binary-mirantis-com.s3.amazonaws.com/ceph/bundles/airgap-bundle-ceph-1.0.11.tar.gz -o airgap-bundle-ceph-1.0.12.tar.gz
    ```

2. Copy the downloaded file to the airgapped environment

3. Upload the images and charts to the registry.

    On the node with access to the registry, set up the following ENV variables:

    ```shell
    export REGISTRY_ADDRESS='<registry_address>'
    export REGISTRY_USERNAME='<username>'
    export REGISTRY_PASSWORD='<password>'
    export BUNDLE_NAME='airgap-bundle-ceph-<version>.tar.gz'
    ```

    For example:

    ```shell
    export REGISTRY_ADDRESS='10.98.15.193:5000'
    export REGISTRY_USERNAME='user'
    export REGISTRY_PASSWORD='pass'
    export BUNDLE_NAME='airgap-bundle-ceph-1.0.12.tar.gz'
    ```

4. Execute the following script:

    ```shell
    #!/usr/bin/env bash
    set -ex


    if [[ -z "$REGISTRY_ADDRESS" ]]; then
    echo "Must provide REGISTRY_ADDRESS in environment" 1>&2
    exit 1
    fi
    if [[ -z "$REGISTRY_USERNAME" ]]; then
    echo "Must provide REGISTRY_USERNAME in environment" 1>&2
    exit 1
    fi
    if [[ -z "$REGISTRY_PASSWORD" ]]; then
    echo "Must provide REGISTRY_PASSWORD in environment" 1>&2
    exit 1
    fi


    if ! [ -x "$(command -v skopeo)" ]; then
    echo 'Error: skopeo is not installed.' >&2
    exit 1
    fi


    BUNDLE_NAME=${BUNDLE_NAME:-"airgap-bundle-ceph.tar.gz"}
    REGISTRY_PROJECT_PATH=ceph
    REGISTRY_TLS_VERIFY=${REGISTRY_TLS_VERIFY:-"true"}


    # Login to the registry
    skopeo login "$REGISTRY_ADDRESS" -u "$REGISTRY_USERNAME" -p "$REGISTRY_PASSWORD" --tls-verify=$REGISTRY_TLS_VERIFY


    # Extract the bundle
    mkdir -p ./bundle
    tar -xzf "$BUNDLE_NAME" -C ./bundle
    
    # Iterate over bundle artifacts and upload each one using skopeo
    for archive in $(find ./bundle -print | grep ".tar"); do
        # Form the image name from the archive name
        img=$(basename "$archive" | sed 's~\.tar~~' | tr '&' '/' | tr '@' ':'| cut -d "/" -f 3-);
        echo "Uploading $img";
        # Copy artifact from local oci archive to the registry
        skopeo copy --dest-tls-verify=$REGISTRY_TLS_VERIFY -q "oci-archive:$archive" "docker://$REGISTRY_ADDRESS/$REGISTRY_PROJECT_PATH/$img";
    done;

    rm -r ./bundle || true
    ```

## Installation

1. Setup the Ceph `ServiceTemplate` from the registry:

    ```shell
    helm install ceph-controller-1-0-12 oci://${REGISTRY_ADDRESS}/k0rdent-enterprise-catalog/ceph-controller-service-template --version 1.0.12 -n kcm-system –-set helmRepository.url=oci://${REGISTRY_ADDRESS}/ceph
    ```

2. Edit the `ClusterDeployment` to enable Ceph as usual, but but add the docker images repository value:

    ```yaml
    ...
    spec:
    serviceSpec:
        services:
        ...
        - name: ceph
        namespace: ceph-lcm-mirantis
        template: ceph-controller-1-0-12
        values: |
            ceph-operator:
                global:
                    dockerBaseUrl: ${REGISTRY_ADDRESS}
                rookExtraConfig:
                    csiKubeletPath: /var/lib/k0s/kubelet
                controllers:
                    cephMaintenance:
                        enabled: false
                installNamespaces: false
    ```

3. From here, you can pick up from step 3 from the usual [Ceph installation](https://docs.k0rdent-enterprise.io/v1.0.0/addons/ceph/ceph-install/#ceph-deployment-on-k0rdent).
