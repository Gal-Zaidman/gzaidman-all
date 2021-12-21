# Small local K8S cluster comparison

When working with K8S it is sometimes very useful to test things in a test cluster before deploying them to the full clusters we maintain.
For that reason a number of projects poped up which allows you to setup a working K8S cluster on your local env with little to no effort.
In this blog post we will review and compare them.

## K8S

k0s is an all-inclusive Kubernetes distribution that started at early 2020 and already has a wide comunity behind it. K8S comes configured with all of the features needed to build a Kubernetes cluster and packaged as a single binary for ease of use.

- Supports different installation methods: single-node, multi-node, airgap and Docker.
- Modest system requirements (1 vCPU, 1 GB RAM).
- Vanilla upstream Kubernetes (with no changes)
- Available as a single binary with no OS dependencies besides the kernel
- Scalable from a single node to large, high-available clusters
- Supports custom Container Network Interface (CNI) plugins (Kube-Router is the default, Calico is offered as preconfigured alternative)
- Supports all Kubernetes storage options with Container Storage Interface (CSI)
- Supports a variety of datastore backends: etcd (default for multi-node clusters), SQLite (default for single node clusters), MySQL, and PostgreSQL
