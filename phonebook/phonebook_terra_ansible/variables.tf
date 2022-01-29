### variable.tf
variable "aws_region" {
  description = "AWS region on which we will setup the swarm cluster"
  default = "us-east-1"
}
variable "ami" {
  description = "Amazon Linux AMI"
  default = "ami-04505e74c0741db8d"
}
variable "instance_type" {
  description = "Instance type"
  default = "t2.micro"
}
variable "key_path" {
  description = "SSH Public Key path"
  default = "/Users/koc/Desktop/key_AWS/key.pem"
}
variable "key_name" {
  description = "Desired name of Keypair..."
  default = "key"
}
variable "bootstrap_path" {
  description = "Script to install Docker Engine"
  default = "install_docker_machine_compose.sh"
}