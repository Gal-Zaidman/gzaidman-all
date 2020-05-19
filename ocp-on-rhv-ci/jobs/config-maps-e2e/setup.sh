#!/bin/sh
trap 'rc=$?; if test "${rc}" -eq 0; then touch /tmp/shared/01_install.done; else touch /tmp/shared/01_install.exit; fi; exit "${rc}"' EXIT
trap 'CHILDREN=$(jobs -p); if test -n "${CHILDREN}"; then kill ${CHILDREN} && wait; fi' TERM

## Wait untill lease is acquired
while true; do
    if [[ -f /tmp/shared/exit ]]; then
        echo "Another process exited" 2>&1
        exit 1
    fi
    if [[ -f /tmp/shared/leased ]]; then
        echo "Lease acquired, installing..."
        break
    fi
    sleep 15 & wait
done

cp "$(command -v openshift-install)" /tmp/shared
mkdir -p /tmp/shared/artifacts/installer

## update the IDs for new cluster
source /tmp/shared/ovirt-lease.conf
source /etc/openshift-installer/ovirt.conf

export PATH=$PATH:/tmp/shared
export EXPIRATION_DATE=$(date -d '4 hours' --iso=minutes --utc)
export SSH_PUB_KEY=$(cat "${SSH_PUB_KEY_PATH}")
export PULL_SECRET=$(cat "${PULL_SECRET_PATH}")
export TF_VAR_ovirt_template_mem=${WORKER_MEM}
export TF_VAR_ovirt_template_cpu=${WORKER_CPU}
export TF_VAR_ovirt_master_mem=${MASTER_MEM}
export TF_VAR_ovirt_master_cpu=${MASTER_CPU}

## Image handling - for now the CI uses a fixed rhcos template
## TODO - the fixed template is saving time and space when creating the
## cluster in the cost of having to maitain the supported version. This
## maintnance procedure does not exist yet.
export OPENSHIFT_INSTALL_OS_IMAGE_OVERRIDE=${OVIRT_ENGINE_TEMPLATE_NAME}

# We want the setup to download the latest CA from the engine
# Therefor living it empty
export OVIRT_CONFIG=/tmp/shared/artifacts/installer/ovirt-config.yaml
cat > /tmp/shared/artifacts/installer/ovirt-config.yaml <<EOF
ovirt_url: ${OVIRT_ENGINE_URL}
ovirt_username: ${OVIRT_ENGINE_USERNAME}
ovirt_password: ${OVIRT_ENGINE_PASSWORD}
ovirt_cafile: ""
ovirt_insecure: true
EOF

cat > /tmp/shared/artifacts/installer/install-config.yaml << EOF
apiVersion: v1
baseDomain: ${BASE_DOMAIN}
metadata:
  name: ${OCP_CLUSTER}
compute:
- hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 2
controlPlane:
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
platform:
  ovirt:
    ovirt_cluster_id: ${OVIRT_ENGINE_CLUSTER_ID}
    ovirt_storage_domain_id: ${OVIRT_ENGINE_STORAGE_DOMAIN_ID}
    api_vip: ${OVIRT_APIVIP}
    dns_vip: ${OVIRT_DNSVIP}
    ingress_vip: ${OVIRT_INGRESSVIP}
pullSecret: >
  ${PULL_SECRET}
sshKey: |
  ${SSH_PUB_KEY}
EOF

function update_image_registry() {
  while true; do
    sleep 10;
    oc get configs.imageregistry.operator.openshift.io/cluster >/dev/null 2>&1 && break
  done
  oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"managementState":"Managed","storage":{"emptyDir":{}}}}'
}

cd /tmp/shared/artifacts

#download oc if missing
if [ ! -f oc ] ; then
    echo "downloading oc binary"
    wget https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.5/linux/oc.tar.gz -O oc.tar.gz
    tar xvfz oc.tar.gz
    chmod +x ./oc
fi
export PATH=$PATH:/tmp/shared/artifacts

TF_LOG=debug openshift-install --dir=/tmp/shared/artifacts/installer create ignition-configs --log-level=debug
python -c \
    'import json, sys; j = json.load(sys.stdin); j[u"systemd"][u"units"] = [{u"contents": "[Unit]\nDescription=Mount etcd as a ramdisk\nBefore=local-fs.target\n[Mount]\n What=none\nWhere=/var/lib/etcd\nType=tmpfs\nOptions=size=2G\n[Install]\nWantedBy=local-fs.target", u"enabled": True, u"name":u"var-lib-etcd.mount"}]; json.dump(j, sys.stdout)' \
    </tmp/shared/artifacts/installer/master.ign \
    >/tmp/shared/artifacts/installer/master.ign.out
mv /tmp/shared/artifacts/installer/master.ign.out /tmp/shared/artifacts/installer/master.ign

export KUBECONFIG=/tmp/shared/artifacts/installer/auth/kubeconfig
update_image_registry &

# What we're doing here is we generate manifests first and force that OpenShift SDN is configured.
TF_LOG=debug openshift-install --dir=/tmp/shared/artifacts/installer create manifests --log-level=debug
echo "done with manifests"
sed -i '/^  channel:/d' /tmp/artifacts/installer/manifests/cvo-overrides.yaml
# This is for debugging purposes, allows us to map a job to a VM
cat /tmp/artifacts/installer/manifests/cluster-infrastructure-02-config.yml
export KUBECONFIG=/tmp/artifacts/installer/auth/kubeconfig
update_image_registry &

TF_LOG=debug openshift-install --dir=/tmp/shared/artifacts/installer create cluster --log-level=debug &
