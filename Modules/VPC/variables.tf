
variable "vpc_variables" {
  description = "Configuration variables for VPC"
  type        = map(string)
  
  validation {
    condition = contains(keys(var.vpc_variables), "CIDR") && contains(keys(var.vpc_variables), "Name")
    error_message = "vpc_variables must contain 'CIDR' and 'Name' keys."
  }
}

variable "subnets" {
  description = "List of subnet CIDR blocks"
  type        = list(string)
  
  validation {
    condition = length(var.subnets) == 4
    error_message = "Exactly 4 subnets must be provided (2 public, 2 private)."
  }
}

variable "ingress_ports_list" {
  description = "List of ingress ports for security group"
  type        = list(number)
  default     = [80, 443, 22]
}

variable "sg_ingress_cidr" {
  description = "CIDR block for security group ingress rules"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}