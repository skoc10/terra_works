### main.tf
# Specify the provider and access details
provider "aws" {
  #access_key = "your-aws-access-key"
  #secret_key = "your-aws-secret-access-key"
  region = "${var.aws_region}"
}
resource "aws_instance" "master" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  user_data = "${file("${var.bootstrap_path}")}"
  security_groups = ["docker-swarm-sec-gr"]
tags {
    Name  = "Leader-master"
  }
}
resource "aws_instance" "worker1" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  user_data = "${file("${var.bootstrap_path}")}"
  security_groups = ["docker-swarm-sec-gr"]
tags {
    Name  = "worker 1"
  }
}
resource "aws_instance" "worker2" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  user_data = "${file("${var.bootstrap_path}")}"
  security_groups = ["docker-swarm-sec-gr"]
tags {
    Name  = "worker 2"
  }
}