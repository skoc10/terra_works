provider "aws" {
  region = "us-east-1"
}

variable "ec2name" {
  default = ["First", "Second"]
}
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "instance" {
  ami = "${data.aws_ami.amazon-linux-2.id}"
  instance_type = "t2.micro"
  key_name = "key"
  security_groups = ["tf-provisioner-sg"]
  for_each = toset(var.ec2name)
  tags = {
    Name = "Terraform ${each.value} Instance"
  }

  provisioner "local-exec" {
      command = "echo http://${self.public_ip} >> public_ip.txt"
  }
  provisioner "local-exec" {
      command = "echo http://${self.private_ip} >> private_ip.txt"
  }