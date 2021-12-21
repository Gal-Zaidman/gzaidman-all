
# Detecting and Managing Drift with Terraform

Terraform is an opensource infrastructure has code solution created by HashiCorp which enables you to manage the lifecycle of your infrastructure by using declarative configuration files. One challenge when managing infrastructure as code is **drift**.

This post explains how to use Terraform to detect and manage configuration drift. We will cover:

- Terraform State: The state file and how Terraform tracks resources.
- Terraform Refresh: The refresh command and reconciling real-world drift.
- Terraform Plan: The plan command and reconciling desired configuration with real-world state.
- Terraform Config: Useful config options for managing drift.

For the rest of this post, we will use this example resource configuration snippet to illustrate different scenarios and features of Terraform:

```bash
# AWS EC2 VM with AMI and tags
resource "aws_instance" "example" {
  ami           = "ami-656be372"
  instance_type = "t1.micro"
  tags {
    drift_example = "v1"
  }
}
```

## Terraform state: How Terraform tracks resources

Terraform requires some sort of database to map Terraform config to the real world, this database is called the terraform state. The state is stored in a file named terraform.tfstate which will be created the first time you run terraform apply, and will be updated on every change made by terraform.
For example when you define a resource in your configuration:
resource "aws_instance" "example"
Terraform uses this map to know that instance i-abcd1234 is represented by that resource.

State is essential to Terraform and performs these functions:

- Map resources defined in the configuration to real-world resources.
- Track metadata about resources such as dependencies and dependency order.
- Cache resource attributes to improve performance when managing very large infrastructures.
- Track resources managed by Terraform, to ignore other resources in the same environment.

The format of the state file is JSON and is designed for internal use only (not recommended to edit it manually).  

To see the current state for the entire configuration, we use the command:
```bash
$ terraform show
aws_instance.example:
  id = i-011a9893eff09ede1
  ami = ami-656be372
  availability_zone = us-east-1d
  ...
```

To see the current state for a specific resource, we use the command:

```bash
$ terraform state show aws_instance.example
id                                        = i-011a9893eff09ede1
ami                                       = ami-656be372
availability_zone                         = us-east-1d
...
```

## What is Drift

Drift is the term for when the real-world state of your infrastructure differs from the state defined in your configuration files.
This can happen for many reasons:

- Changing configuration: adding/removing resources or changing resource definitions on the terraform configuration files.
- Resources internal changes: some software installed on the resource changed the resource.
- Hardware failures: a bare metal has failed.
- Manual change to resources: Someone or some tool (for example ansible) with access to the env changed or terminated the resource.

Basically terraform cannot detect drift of resources and their associated attributes that occurred by outside of terraform.

# Terraform refresh: Reconciling real-world drift

Terraform refresh is a command which reconcile the resources tracked by the state file with the real world.
Refresh is ran prior to a **plan** or **apply** command, but can also ran manually with terraform refresh:

```bash
$ terraform refresh
aws_instance.example: Refreshing state... (ID: i-011a9893eff09ede1)
```

When we refresh terraform will query your infrastructure providers to find out what's actually running and the current configuration, and update the state file with this new information. By default, a backup of your state file is written to terraform.tfstate.backup in case the state file is lost or corrupted to simplify recovery.

## Terraform plan: Reconciling desired configuration with real-world state

A Terraform plan is a description of everything Terraform will do to implement your desired configuration. Terraform plan is done automatically during an apply but can also be done explicitly with the terraform plan command. The first time you run terraform the plan will be to create all of the resources in your configuration, after that terraform may plan to edit existing resources, or destroy and create new ones.

After refreshing the state file, Terraform can compare the desired state, defined in your configuration, with the actual state of your existing resources. This comparison allows Terraform to detect which resources need to be created, modified, or destroyed and form a plan.

Using our same example, we can see the output of plan after having manually updated the tags on the instance using the AWS console:

$ 
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_instance.example: Refreshing state... (ID: i-011a9893eff09ede1)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ aws_instance.example
      tags.drift_example: "v2" => "v1"

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------
We can see Terraform will update the value of the tag from v2 to v1. Terraform is trying to correct the drift and modify the tag to match the value in the configuration.

Not all drift can be fixed by updating a resource, sometimes resources need to be recreated. Using our same example, we can see the output of terraform plan after having manually terminated the instance using the AWS console:

$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_instance.example: Refreshing state... (ID: i-011a9893eff09ede1)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_instance.example
      id:                           <computed>
      ami:                          "ami-656be372"
      availability_zone:            <computed>
      instance_state:               <computed>
      instance_type:                "t1.micro"
      tags.drift_example:           "v1"
      ...

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------
We can see that Terraform, having detected that the resource specified in the configuration no longer exists, will create a new instance of it with the values specified in the configuration.

When drift occurs in resources that still exist, for attributes that cannot be updated, Terraform will destroy the original resource before re-creating it.

Using our same example configuration, we specify a new AMI value:

resource "aws_instance" "example" {
  # updated AMI
  ami           = "ami-14c5486b"
}
Running terraform plan with this update configuration results in the following:

$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_instance.example: Refreshing state... (ID: i-06641647ef59e4304)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

-/+ aws_instance.example (new resource required)
      id:                           "i-06641647ef59e4304" => <computed> (forces new resource)
      ami:                          "ami-656be372" => "ami-14c5486b" (forces new resource)
      associate_public_ip_address:  "" => <computed>
      availability_zone:            "us-east-1c" => <computed>
      instance_state:               "running" => <computed>
      instance_type:                "t1.micro" => "t1.micro"
      tags.drift_example:           "v1" => "v1"
      …

Plan: 1 to add, 0 to change, 1 to destroy.

------------------------------------------------------------------------
We see that to reconcile our configuration with real-world state, Terraform will first destroy the existing instance, built with the original AMI, and then recreate it with the new AMI.

Lifecycle options: Configuring how Terraform manages drift
Terraform provides some lifecycle configuration options for every resource, regardless of provider, that give you more control over how Terraform reconciles your desired configuration against state when generating plans.

One of these options is prevent_destroy. When this is set to true, any plan that includes a destroy of this resource will return an error message. Use this flag to provide extra protection against the accidental deletion of any essential resources.

In the last example, where we updated the AMI of our resource, terraform plan indicated that the existing instance would be destroyed. To prevent this behavior, add the following to the resource’s definition:

  lifecycle {
    prevent_destroy = true
  }
Running terraform plan now generates an error, alerting us that applying this plan would destroy resources:

$ terraform plan
Error: Error running plan: 1 error(s) occurred:

* aws_instance.example: 1 error(s) occurred:

* aws_instance.example: aws_instance.example: the plan would destroy this resource, but it currently has lifecycle.prevent_destroy set to true. To avoid this error and continue with the plan, either disable lifecycle.prevent_destroy or adjust the scope of the plan using the -target flag.
While returning an error when any resource with prevent_destory = true will be deleted is useful for preventing the accidental destruction of resources, Terraform won’t allow us to make any other changes when this happens.

Instead, another option for managing drift is the ignore_changes parameter, which tells Terraform which individual attributes to ignore when evaluating changes.

Using our same example, we add ignore_changes = ["ami"] to the lifestyle stanza and re-run terraform plan:

$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

aws_instance.example: Refreshing state... (ID: i-06641647ef59e4304)

------------------------------------------------------------------------

No changes. Infrastructure is up-to-date.

This means that Terraform did not detect any differences between your
configuration and real physical resources that exist. As a result, no
actions need to be performed.
This time, rather than an error, even though the AMI of the instance is different from what is specified in the configuration, Terraform reports that no changes have occured. This is because, in the process of reconciling configuration with real-world state, Terraform ignored the values for AMI.

Another lifecycle flag is create_before_destroy. This is used for controlling the ordering of resource creation and destruction, particularly for achieving zero down time.

Summary
Drift is the term for when the real-world state of your infrastructure differs from the state defined in your configuration. Terraform helps detect and manage drift. Information about the real-world state of infrastructure managed by Terraform is stored in the state file. The command terraform refresh updates this state file, reconciling what Terraform thinks is running and its configuration, with what actually is. All plan and apply commands run refresh first, prior to any other work. Detect drift with terraform plan, which reconciles desired configuration with real-world state and tells you what Terraform will do during terraform apply. Terraform provides more fine grained control of how to manage drift with lifecycle parameters prevent_destroy and ignore_changes.

## Refrences

1. [Detecting and Managing Drift with Terraform](https://www.hashicorp.com/blog/detecting-and-managing-drift-with-terraform/)
2. [Purpose of Terraform State](https://www.terraform.io/docs/state/purpose.html)