#!/bin/bash
trap 'rc=$?;  touch /tmp/shared/02_tests.done ; exit "${rc}"' EXIT
trap 'CHILDREN=$(jobs -p); if test -n "${CHILDREN}"; then kill ${CHILDREN} && wait; fi' TERM

set -euo pipefail
echo "waiting for installation to complete..."
while true; do
    if [[ -f /tmp/shared/01_install.done ]]; then
        break
    fi
    sleep 20 & wait
done

echo "beginnging testing..."

export KUBECONFIG=/tmp/shared/artifacts/installer/auth/kubeconfig

mkdir -p /tmp/shared/artifacts/junit/

if [ ! -f $KUBECONFIG ] ; then
    echo -e "Couldnt find KUBECONFIG at $KUBECONFIG"
    exit 22
fi

openshift-tests run openshift/conformance/parallel --dry-run | grep 'Early' | openshift-tests run -o /tmp/shared/artifacts/e2e.log --junit-dir /tmp/shared/artifacts/junit/ -f -