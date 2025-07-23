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
  tags = var.tags
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

module "ECS" {
  source = "./Modules/ECS"
  ECS_Name           = var.ECS_Name
  private_subnet_ids = values(module.VPCs.private_subnet_ids)
  vpc_id             = module.VPCs.vpc_id
  security_group_ids = [module.VPCs.public_security_group_id]
}

module "ECR" {
  source = "./Modules/ECR"
  ECR_Name = var.ECR_Name
}

module "Amrize_Testing_LB" {
  source = "./Modules/APP_Load_Balancer"
  
  tags                = var.tags
  vpc_id              = module.VPCs.vpc_id
  public_subnet_ids   = values(module.VPCs.public_subnet_ids)
  security_group_ids  = [module.VPCs.public_security_group_id]
  target_group_arn    = module.ECS.target_group_arn
}