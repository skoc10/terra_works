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
/* resource "aws_instance" "tf-ec2" {
  ami           = "ami-0ed9277fb7eb570c9"
  instance_type = "t2.micro"
  key_name      = "key"    # write your pem file without .pem extension>
  tags = {
    "Name" = "tf-ec2"
  }
} */


resource "aws_s3_bucket" "tf-s3" {
  bucket = var.s3_buc_name
  acl    = "private"
}