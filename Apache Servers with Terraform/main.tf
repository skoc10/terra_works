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
  user_data  = file("user_data.sh")
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
}

  output "inst-public-ip" {
  value = [for name in var.ec2name : aws_instance.instance[name].public_ip ]
  }


resource "aws_security_group" "tf-sec-gr" {
  name = "tf-provisioner-sg"
  tags = {
    Name = "tf-provisioner-sg"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      protocol = "tcp"
      to_port = 22
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
      from_port = 443
      protocol = "tcp"
      to_port = 443
      cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
      from_port = 0
      protocol = -1
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
  }
}