# terraform-example

This repository is an example of one way of standing up a webserver in AWS via Terraform.

## Requirements

You'll need to have [terraform installed](https://www.terraform.io/downloads.html), as well as [inspec](https://www.inspec.io/downloads/) for running tests. If installing via Hoembrew on OS X, you might have to first `brew tap chef/chef`

There are a couple of required variables that need to be setup before you can execute the Terraform plan:

* `name`
* `ssh_key`

You [can set these in many ways](https://www.terraform.io/docs/configuration/variables.html), including via the command-line when asked for input, by exporting environment variables (`export TF_VAR_ssh_key=foobar`), or by using a variables file via the `-var-file=FILE` flag. A sample `terraform.tfvars.sample` file is included for your consideration.

## Usage

1. Ensure your AWS credentials are available in `~/.aws/credentials` or [present as environment variables.](https://www.terraform.io/docs/providers/aws/index.html)
2. Run `make init` in the root of the repository to download the required providers and modules.
3. Run `make plan` to show the resources that will be applied.
4. Run `make apply` to provision the environment. Once it's complete, you'll get an ip address of the server in the output section where you can access the website in your browser.

```
Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

Outputs:

environment_name = test
vpc_id = vpc-foobar
webserver_ip = x.x.x.x
```

5. To destroy, run `make destroy`

## Testing

Tests are run by inspec. The environment will need to have been provisioned prior to running the tests. Tests can be executed via `make test`.

```
Profile: InSpec Profile (verify)
Version: 0.1.0
Target:  aws://

  EC2 Instance test2
     ✔  should exist
     ✔  should be running
     ✔  instance_type should eq "t2.micro"
     ✔  tags should include {:key => "Name", :value => "test2"}
  EC2 Security Group sg-e4313995
     ✔  should exist
     ✔  should allow in {:port=>22, :ipv4_range=>"0.0.0.0/0"}
     ✔  should allow in {:port=>80, :ipv4_range=>"0.0.0.0/0"}
     ✔  vpc_id should cmp == "vpc-bb4f50c2"
  VPC vpc-bb4f50c2
     ✔  should exist
     ✔  cidr_block should cmp == "10.0.0.0/16"

Test Summary: 10 successful, 0 failures, 0 skipped
```

## Improvements

* Implement ELB
* Implement auto-scaling groups
* Use more than one AZ
