provider "aws" {
  region     = "us-east-1"
  #access_key = "xxxxxxxxxxxxxxxxxxxxxxxxx"
  #secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxx"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.69.0"
    }
  }
}

resource "aws_s3_bucket" "skoc1101010koc" {
  bucket = "skoc1101010koc"
  acl    = "private"

  tags = {
    Name        = "skoc1101010koc"
    Environment = "Dev"
  }
}

data "template_file" "userdata" {
  template = file("${path.module}/userdata.sh")
  vars = {
    rds_endpoint = "${aws_s3_bucket.skoc1101010koc.bucket_domain_name}"
  }
}
resource "aws_instance" "test"  {
  ami           = var.aws_ami
  instance_type = var.instance_type
  security_groups = ["lt_sg"]

  user_data       = data.template_file.userdata.rendered
 
  key_name        = var.key_name
}

resource "aws_security_group" "lt_sg" {
  name        = "lt_sg"
  description = "launch template security group"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}