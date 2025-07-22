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