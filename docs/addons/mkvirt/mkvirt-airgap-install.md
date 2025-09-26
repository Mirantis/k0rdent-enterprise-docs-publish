# How-To Deploy Mirantis k0rdent Virtualization on an airgapped {{{ docsVersionInfo.k0rdentName }}} Environment

In an airgapped setup, you can't just rely on pulling images or spinning up extra platforms when you need them. Everything has to live inside the environment, and maintaining both a Kubernetes cluster and a separate virtualization stack is extra overhead you don't want. With Mirantis k0rdent Virtualization, you can run your VMs right inside Kubernetes, so you only manage one system. That's a big deal when every update, patch, or image has to be staged by hand instead of fetched from the internet.

Airgapped environments also tend to come with strict security and compliance rules. Some workloads still need VMs for isolation or because they can't be containerized, but you still want them governed by the same policies and tooling as the rest of the cluster. Mirantis k0rdent Virtualization gives you the option to keep VMs and containers in one place, fully under local control, so you can keep legacy apps and sensitive workloads running without needing external connectivity.

Follow these steps to install Mirantis k0rdent Virtualization in an airgapped {{{ docsVersionInfo.k0rdentName }}} environment.

## Prerequisites

Make sure the following requirements are in place before beginning the installation:

* Offline registry for uploading/downloading images. This offline registry must use HTTPS, and the TLS certificates should be trusted on all nodes. The registry must be accessible from the airgapped environment.
* [skopeo](https://github.com/containers/skopeo) 1.6.1 or later, to enable upload/download of images to/from the offline registry.

## Preparation

Follow these steps to prepare for Mirantis k0rdent Virtualization offline install:

1.  From a non-airgapped system, download the offline bundle:    

     ```bash
     curl -L https://binary-mirantis-com.s3.amazonaws.com/kubevirt/bin/artifacts/airgap-bundle-hco-1.15.0-mira.tar.gz -o airgap-bundle-hco-1.16.0-mira.tar.gz 
     ```

2.  Upload the bundle to a node that is accessible from the airgapped registry.

3.  Prepare the registry environment:
    
     On the node with access to registry, set up the following ENV variables:

     ```bash
     export REGISTRY_ADDRESS='<registry_address>'
     export REGISTRY_PROJECT_PATH='<registry-path>'
     export REGISTRY_USERNAME='<username>'
     export REGISTRY_PASSWORD='<password>'
     export AIRGAP_BUNDLE_FILE='airgap-bundle-hco-<version>.tar.gz'
     ```

     For example:

     ```bash
     REGISTRY_ADDRESS=10.96.128.68:5000
     REGISTRY_PROJECT_PATH=kubevirt
     AIRGAP_BUNDLE_FILE=airgap-bundle-hco-1.16.0-mira.tar.gz
     ```

4. Execute the following script:

     ```bash
     #!/usr/bin/env bash
     set -ex
     
     # Login to the registry
     docker login "$REGISTRY_ADDRESS" -u "$REGISTRY_USERNAME" -p "$REGISTRY_PASSWORD" && \

     # Extract the bundle
     tar -xzf "$AIRGAP_BUNDLE_FILE" -C ./bundle

     # Iterate over bundle artifacts and upload each one using skopeo
     for archive in $(find ./bundle -print | grep ".tar"); do
 
       # Form the image name from the archive name
       img=$(basename "$archive" | sed 's~\.tar~~' | tr '&' '/' | tr '@' ':'| cut -d "/" -f 3);
       echo "Uploading $img";

       # Copy artifact from local oci archive to the registry
       skopeo copy -q "oci-archive:$archive" "docker://$REGISTRY_ADDRESS/$REGISTRY_PROJECT_PATH/$img";

     done;
     ```

## Installation:

Follow these steps to complete the installation.

1.  Set up `helm hco-service-template` from the registry:    

     ```bash
     helm install hco-service-template oci://${REGISTRY_ADDRESS}/${REGISTRY_PROJECT_PATH}/hco-service-template --version {{{ docsVersionInfo.addonVersions.dotVersions.hco}}} -n kcm-system –-set helmRepository.url=oci://${REGISTRY_ADDRESS}/${REGISTRY_PROJECT_PATH}
     ```

2.  Continue from step 2 of the [Mirantis k0rdent Virtualization installation guide](mkvirt-install.md).