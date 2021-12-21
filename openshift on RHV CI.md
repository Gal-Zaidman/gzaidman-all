# OpenShift on RHV CI

## Why

Openshift needs to run jobs against a RHV engine to make sure that the RHV installation flow hasn't been broken and to detect bugs during development.
To achive that Openshift needs an **Upstream** (meaning available outside the RH VPN) oVirt engine that it can ran jobs against.

## How

### How the CI infrastructure is built

![](2021-11-22-11-56-55.png)

#### Ovirt Engine

The oVirt engine can be found here: https://ovirt-engine.ocp-on-ovirt.gcp.devcluster.openshift.com
The engine runs on a VM instance in IBM, only Evgheni Dereveanchin and his team have permissions to manage it.
Evgeny Slutsky is responsible for the general maintance of the engine VM.

#### Hosts

We have 10 BM IBM hosts in our CI to run all of our jobs:
1. baremetal01 (baremetal01.ocp-on-ovirt.gcp.devcluster.openshift.com)
2. baremetal04 (baremetal04.ocp-on-ovirt.gcp.devcluster.openshift.com)
3. baremetal06 (baremetal06.ocp-on-ovirt.gcp.devcluster.openshift.com)
4. baremetal07 (baremetal07.ocp-on-ovirt.gcp.devcluster.openshift.com)
5. baremetal08 (baremetal08.ocp-on-ovirt.gcp.devcluster.openshift.com)
6. baremetal09 (baremetal09.ocp-on-ovirt.gcp.devcluster.openshift.com)
7. baremetal10 (baremetal10.ocp-on-ovirt.gcp.devcluster.openshift.com)
8. baremetal11 (baremetal11.ocp-on-ovirt.gcp.devcluster.openshift.com)
9. baremetal12 (baremetal12.ocp-on-ovirt.gcp.devcluster.openshift.com)
10. baremetal13 (baremetal13.ocp-on-ovirt.gcp.devcluster.openshift.com)

Each host has 96GB mem and 96 cores, and we are using 150% memory overcommit in our cluster which means the the CI has a total of 96\*10\*1.5=1440gb=1.4TB.
Since each openshift cluster is 80 GB, assuming we don't want to consume all the overcommited memory (lets leave 150GB) we can run (1440-150)/80 =~16 openshift clusters in parallel.

#### Proxy VM

The Proxy VM is the heart of the CI in the OCP on RHV setup, it serves as the Router, DHCP, NAT, and DNS of the openshift clusters.
The proxy VM has one extrnal nic (ovirtmgmt) and one nic for each ovn network, meaning each Openshift cluster network.
When you log into the proxy VM you can see:
- the DNS config for each network in the /var/lib/dnsmasq/dnsmasq-net-XX.conf file.
- the haproxy config file: /etc/haproxy/haproxy.cfg

more can be found in the [ansible role](https://github.com/oVirt/ocp-on-ovirt/tree/master/ocp-on-rhv-ci/deploy-infra-env/roles/ocp-rhv-proxy-vm).

#### DNS records

All of our DNS records are hosted in the Openshift GCP account under the gcp.devcluster.openshift.com domain.
To change them you will need to loginto the Openshift GCP instance and edit them.

#### CI Leases

We need CI Leases to make sure we are not overwelming the oVirt engine with jobs that it doesn't have resources to handle, and also to give a specifc job certain information which it requires to run.
Our leases configuration can be found on [boskos.yaml](https://github.com/openshift/release/blob/master/core-services/prow/02_config/_boskos.yaml#L789-L814)
The `ovirt-quota-slice` is a general lease that is needed for each job, it marks a deticated hardware which will be saved for the job, it is required by each job implicitly by stating that the `cluster_profile` is equal to ovirt, for example [here](https://github.com/openshift/release/blob/master/ci-operator/config/openshift/cluster-api-provider-ovirt/openshift-cluster-api-provider-ovirt-master.yaml#L50), see more info on job and leases configuration on the Doc, [Link](https://docs.ci.openshift.org/docs/architecture/step-registry/#implicit-lease-configuration-with-cluster_profile)
The `ovirt-upgrade-quota-slice` is a lease which is specific for upgrade jobs, it is required by each job and represents a storage domain which would be deticated for the upgrade job.
it is required by each upgrade job explicity here [Link](https://github.com/openshift/release/blob/master/ci-operator/step-registry/openshift/upgrade/ovirt/openshift-upgrade-ovirt-workflow.yaml#L17-L19)
It is requested explicity here, see more info on explicit job and leases configuration on the Doc, [Link](https://docs.ci.openshift.org/docs/architecture/step-registry/#explicit-lease-configuration)

For more info on CI leases see Docs, [Link](https://docs.ci.openshift.org/docs/arcitecture/quota-and-leases/)

Example of a PR for adding leases, [link](https://github.com/openshift/release/pull/21310/files)
Example of a PR for adding a new lease, [link](https://github.com/openshift/release/pull/21069/files)

#### CI Secrets

We need CI Secrets to give a Job sensative data like credentials and pull secret for it to actually run against our oVirt engine, and it is very important to us that the sensative data will only be available for the job.
The is why Openshift CI maintains a Vault istance for us, we can store all of our sensative data in the Vault, and that sensative data will be available to our jobs.
The vault instance address is vault.ci.openshift.org, you need to use the OIDC auth to log in there. After logging in, click on kv, then selfservice and you should see the oVirt secret collection.
Currently we use the "cluster-secrets-ovirt" collection, were we keep:
1. Specific lease files in the form of ovirt-XX.json:
Each lease file coresponds to a secifc CI lease, when a job starts it gets a lease out of the pool of leases, and we use the lease name to select the file from the secrets.
The file contains information for a specific job like the api-vip to use or the cluster name it should have, those fields are uniqe for each lease and corespond to existing infrastructure in the oVirt engine and proxy VM.
For example a CI job start and it gets the "ovirt-10" lease then it will get the information from the ovirt-10.json file.

The job step that extracts the info from the secert is here, [Link](https://github.com/openshift/release/blob/master/ci-operator/step-registry/ipi/conf/ovirt/generate-install-config-params/ipi-conf-ovirt-generate-install-config-params-commands.sh)

2. Upgrade jobs lease files in the form of ovirt-upgrade-X.json:
For each upgrade job we have a seperate storage domain, this was required due to the fact that upgrade jobs need persistant storage to function and run etcd on as opposed to regular jobs which can use emptyDir for etcd.
That is why we have a seperate lease for each upgrade job, because on top of the compute resources it require it also consumes a deticated storage domain.

The job step that extracts the info from the secert is here, [Link](https://github.com/openshift/release/blob/master/ci-operator/step-registry/ipi/conf/ovirt/generate-install-config-params/ipi-conf-ovirt-generate-install-config-params-commands.sh)

3. ovirt.conf:
Contains oVirt engine information which is shared between all jobs, like engine URL and connection info.

It is used in the install config, [here](https://github.com/openshift/release/blob/master/ci-operator/step-registry/ipi/conf/ovirt/generate-install-config/ipi-conf-ovirt-generate-install-config-commands.sh#L8)

4. pull-secret:
The pull-secret which the jobs need to pull resources from the Openshift release image registry, it should never expire, and if it does then #forum_testplatform needs to be contacted to regenerate it.

It is used in the install config, [here](https://github.com/openshift/release/blob/master/ci-operator/step-registry/ipi/conf/ovirt/generate-install-config/ipi-conf-ovirt-generate-install-config-commands.sh#L12)

5. send-event-to-ovirt.sh:
A bash function to send an event to oVirt when the job is starting and ending, it helps to look at the oVirt Engine events and filter then to see information about specific jobs.
It is kept as a secret for historical reasons, it used to contain sensetive information but not any more, it can be ported to a function in the code itself.

6. ssh keys:
To connect to the engine/proxy VM

More information on Openshift CI secrets and how to use them in jobs can be found in the [Docs](https://docs.ci.openshift.org/docs/how-tos/adding-a-new-secret-to-ci/)

### How a oVirt CI job is built

The CI tests are built in a complex multi stage tests architecture which is best explained in the offical documentation, I will deticate this section to point stuff which are specific to the oVirt jobs, and the logic which they have.
If you are not familir with Openshift CI please stop here and read the [Multi-Stage Tests and the Test Step Registry docs](https://docs.ci.openshift.org/docs/architecture/step-registry/) it is important to understand what are Steps, Chains and Workflow to continue to read.

#### oVirt Workflows

Ovirt jobs are grouped into workflows, were each workflow represents a single job that can be triggered and contains all the steps and ENV vars required to run it.
We try to avoid from stating ENV vars in the job definition to prevent configuration issues, we prefer creating another workflow or a step compared to start adding more and more env vars.
Remember that workflows just group steps and chains so you sould have a workflow for each job type.
So for example lets take a look at the conformace workflows:
The regular job that is triggered for master, 4.9,4.8 is found [here](https://github.com/openshift/release/blob/master/ci-operator/step-registry/openshift/e2e/ovirt/conformance/openshift-e2e-ovirt-conformance-workflow.yaml)
But on 4.7 and 4.6 we didn't have affinity groups in the install config, so we needed to create a different workflow which will describe a 4.7/6 job, it is almost identical to the regular workflow, but it requires a specifc chain for 4.6 and 4.7. see [Link](https://github.com/openshift/release/blob/master/ci-operator/step-registry/openshift/e2e/ovirt/conformance/release-4.6-4.7/openshift-e2e-ovirt-conformance-release-4.6-4.7-workflow.yaml#L5).

If we take a closer look into the workflows, we deticate:
- `pre` section to all configuration which is required to setup the openshift cluster, after the `pre` section we should have a fully functional cluster which is ready for tests.
- `test` section to run the specific test suite which is specifice in the `TEST_SUITE` and `TEST_TYPE` env vars
- `post` section to extract information from the cluster and destroy the cluster (clean up the env).

The oVirt csi, minimal and conformance workflows can be found [here](https://github.com/openshift/release/tree/master/ci-operator/step-registry/openshift/e2e/ovirt) and the upgrade workflows can be found [here](https://github.com/openshift/release/tree/master/ci-operator/step-registry/openshift/upgrade/ovirt).

Each workflow contains the env vars and steps/chains which are required for it to run, you can look at the different steps to see how the env vars are used.
We also try to document a clear explantation on what is the workflow and how it differs from other workflows.

#### oVirt Chains

The chains are the most simple section, chains just group steps and give then meaning do it would be clearer on the workflow.
The main big chains are the pre and post chains (as explained above), they can be found [here](https://github.com/openshift/release/tree/master/ci-operator/step-registry/ipi/ovirt), you can take a look at then and see that they contain other chains and steps.

#### oVirt Steps

Steps are the moving pieces of the Job and contain the logic to run for each of them.
We have steps that are specific to oVirt which we maintain [conf](https://github.com/openshift/release/tree/master/ci-operator/step-registry/ipi/conf/ovirt), [install](https://github.com/openshift/release/tree/master/ci-operator/step-registry/ipi/install/ovirt) and steps that are shared between providers for example:

- [etcd on ramfs](https://github.com/openshift/release/blob/master/ci-operator/step-registry/ipi/conf/etcd/on-ramfs/ipi-conf-etcd-on-ramfs-commands.sh)
- [install](https://github.com/openshift/release/blob/master/ci-operator/step-registry/ipi/install/install/ipi-install-install-commands.sh) notice that stable install is used for upgrade jobs
- [test](https://github.com/openshift/release/blob/master/ci-operator/step-registry/openshift/e2e/test/openshift-e2e-test-commands.sh)

### Where are the CI jobs located?

The jobs themselfs are localled in the [ci-operator/jobs/openshift directory](https://github.com/openshift/release/tree/master/ci-operator/jobs/openshift), BUT they are AUTO GENERATED from the job configurations at [ci-operator/config/openshift](https://github.com/openshift/release/tree/master/ci-operator/config/openshift) by running the `make jobs` command.
So to edit or create a new job, you will need to edit the config file and then run `make jobs` which will create the full job definition in the correct place.

Some example PRs:
1. Adding a periodic confortmance job, [Link](https://github.com/openshift/release/pull/20576/files)
2. Editing existing job, marking jobs as required, [Link](https://github.com/openshift/release/pull/22837/files)
3. Editing existing job, pointing a job to a different workflow, [Link](https://github.com/openshift/release/pull/19210/files)

### Types of jobs and the difference between them

#### Minimal

Minimal or Regualr jobs are the job that we run against each PR, they are using etcd on RAM and run with the default storage domain.
The Minimal job doesn't run the whole conformance test suite, it only runs tests that are marked as "Early".
The main perpuse on the minimal job is the check that a PR doesn't break the installation and the cluster, it checks that the openshift cluster is functional i.e all the cluster operators are ready, and that there hasn't been any unexpected behaivur during the installation.
See [minimal workflow example](https://github.com/openshift/release/blob/master/ci-operator/step-registry/openshift/e2e/ovirt/minimal/openshift-e2e-ovirt-minimal-workflow.yaml).

Upon writing it I remembered that when we migrated to workflows we copied the logic of tests and changed a very small thing to

#### CSI

CSI test run a special K8S/Openshift test suite which tests CSI related things.
This test suite uses etcd on RAM and run with the default storage domain.
Because each CSI has different things which it supports the test suite has logic to accept a manifest that list the features which the CSI driver supports, and can skip tests that shouldn't run for this specific driver.
We generate the csi test manifest in the conf phase, [Link](https://github.com/openshift/release/tree/master/ci-operator/step-registry/ipi/conf/ovirt/generate-csi-test-manifest).
Since on release 4.6-4.8 we didn't support resize we have 2 different steps for the creation of the test manifests.
The CSI workflow need to specify 3 env vars to run currectly:

- TEST_TYPE == "suite" - to indicate that we want to run a suite which is specified by the "TEST_SUITE" var.
- TEST_SUITE: "openshift/csi" - to indicate that we want to run the CSI suite.
- TEST_CSI_DRIVER_MANIFEST == "csi-test-manifest.yaml" - the name of the CSI driver manifest file to use.

See [csi workflow example](https://github.com/openshift/release/blob/master/ci-operator/step-registry/openshift/e2e/ovirt/csi/openshift-e2e-ovirt-csi-workflow.yaml).

#### Conformance

Conformance suite runs the OCP/K8S conformance test suite on the cluster.
We run it for all the periodic tests and release tests.

The perodic job is defined on the [config files](https://github.com/openshift/release/blob/5a125021de05682c25dc0eac641f5ed4f2b4d01f/ci-operator/config/openshift/release/openshift-release-master__nightly-4.10.yaml) like most jobs.

The release jobs is defined in the [release controller](https://github.com/openshift/release/blob/master/core-services/release-controller/_releases/release-ocp-4.10.json#L222-L225), this is duplicated for each release version (4.6, 4.8, and so on).

The reason that we don't run it for each job is that sometimes conformance jobs just don't pass due to known issues, and we don't want to block PRs due to that, plus it speeds up test times - we did wanted to add an optional conformace job for our tests repos but at the time of this writing we haven't gotten to that.

See [conformance workflow example](https://github.com/openshift/release/blob/7e61829f682e1574513f78c3e94537836d824ab3/ci-operator/step-registry/openshift/e2e/ovirt/conformance/openshift-e2e-ovirt-conformance-workflow.yaml).

#### Upgrade

Upgrade jobs tests upgrading from version X to Y, currently we have only minor upgrades jobs meaning from 4.x to 4.(x+1), but there were talks about adding multiple upgrade jobs 4.x -> 4.(x+1) -> 4.(x+2) and so on.
Currently we can run up to 6 upgrade jobs in parallel, something that was made possiable when we added a sperate storage domain for each upgrade job.

There are a couple of differences between of Upgrade jobs and Regular jobs:

1. Upgrade jobs can't use the etcd on ramfs, because the nodes reboot during the upgrade then everything which had existed on ram would be deleted. To have a successful upgrade job we can't use the etcd hack we use for all other jobs, that is why we needed to give each job its own storage domain in RHV and a seperate storage on IBM to back that storage domain.
Notice that since etcd requires a very strong storage and we needed to give each job a High IOPs storage form IBM with 1TB, we arrived at 600GB after a lot of testing in CI to find the lowest amount which suticfied the IOPs for etcd - when we will have the ability to use thick provisioned for jobs then we will probably be able to reduce the amount and save some money.

2. Upgrade jobs use the stableinstall step, becuse they need to install from an older version then the version of the job. An upgrade job for the 4.8 branch tests 4.7 -> 4.8 upgrade, so we need to make sure that 4.7 is installed, this is done by defining the installer version to the "stable" version which means the previus version:
- in the [job config](https://github.com/openshift/release/blob/master/ci-operator/config/openshift/release/openshift-release-master__ci-4.10-upgrade-from-stable-4.9.yaml#L11-L14).
- in the [step](https://github.com/openshift/release/blob/master/ci-operator/step-registry/ipi/install/install/stableinitial/ipi-install-install-stableinitial-ref.yaml#L3)
And the the workflow we specify the release image to use [here](https://github.com/openshift/release/blob/master/ci-operator/step-registry/openshift/upgrade/ovirt/openshift-upgrade-ovirt-workflow.yaml#L15-L16).

See [upgrade workflow example](https://github.com/openshift/release/blob/master/ci-operator/step-registry/openshift/upgrade/ovirt/openshift-upgrade-ovirt-workflow.yaml).

## Monitoring and Debugging tools:

1. Test Grid: [Link to 4.10](https://testgrid.k8s.io/redhat-openshift-ocp-release-4.10-informing#periodic-ci-openshift-release-master-nightly-4.10-e2e-ovirt&sort-by-failures=&width=20)

The test grid is our best place to observe a job over time, we can do some basic sorting to it.
When ever a new release jon is create it is automatically added to the test grid, but you can add any job to it.See [Add a Job to TestGrid](https://docs.ci.openshift.org/docs/how-tos/add-jobs-to-testgrid/).

2. Sippy: [Link](https://sippy.ci.openshift.org/sippy-ng/)
Sippy is a tool whic h is created and maintained by the Openshift CI team, it shows an overview of the status for jobs on a certain release, but the most useful feature in my opinion is the TestCase to Bug mapping. If you look at the test cases, it lists what are the most failed tests and tries to find a bug for each of them - it can really help save time debuging a known issue.

3. CI status: [Link](https://deck-ci.apps.ci.l2s4.p1.openshiftapps.com/)
alows us to view general status of jobs from the last 12 hours.

4. CI search: [Link](https://search.ci.openshift.org/)
A very very powerful tool to search regex in CI jobs. We can search a regex in the job juinit, build log, bugzilla and all of them together.
It is used for a lot of cases and referenced a lot on BZs.
It can help us understand if a problem is just for us or for all providers, if you see a test case which is failing for oVirt you can search it in the juinit and it will show us in which jobs it failed and the procentage of failures over a defined period of time, it can also search in BZ and find Bugs which handle that failure.