data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc_virginia" {
  cidr_block = var.vpc_variables["CIDR"]
  tags = {
    "Name" = "vpc-${var.vpc_variables.Name}"
    "date" = var.tags["date"]
    "owner" = var.tags["owner"]
    "cloud" = var.tags["cloud"]
    "IAC" = var.tags["IAC"]
    "IAC_Version" = var.tags["IAC_Version"]
    "project" = var.tags["project"]
    "region" = var.tags["region"]    
  }
}

resource "aws_subnet" "public_subnet" {
  for_each                = { for k, v in var.subnets : k => v if can(regex("public", k)) }
  vpc_id                  = aws_vpc.vpc_virginia.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[index(keys({ for k, v in var.subnets : k => v if can(regex("public", k)) }), each.key)]
  map_public_ip_on_launch = true
  tags = {
    "Name" = each.key
  }
}

resource "aws_subnet" "private_subnet" {
  for_each          = { for k, v in var.subnets : k => v if can(regex("private", k)) }
  vpc_id            = aws_vpc.vpc_virginia.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[index(keys({ for k, v in var.subnets : k => v if can(regex("private", k)) }), each.key)]
  tags = {
    "Name" = each.key
  }
  depends_on = [
    aws_subnet.public_subnet
  ]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_virginia.id

  tags = {
    Name = "igw vpc virginia"
  }
}


resource "aws_route_table" "public_crt" {
  vpc_id = aws_vpc.vpc_virginia.id

  route {
    cidr_block = var.sg_ingress_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public crt"
  }
}

resource "aws_route_table_association" "crta_public_subnet" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_crt.id
}

# NAT Gateway and Elastic IP
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "NAT Gateway EIP"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = values(aws_subnet.public_subnet)[0].id
  tags = {
    Name = "NAT Gateway"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Private Route Table
resource "aws_route_table" "private_crt" {
  vpc_id = aws_vpc.vpc_virginia.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private crt"
  }
}

# Private Route Table Associations
resource "aws_route_table_association" "crta_private_subnet" {
  for_each       = aws_subnet.private_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_crt.id
}

resource "aws_security_group" "sg_public_instance" {
  name        = "Public Instance SG"
  description = "Allow SSH inbound traffic and ALL egress traffic"
  vpc_id      = aws_vpc.vpc_virginia.id

  dynamic "ingress" {
    for_each = var.ingress_ports_list
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.sg_ingress_cidr]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Public Instance SG"
  }
}


#module "mybucket" {
#  source      = "./modulos/s3"
#  bucket_name = "nombreunico1234567"
#
#}
#output "s3_arn" {
#  value = module.mybucket.s3_bucket_arn
#}

# module "terraform_state_backend" {
#   source      = "cloudposse/tfstate-backend/aws"
#   version     = "0.38.1"
#   namespace   = "example"
#   stage       = "prod"
#   name        = "terraform"
#   environment = "us-east-1"
#   attributes  = ["state"]

#   terraform_backend_config_file_path = "."
#   terraform_backend_config_file_name = "backend.tf"
#   force_destroy                      = false
# }
