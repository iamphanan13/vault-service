# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.vpc_name}-vpc"
    Terraform   = "true"
    Environment = "Production"
    Description = "VPC for ${var.vpc_name}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.vpc_name}-igw"
    Terraform   = "true"
    Environment = "Production"
    Description = "Internet Gateway for ${var.vpc_name}"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = {
    Name        = "${var.vpc_name}-nat-eip"
    Terraform   = "true"
    Environment = "Production"
    Description = "Elastic IP for NAT Gateway"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name        = "${var.vpc_name}-nat-gw"
    Terraform   = "true"
    Environment = "Production"
    Description = "NAT Gateway for ${var.vpc_name}"
  }
}

# Public subnets /24, starting from 10.0.1.0/24
resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.vpc_name}-public-${count.index + 1}"
    Terraform   = "true"
    Environment = "Production"
  }
}

# Private subnets /24, starting from 10.0.10.0/24
resource "aws_subnet" "private" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)


  tags = {
    Name        = "${var.vpc_name}-private-${count.index + 1}"
    Terraform   = "true"
    Environment = "Production"
  }
}

# RDS subnets /24, starting from 10.0.20.0/24
# resource "aws_subnet" "rds" {
#   count             = var.rds_subnet_count
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
#   availability_zone = element(data.aws_availability_zones.available.names, count.index)


#   tags = {
#     Name        = "${var.vpc_name}-rds-${count.index + 1}"
#     Terraform   = "true"
#     Environment = "Production"
#   }
# }

# Public Route Table
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name        = "${var.vpc_name}-public-rtb"
    Terraform   = "true"
    Environment = "Production"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public_rtb_association" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}



# Private Route Table
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gw[0].id
    }
  }

  tags = {
    Name        = "${var.vpc_name}-private-rtb"
    Terraform   = "true"
    Environment = "Production"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "private_rtb_association" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

# RDS Subnet Group
# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = "${var.vpc_name}-rds-subnet-group"
#   subnet_ids = [aws_subnet.rds[0].id, aws_subnet.rds[1].id] 
# }

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  route_table_ids   = [aws_route_table.private_rtb.id]
  vpc_endpoint_type = "Gateway"
  tags = {
    Name        = "${var.vpc_name}-s3-endpoint"
    Terraform   = "true"
    Environment = "Production"
    Description = "S3 Gateway Endpoint for ${var.vpc_name}"
  }

  policy = file("${path.module}/policies/s3-endpoint-policy.json")
}

resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.dynamodb"
  route_table_ids   = [aws_route_table.private_rtb.id]
  vpc_endpoint_type = "Gateway"
  tags = {
    Name        = "${var.vpc_name}-dynamodb-endpoint"
    Terraform   = "true"
    Environment = "Production"
    Description = "DynamoDB Gateway Endpoint for ${var.vpc_name}"
  }

  policy = file("${path.module}/policies/dynamodb-endpoint-policy.json")
}


# KMS Gateway Endpoint
resource "aws_vpc_endpoint" "kms_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.kms"
  vpc_endpoint_type = "Interface"

  # subnet_ids = aws_subnet.private[*].id
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]

  security_group_ids = [var.vpc_endpoint_sg_id]

  private_dns_enabled = true

  tags = {
    Name        = "${var.vpc_name}-kms-endpoint"
    Terraform   = "true"
    Environment = "Production"
    Description = "KMS Gateway Endpoint for ${var.vpc_name}"
  }
}

