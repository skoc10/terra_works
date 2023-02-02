resource "aws_vpc" "main" {
  cidr_block           = var.vpc_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-VPC"
  }
}