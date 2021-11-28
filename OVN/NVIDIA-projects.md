# Nvidia Projects

## Nvidia Network Operator

The Nvidia Network Operator leverages manage Networking related Components in order to enable Fast networking, RDMA and GPUDirect for workloads in a Kubernetes cluster.

https://github.com/Mellanox/network-operator

### CRDS

#### NICClusterPolicy CRD

defines a Cluster state for Mellanox Network devices:

- ofedDriver: OFED driver container* to be deployed on Mellanox supporting nodes
- rdmaSharedDevicePlugin: RDMA shared device plugin and related configurations.
- nvPeerDriver: Nvidia Peer Memory client driver container to be deployed on RDMA & GPU supporting nodes (required for GPUDirect workloads).
- SecondaryNetwork: Specifies components to deploy in order to facilitate a secondary network in Kubernetes. (Multus-CNI, CNI plugins, IPAM CNI)

* Driver containers are containers that allow provisioning of a driver on the host.

#### MacvlanNetwork CRD

defines a MacVlan secondary network. It is translated by the Operator to a NetworkAttachmentDefinition instance.

- networkNamespace: Namespace for NetworkAttachmentDefinition related to this MacvlanNetwork CRD.
- master: Name of the host interface to enslave. Defaults to default route interface.
- mode: Mode of interface one of "bridge", "private", "vepa", "passthru", default "bridge".
- mtu: Maximum Transmission UnIT(MTU) of interface to the specified value. 0 for master's MTU.
- ipam: IPAM configuration to be used for this network.

#### HostDeviceNetwork CRD

defines a HostDevice secondary network. It is translated by the Operator to a NetworkAttachmentDefinition instance.

- networkNamespace: Namespace for NetworkAttachmentDefinition related to this HostDeviceNetwork CRD.
- ResourceName: Host device resource pool.
- ipam: IPAM configuration to be used for this network.
