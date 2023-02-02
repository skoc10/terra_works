
terraform {
  required_version = ">= 1.2.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
  }


}

  # backend "s3" {
  #   bucket         = "<<project>>-tfstate-<<environment>>"
  #   key            = "infrastructure/terraform.tfstate"
  #   region         = "eu-central-1"
    
  #   access_key     = ""
  #   secret_key     = ""
  # }
  

provider "aws" {
  region     = "eu-central-1"
  access_key = ""
  secret_key = ""
}


module "main" {
  source = "../main"
}