# How-to-update-machine-config.md

**Taken from https://jaosorior.dev/2019/modifying-node-configurations-in-openshift-4.x**

OpenShift 4.X relies heavily on operators in order to configure… just about everything. This includes the configuration of the hosts that run the OpenShift installation. In order to configure the aforementioned hosts, the installation comes with a running instance of the “machine-config-operator”, which is an operator that applies host configurations and restarts the host whenever it detects configuration changes.

### Prerequisites
The machine-config-operator gives us a construct named MachineConfig, which allows us to apply configuration changes to specific files and to specific roles.

### What are these roles?

Well, the machine-config-operator works with so called MachineConfigPools which are sets of nodes that have a specific role in your system. Most likely these nodes will run different services, and serve different purposes.

To view all of the roles in your system, do:

``` bash
oc get machineconfigpools
NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED
master   rendered-master-f0718d88f154089eae3b199e387696d4   True      False      False
worker   rendered-worker-3c907e9ae475284d33eadfa3bc6117a5   True      False      False
```

The main thing to note here are the names of the roles.

The content in our MachineConfig definition need URL encoding .

For this, we can use the following snippet:

```python
cat example-chrony.conf | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(''.join(sys.stdin.readlines())))"
```

This will give us the following output:

```bash
server%200.fedora.pool.ntp.org%0Aserver%201.fedora.pool.ntp.org%0Aserver%202.fedora.pool.ntp.org%0Adriftfile%20/var/lib/chrony/drift%0Amakestep%201.0%203%0Artcsync%0Akeyfile%20/etc/chrony.keys%0Aleapsectz%20right/UTC%0Alogdir%20/var/log/chrony%0A
```

With this in mind, lets apply the aforementioned configuration!

1. create a file with the content:

```yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 50-worker-chrony
spec:
  config:
    ignition:
      version: 2.2.0
    storage:
      files:
      - contents:
          source: {URL ENCODED DATA}
        filesystem: root
        mode: 0644
        path: /etc/chrony.conf
```

We’ll call this yaml file chrony-enable-worker.yaml.

Note that we specified the role via the machineconfiguration.openshift.io/role label in the MachineConfig’s metadata. We also gave it a name that reflects the application order (50 will be applied in the middle), the role’s name, and the configuration we’re applying.

Lets see all of the MachineConfig objects that are currently applied to our system:

```bash
$ oc get machineconfigs

NAME                                                        GENERATEDBYCONTROLLER               IGNITIONVERSION   CREATED
00-master                                                   4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
00-worker                                                   4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
01-master-container-runtime                                 4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
01-master-kubelet                                           4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
01-worker-container-runtime                                 4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
01-worker-kubelet                                           4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
99-master-1f70153f-6a5e-11e9-ae85-021543e42872-registries   4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
99-master-ssh                                                                                   2.2.0             72m
99-worker-1f718afb-6a5e-11e9-ae85-021543e42872-registries   4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
99-worker-ssh                                                                                   2.2.0             72m
rendered-master-f0718d88f154089eae3b199e387696d4            4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
rendered-worker-591c18e125b4a536c8574ca84da362f6            4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             71m
Lets now apply our configuration

oc apply -f chrony-enable-worker.yaml

NAME                                                        GENERATEDBYCONTROLLER               IGNITIONVERSION   CREATED
00-master                                                   4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             72m
00-worker                                                   4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             72m
01-master-container-runtime                                 4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             72m
01-master-kubelet                                           4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             72m
01-worker-container-runtime                                 4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             72m
01-worker-kubelet                                           4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             72m
50-worker-chrony                                                                                2.2.0             13s
99-master-1f70153f-6a5e-11e9-ae85-021543e42872-registries   4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             73m
99-master-ssh                                                                                   2.2.0             73m
99-worker-1f718afb-6a5e-11e9-ae85-021543e42872-registries   4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             73m
99-worker-ssh                                                                                   2.2.0             73m
rendered-master-f0718d88f154089eae3b199e387696d4            4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             72m
rendered-worker-591c18e125b4a536c8574ca84da362f6            4.0.0-alpha.0-269-g0ae25d4c-dirty   2.2.0             72m
```

If we want to apply the configuration to other hosts, we’ll need a MachineConfig object per-role.

### The ultimate source of truth

Another feature of the machine-config-operator, is that it allows you to query an aggregated structure with all of the configurations that have been rendered into the host.

Remember the output of getting the MachineConfigPools? Lets get it again:

```bash
oc get machineconfigpools

NAME     CONFIG                                             UPDATED   UPDATING   DEGRADED
master   rendered-master-f8b48d03fe36cf056b547e294deafb44   True      False      False
worker   rendered-worker-3c907e9ae475284d33eadfa3bc6117a5   True      False      False
You will note two things:
```

The items under the CONFIG column, are MachineConfig objects that you can query from the system.

The keys under CONFIG changed from last time we checked! This was because there is a new rendering, since we applied the new chronyd configuration.

To look at the render, we can do the following:

oc get machineconfig/rendered-worker-3c907e9ae475284d33eadfa3bc6117a5 -o yaml
This will show us a yaml representation of all of the configurations that have been applied to that role.

tags: openshift

