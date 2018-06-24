# ---------------------------------------------------------------------------
# Terraform module to create compute resources to stand up a simple webserver
# ---------------------------------------------------------------------------

variable "name" {}

variable "tags" {
  type = "map"
}

variable "vpc_id" {}
variable "region" {}

variable "subnet_ids" {
  type = "list"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ssh_key" {}

data "aws_ami" "xenial" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/cloud-config.yml")}"
}

resource "aws_key_pair" "keypair" {
  key_name   = "${var.name}"
  public_key = "${var.ssh_key}"
}

resource "aws_security_group" "webserver" {
  name        = "${var.name}"
  description = "limit access to ssh and port 80"
  tags        = "${merge(map("Name", "${var.name}-instance"), var.tags)}"

  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_http_ingress" {
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "allow_ssh_ingress" {
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.webserver.id}"
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.webserver.id}"
}

resource "aws_instance" "webserver" {
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.keypair.key_name}"
  subnet_id                   = "${element(var.subnet_ids, 0)}"
  ami                         = "${data.aws_ami.xenial.id}"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.webserver.id}"]
  user_data                   = "${data.template_file.cloud_config.rendered}"
  tags                        = "${merge(map("Name", "${var.name}"), var.tags)}"

  lifecycle {
    create_before_destroy = true
  }
}
