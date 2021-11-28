## OVS + OVN

**Open vSwitch(OVS)** is a High performance programmable virtual switch.
OVS is usually used to connect VMs within a host or between hosts across networks.
OVS connects to VMs via tap devices and to Containers via veth.

**Open Virtual Network (OVN)** is a series of daemons for the Open vSwitch that translate virtual network configurations into OpenFlow. OVN provides a higher-layer of abstraction than Open vSwitch, working with logical routers and logical switches, rather than flows.

**OpenFlow** is a protocol for interacting with the forwarding behaviours of switches from multiple vendors. It provides a way to control the behavior of switches throughout our network.

## OVN Architecture

OVN, is a system to support logical network abstraction in virtual machine and container environments. OVN complements the existing capabilities of OVS to add native support for logical network abstractions, such as logical L2 and L3 overlays and security groups. 

A physical network comprises physical wires, switches, and routers.
A virtual network extends a physical network into a hypervisor or container platform, bridging VMs or containers into the physical network.

An OVN logical network is a network implemented in software that is insulated from physical (and thus virtual) networks by tunnels or other encapsulations. This allows IP and other address spaces used in logical networks to overlap with those used on physical networks without causing conflicts. Logical network topologies can be arranged without regard for the topologies of the physical networks on which they run. Thus, VMs that are part of a logical network can migrate from one physical machine to another without network disruption.

The encapsulation layer prevents VMs and containers connected to a logical network from communicating with nodes on physical networks. For clustering VMs and containers, this can be acceptable or even desirable, but in many cases VMs and containers do need connectivity to physical networks. OVN provides multiple forms of gateways for this purpose.

An OVN deployment consists of several components:

Cloud Management System (CMS): integrates OVN into a physical network by managing the OVN logical network elements and connecting the OVN logical network infrastructure to physical network elements. Exmaples include OpenStack Neutron’s ml2/ovn plugin and the ovn-kubernetes project.
OVN Databases: stores data representing the OVN logical and physical networks.
Hypervisors: run Open vSwitch and translate the OVN logical network into OpenFlow on a physical or virtual machine.
Gateways: extends a tunnel-based OVN logical network into a physical network by forwarding packets between tunnels and the physical network infrastructure.
