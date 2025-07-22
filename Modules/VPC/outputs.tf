output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc_virginia.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.vpc_virginia.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = { for k, v in aws_subnet.public_subnet : k => v.id }
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = { for k, v in aws_subnet.private_subnet : k => v.id }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gw.id
}

output "public_security_group_id" {
  description = "ID of the public security group"
  value       = aws_security_group.sg_public_instance.id
}
