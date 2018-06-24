variable "name" {}

variable "region" {
  default = "us-west-2"
}

variable "tags" {
  type = "map"

  default = {
    "provisioned_by" = "terraform"
  }
}

variable "az_count" {
  default = 3
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "ssh_key" {}

provider "aws" {
  region                  = "${var.region}"
  shared_credentials_file = "~/.aws/credentials"
}

module "network" {
  source   = "./modules/network"
  name     = "${var.name}"
  vpc_cidr = "${var.vpc_cidr}"
  tags     = "${var.tags}"
}

module "compute" {
  source     = "./modules/compute"
  name       = "${var.name}"
  tags       = "${var.tags}"
  region     = "${var.region}"
  vpc_id     = "${module.network.vpc_id}"
  subnet_ids = "${module.network.subnet_ids}"
  ssh_key    = "${var.ssh_key}"
}

output "environment_name" {
  value = "${var.name}"
}

output "webserver_ip" {
  value = "${module.compute.ip}"
}

output "vpc_id" {
  value = "${module.network.vpc_id}"
}
