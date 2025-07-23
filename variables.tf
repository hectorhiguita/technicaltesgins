
variable "vpc_variables" {
  description = "Configuration variables for VPC including CIDR and Name"
  type        = map(string)
  
  validation {
    condition = contains(keys(var.vpc_variables), "CIDR") && contains(keys(var.vpc_variables), "Name")
    error_message = "vpc_variables must contain 'CIDR' and 'Name' keys."
  }
}

variable "subnets" {
  description = "Map of subnet names to CIDR blocks (must contain 'public' or 'private' in the key name)"
  type        = map(string)
  
  validation {
    condition = length(var.subnets) == 4
    error_message = "Exactly 4 subnets must be provided (2 public, 2 private)."
  }
}

variable "ingress_ports_list" {
  description = "List of ingress ports for security group"
  type        = list(number)
}

variable "sg_ingress_cidr" {
  description = "CIDR block for security group ingress rules"
  type        = string
  default     = "0.0.0.0/0"
  
  validation {
    condition = can(cidrhost(var.sg_ingress_cidr, 0))
    error_message = "sg_ingress_cidr must be a valid CIDR block."
  }
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "ECS_Name" {
  description = "value for ECS cluster name"
  type        = string
}

variable "ECR_Name" {
  description = "value for ECR repository name"
  type        = string
}