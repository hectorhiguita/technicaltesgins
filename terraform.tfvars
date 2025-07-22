vpc_variables = {
  "CIDR"         = "10.90.0.0/24"
  "Name"        = "amrize_vpc"

}


tags = {
  "date"         = "2025-07-22"
  "owner"       = "Alejandro Higuita"
  "cloud"       = "AWS"
  "IAC"         = "Terraform"
  "IAC_Version" = "1.12.2"
  "project"     = "Amrize technical test"
  "region"      = "virginia"
}

subnets = ["10.90.0.0/27", "10.90.0.32/27" , "10.90.0.64/27", "10.90.0.96/27"]

ingress_ports_list = [80]

sg_ingress_cidr = "0.0.0.0/0"
