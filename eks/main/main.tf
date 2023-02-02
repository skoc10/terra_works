module "eks" {
  source      = "../modules/eks"

  vpc_id      = module.vpc.vpc_id
  eks_subnets = module.vpc.eks_subnets

  region                  = "eu-central-1"
  cluster_name            = "<<Project>>-<<Env>>"
  endpoint_public_access  = false
  endpoint_private_access = true
  node_group_name         = "<<Project>>-<<Env>>-ng"
  eks_version             = "1.23"

  scaling_desired_size = 3
  scaling_max_size     = 10
  scaling_min_size     = 2

  node_instance_types  = ["t3.medium"]
  node_disk_size       = 20
  node_max_unavailable = 1
}



module "vpc" {
  source = "../modules/vpc"

  project   = "<<Project>>-<<Env>>"
  vpc_block = "10.0.0.0/16"

  public-subnet-map = [{ name = "<<Project>>-<<Env>>-Public-1a", az = "eu-central-1a", cidr = "" },
                       { name = "<<Project>>-<<Env>>-Public-1b", az = "eu-central-1b", cidr = "" },
                       { name = "<<Project>>-<<Env>>-Public-1c", az = "eu-central-1c", cidr = "" }]
 
  eks-subnet-map = [{ name = "<<Project>>-<<Env>>-EKS-Nodes-1a", az = "eu-central-1a", cidr = "" },
                    { name = "<<Project>>-<<Env>>-EKS-Nodes-1b", az = "eu-central-1b", cidr = "" },
                    { name = "<<Project>>-<<Env>>-EKS-Nodes-1c", az = "eu-central-1c", cidr = "" }]
}


### PRIVATE AND DATA SUBNETS ARE OPTIONAL ###


  # private-subnet-map = [{ name = "<<Project>>-<<Env>>-Private-1a", az = "eu-central-1a", cidr = "" },
  #                       { name = "<<Project>>-<<Env>>-Private-1b", az = "eu-central-1b", cidr = "" },
  #                       { name = "<<Project>>-<<Env>>-Private-1c", az = "eu-central-1c", cidr = "" }]
 
  # data-subnet-map = [{ name = "<<Project>>-<<Env>>-Data-1a", az = "eu-central-1a", cidr = "" },
  #                    { name = "<<Project>>-<<Env>>-Data-1b", az = "eu-central-1b", cidr = "" },
  #                    { name = "<<Project>>-<<Env>>-Data-1c", az = "eu-central-1c", cidr = "" }]