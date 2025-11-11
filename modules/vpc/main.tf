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
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.vpc_name}-public-${count.index + 1}"
    Terraform   = "true"
    Environment = "Production"
  }
}

# Private subnets /24, starting from 10.0.10.0/24
resource "aws_subnet" "private" {
  count      = var.private_subnet_count
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 10)


  tags = {
    Name        = "${var.vpc_name}-private-${count.index + 1}"
    Terraform   = "true"
    Environment = "Production"
  }
}

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