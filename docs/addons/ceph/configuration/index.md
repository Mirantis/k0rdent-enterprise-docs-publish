# Ceph Cluster Configuration

This document describes how to configure a Ceph cluster using the **MiraCeph** object. MiraCeph must always be created under the `ceph-lcm-mirantis` namespace—the base controllers namespace—and is processed by the Ceph Controller pod and its ceph-controller container.

MiraCeph consists of two main sections: **spec** and **status**.