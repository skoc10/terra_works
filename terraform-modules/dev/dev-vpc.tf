module "tf-vpc" {
  source = "../modules"
  environment = "skoc"
}

output "vpc-cidr-block" {
  value = module.tf-vpc.vpc_cidr
}