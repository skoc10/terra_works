provider "aws" {
  region     = "us-east-1"
  #access_key = "xxxxxxxxxxxxxxxxxxxx"
  #secret_key = "xxxxxxxxxxxxxxxxxxxx"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.69.0"
    }
  }

  backend "s3" {
    bucket = "tf-remote-s3-bucket-skoc-changehere"
    key = "env/dev/tf-remote-backend.tfstate"
    region = "us-east-1"
    dynamodb_table = "tf-s3-app-lock"
    encrypt = true
  }
}

locals {
  mytag = "skoc-local-name"
}
data "aws_ami" "tf_ami" {
  most_recent = true
  owners = [ "self" ]

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  
}
resource "aws_instance" "tf-ec2" {
  ami           = data.aws_ami.tf_ami.id
  instance_type = var.ec2_type
  key_name      = "key"    # write your pem file without .pem extension>
  tags = {
    "Name" = "${local.mytag}-come from locals"
  }
}

resource "aws_s3_bucket" "tf-s3" {
  #bucket = "${var.s3_bucket_name}-${count.index + 1}"
  acl    = "private"
  # count = var.num_of_buckets
  # count = var.num_of_buckets != 0 ? var.num_of_buckets : 3
  for_each = toset(var.users)
  bucket = "example-tf-s3-bucket-${each.value}"

}

resource "aws_iam_user" "new_users" {
  name = each.value
  for_each = toset(var.users)
  
}

