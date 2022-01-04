variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "db_user_name" {
  default = "admin"
}
variable "db_name" {
  default = "phonebook"
}
variable "db_password" {
  default = "selmankoc"
}
# Amazon Linux 2 AMI (HVM) - Kernel 5.10
variable "aws_ami" {
  default = "ami-0ed9277fb7eb570c9"
}

variable "availability_zones" {
  default     = "us-east-1c,us-east-1d"
  description = "List of availability zones, use AWS CLI to find your "
}

variable "key_name" {
  description = "Name of AWS key pair"
  default = "key"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "3"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "2"
}