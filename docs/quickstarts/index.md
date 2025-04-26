# Guide to QuickStarts

The following QuickStart chapters provide a recipe for quickly installing and trying {{{ docsVersionInfo.k0rdentName }}}. Setting up {{{ docsVersionInfo.k0rdentName }}} for production is detailed in the [Administrator Guide](../admin/index.md).

## What the QuickStart covers

The QuickStart section explains:

* Getting a working environment set up for managing {{{ docsVersionInfo.k0rdentName }}}.
* Setting up a minimal Kubernetes cluster (management cluster) plus requirements to host {{{ docsVersionInfo.k0rdentName }}} itself.
* Selecting a cloud environment (AWS or Azure) and configuring {{{ docsVersionInfo.k0rdentName }}} to lifecycle manage clusters on this substrate.
* Using {{{ docsVersionInfo.k0rdentName }}} to deploy a managed cluster.
* (Optional stretch goal) Setting up the {{{ docsVersionInfo.k0rdentName }}} management cluster to simultaneously lifecycle manage clusters on _both_ cloud environments.

## QuickStart Prerequisites

QuickStart prerequisites are simple &mdash; you'll need:

* A desktop or virtual machine running a [supported version of linux](#supported-operating-systems). You'll use this machine to install a basic Kubernetes working environment, and to host a single-node k0s Kubernetes management cluster to host {{{ docsVersionInfo.k0rdentName }}} components. For simplest setup, configure this machine as follows:
    * A minimum of 8GB RAM, 4 vCPUs, 100GB SSD (for example, AWS `t2.xlarge` or equivalent)
    * Set up for SSH access using keys (standard for cloud VMs)
    * Set up for passwordless sudo (that is, edit `/etc/sudoers` to configure your user to issue `sudo` commands without a password challenge)
    * Inbound traffic: SSH (port 22) and ping from your laptop's IP address
    * Outbound traffic: All to any IP address
    * Apply all recent updates and upgrade local applications (`sudo apt update`/`sudo apt upgrade`)
    * (Optional) snapshot the machine in its virgin state
* Administrative-level access to an AWS or Azure cloud account, depending on which cloud environment you prefer. {{{ docsVersionInfo.k0rdentName }}} will leverage this cloud to provide infrastructure for hosting child clusters.

### Supported Operating Systems

Any linux based OS that supports deploying [k0s](https://k0sproject.io/) will work, though you may need to adjust the suggested commands.


| OS | Package Manager | Link|
|----|-----------------|-----|
|Ubuntu Server| `apt` | [22.04.5 LTS, Jammy Jellyfish](https://releases.ubuntu.com/jammy/) |

> NOTE: 
> Other recent versions of 'enterprise' Linux should work with the
> following instructions as well, though you will need to adapt for
> different package managers and perhaps use slightly-different
> provider-recommended methods for installing required dependencies
> (for example, Helm). Once you've installed {{{ docsVersionInfo.k0rdentName }}} in the management cluster
> and have kubectl, Helm, and other resources connected, you'll mostly
> be dealing with Kubernetes, and everything should work the same way on
> any host OS.

## Limitations

This QuickStart guides you in quickly creating a minimal {{{ docsVersionInfo.k0rdentName }}} working environment. As mentioned earlier, setting up {{{ docsVersionInfo.k0rdentName }}} for production is detailed in the [Administrator Guide](../admin/index.md).

The current QuickStart focuses on AWS and Azure cloud environments, and guides in creating 'standalone' clusters. In {{{ docsVersionInfo.k0rdentName }}} parlance, that means 'CNCF-certified Kubernetes clusters with control planes and workers hosted on cloud virtual machines.' The 'CNCF-certified Kubernetes cluster' (in this case) is the [k0s Kubernetes distro](https://k0sproject.io).

Next you'll want to learn how to:

- [Set up the Management Node and Cluster](quickstart-1-mgmt-node-and-cluster.md)
- [Configure and Deploy to AWS](quickstart-2-aws.md)
- [Configure and Deploy to Azure](quickstart-2-azure.md)
- [Configure and Deploy on any SSH-accessible Linux hosts](quickstart-2-remote.md)
- [Configure and Deploy to GCP](quickstart-2-gcp.md)
