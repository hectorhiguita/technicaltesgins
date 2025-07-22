terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.4.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

module "VPCs" {
  source = "./Modules/VPC"
  vpc_variables      = var.vpc_variables
  subnets            = var.subnets
  ingress_ports_list = var.ingress_ports_list
  sg_ingress_cidr    = var.sg_ingress_cidr
}


module "terraform_state_backend" {
     source = "cloudposse/tfstate-backend/aws"
     # Cloud Posse recommends pinning every module to a specific version
     version     = "1.5.0"
     namespace  = "Amrize_Testing"
     stage      = "Test"
     name       = "terraform"
     attributes = ["state"]
     terraform_backend_config_file_path = "."
     terraform_backend_config_file_name = "backend.tf"
     force_destroy                      = false
   }