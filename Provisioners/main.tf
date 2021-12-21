terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.38.0"
    }
  }
}

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

  /* provisioner "local-exec" {
    inline = [
      "echo http://${self.public_ip} >> public_ip.txt",
      "echo http://${self.private_ip} >> private_ip.txt"
    ]
  } */

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ec2-user"
    private_key = file("key.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum -y install httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd" ,
      "echo 'Hello World' > index.html",
      "cp index.html /var/www/html/",
      "sudo cp index.html /var/www/html/"
    ]
  }

  provisioner "file" {
    content = self.public_ip
    destination = "/home/ec2-user/my_public_ip.txt"
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

  egress {
      from_port = 0
      protocol = -1
      to_port = 0
      cidr_blocks = [ "0.0.0.0/0" ]
  }
}