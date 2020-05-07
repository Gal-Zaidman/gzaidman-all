#!/bin/bash

create_hosted_engine_vm(){
    name="${1:=hosted_engine}"
    mem="${2:=6096}"
    cpus="${3:=2}"
    network="${4:=he-localvms}"
    mac="${5:=52:54:00:45:ca:92}"
    iso_path="${6:=/tmp/path_to_iso.iso}"
    disk_size="${7:=60}"
    sudo virt-install --name ${name} --memory ${mem} --vcpus ${cpus} --network network=${network},mac=${mac} --cdrom=${iso_path} --disk size=${disk_size}
}

vm_ip="192.168.100.103"
my_ip="192.168.100.1"
# Flow
create_hosted_engine_vm
ssh "root@${vm_ip}"
# Mount cockpit ovirt
mv "/usr/share/cockpit/ovirt-dashboard/" "/usr/share/cockpit/ovirt-dashboard.backup/""
mkdir /cockpit-ovirt
cat "${my_ip}:/home/gzaidman/workspace/upstream/cockpit-ovirt nfs rw 0 0"
mount -a
ln -s "/cockpit-ovirt/dashboard/dist" "/usr/share/cockpit/ovirt-dashboard/""
# Add the ovirt-release
