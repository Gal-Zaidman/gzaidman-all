#!/bin/bash
set -euo pipefail

trap 'rc=$?; CHILDREN=$(jobs -p); if test -n "${CHILDREN}"; then kill ${CHILDREN} && wait; fi; if test "${rc}" -ne 0; then touch /tmp/shared/exit; fi; exit "${rc}"' EXIT

# hack for bazel
function boskosctl() {
/app/boskos/cmd/cli/app.binary "${@}"
}

# Function to extract the lease resources
function extract_leases_info() {
echo "$( jq ."${1}" --raw-output "${2}" )"
}

function acquire_lease() {
  resource="$( boskosctl --server-url http://boskos.ci --owner-name "${CLUSTER_NAME}" acquire --type "${CLUSTER_TYPE}-quota-slice" --state "free" --target-state "leased" --timeout 150m )"
  resource_name="$(echo "${resource}"|jq .name --raw-output)"
  echo "[INFO] Lease acquired! at $(date --utc)"
  echo "[INFO] Leased resource: ${resource}"
  lease_path="/etc/openshift-installer/${resource_name}.json"
  ovirt_engine_template_name="$(extract_leases_info ovirt_engine_template_name ${lease_path})"
  echo "[INFO] Sending heartbeats to retain the lease ${resource_name}"
  boskosctl --server-url http://boskos.ci --owner-name "${CLUSTER_NAME}" heartbeat --resource "${resource}" &
  heartbeats_pid=$!
  if [ "${LEASE_TYPE}" == "conformance" ]; then
    bm_name="$(extract_leases_info ovirt_engine_cluster_bm ${lease_path})"
    conformance_resource="$( boskosctl --server-url http://boskos.ci --owner-name "${CLUSTER_NAME}" acquire --type "${CLUSTER_TYPE}-${bm_name}" --state "free" --target-state "leased" --timeout 150m )"
    conformance_resource_name="$(echo "${conformance_resource}"|jq .name --raw-output)"
    echo "[INFO] Conformance Lease acquired! at $(date --utc)"
    echo "[INFO] Conformance Leased resource: ${conformance_resource}"
    boskosctl --server-url http://boskos.ci --owner-name "${CLUSTER_NAME}" heartbeat --resource "${conformance_resource}" &
    conformance_heartbeats_pid=$!
    echo "[INFO] Sending heartbeats to retain the lease ${conformance_resource_name}"
    worker_cpu=8
    worker_mem=16384
    master_cpu=8
    master_mem=16384
  else
    ovirt_engine_template_name="${ovirt_engine_template_name}-8G"
    worker_cpu=4
    worker_mem=8192
    master_cpu=4
    master_mem=8192
  fi
}

function release() {
  echo "killing heartbeat process "${heartbeats_pid}" at $(date --utc)"
  kill -9 "${heartbeats_pid}"
  echo "[INFO] Releasing the lease on resouce ${resource_name}"
  boskosctl --server-url http://boskos.ci --owner-name "${CLUSTER_NAME}" release --name "${resource_name}" --target-state "free"
  if [ "${LEASE_TYPE}" == "conformance" ]; then
    echo "killing conformance heartbeats process "${conformance_heartbeats_pid}" at $(date --utc)"
    kill -9 "${conformance_heartbeats_pid}"
    echo "[INFO] Releasing the lease on resouce ${conformance_resource_name}"
    boskosctl --server-url http://boskos.ci --owner-name "${CLUSTER_NAME}" release --name "${conformance_resource_name}" --target-state "free"
  fi
}

echo "[INFO] Acquiring a lease ..."
acquire_lease

#Saving parameters for the env
cat > /tmp/shared/ovirt-lease.conf <<EOF
OVIRT_APIVIP="$(extract_leases_info ovirt_apivip ${lease_path})"
OVIRT_DNSVIP="$(extract_leases_info ovirt_dnsvip ${lease_path})"
OVIRT_INGRESSVIP="$(extract_leases_info ovirt_ingressvip ${lease_path})"
WORKER_CPU="${worker_cpu}"
WORKER_MEM="${worker_mem}"
MASTER_CPU="${master_cpu}"
MASTER_MEM="${master_mem}"
OCP_CLUSTER="$(extract_leases_info cluster_name ${lease_path})"
OVIRT_ENGINE_CLUSTER_ID="$(extract_leases_info ovirt_engine_cluster_id ${lease_path})"
OVIRT_ENGINE_TEMPLATE_NAME="${ovirt_engine_template_name}"
EOF

touch /tmp/shared/leased

trap "release" EXIT
trap "release" TERM

while true; do
  if [[ -f /tmp/shared/exit ]]; then
    echo "Another process exited" 2>&1
    exit 0
  fi
  sleep 15 & wait $!
done
