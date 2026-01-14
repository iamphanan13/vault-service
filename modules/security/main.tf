# Security group for public instance
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Security group for public instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip]
    description = "Allow access to SSH from my IP"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip]
    description = "Allow access to Grafana from my IP"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.vpc_name}-public-sg"
    Terraform   = "true"
    Environment = "Production"
    Description = "Security group for public instance"
  }
}


# Security group for private instance
resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Security group for private instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8200
    to_port         = 8200
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8200
    to_port         = 8200
    protocol        = "tcp"
    security_groups = [aws_security_group.nlb_sg.id]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8201
    to_port   = 8201
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.vpc_name}-private-sg"
    Terraform   = "true"
    Environment = "Production"
    Description = "Security group for Vault private instance"
  }
}


resource "aws_security_group" "nlb_sg" {
  name        = "nlb-sg"
  description = "Security group for private instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.vpc_name}-nlb-sg"
    Terraform   = "true"
    Environment = "Production"
    Description = "Security group for Vault Network Load Balancer"
  }
}


# Security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.private_sg.id]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port       = 22
  #   to_port         = 22
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.public_sg.id]
  # }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.private_sg.id]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.vpc_name}-rds-sg"
    Terraform   = "true"
    Environment = "Production"
    Description = "Security group for Vault private instance"
  }
}

# KMS VPC Endpoint Security Group
resource "aws_security_group" "kms_vpc_endpoint_sg" {
  name        = "kms-vpc-endpoint-sg"
  description = "Security group for KMS VPC Endpoint"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.private_sg.id]
    # cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.vpc_name}-kms-vpc-endpoint-sg"
    Terraform   = "true"
    Environment = "Production"
    Description = "Security group for KMS VPC Endpoint"
  }
}



