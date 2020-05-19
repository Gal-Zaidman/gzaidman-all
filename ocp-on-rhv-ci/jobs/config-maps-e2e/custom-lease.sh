#!/bin/bash
set -euo pipefail

trap 'rc=$?; CHILDREN=$(jobs -p); if test -n "${CHILDREN}"; then kill ${CHILDREN} && wait; fi; if test "${rc}" -ne 0; then touch /tmp/shared/exit; fi; exit "${rc}"' EXIT

function extract_leases_info() {
  echo "$( jq ."${1}" --raw-output "${2}" )"
}

custom_lease="${CUSTOM_LEASE}"
lease_path="/etc/openshift-installer/${custom_lease}.json"

#Saving parameters for the env
cat > /tmp/shared/ovirt-lease.conf <<EOF
OVIRT_APIVIP="$(extract_leases_info ovirt_apivip ${lease_path})"
OVIRT_DNSVIP="$(extract_leases_info ovirt_dnsvip ${lease_path})"
OVIRT_INGRESSVIP="$(extract_leases_info ovirt_ingressvip ${lease_path})"
WORKER_CPU="8"
WORKER_MEM="16384"
MASTER_CPU="8"
MASTER_MEM="16384"
OCP_CLUSTER="$(extract_leases_info cluster_name ${lease_path})"
OVIRT_ENGINE_CLUSTER_ID="$(extract_leases_info ovirt_engine_cluster_id ${lease_path})"
OVIRT_ENGINE_TEMPLATE_NAME="$(extract_leases_info ovirt_engine_template_name ${lease_path})"
EOF

touch /tmp/shared/leased

while true; do
    if [[ -f /tmp/shared/exit ]]; then
        echo "Another process exited" 2>&1
        exit 0
    fi
    sleep 15 & wait $!
done
