resource "aws_instance" "bastion" {
  ami                    = var.public_ami_id        # "ami-0c625341be5acdd55"
  instance_type          = var.public_instance_type # "t3.micro"
  subnet_id              = var.public_subnet_id     # aws_subnet.public[0].id
  vpc_security_group_ids = [var.public_sg_id]
  key_name               = var.public_key_name # aws_security_group.vault.id

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  ebs_block_device {
    device_name = "/dev/sdg"
    encrypted   = true
  }
  tags = {
    Name        = "Bastion Host Instance"
    Terraform   = "true"
    Environment = "Production"
    Description = "Bastion Host EC2 instance"
  }
}

resource "aws_instance" "vault" {
  ami                    = var.private_ami_id        # "ami-0c625341be5acdd55"
  instance_type          = var.private_instance_type # "t3.micro"
  subnet_id              = var.private_subnet_id     # aws_subnet.public[0].id
  vpc_security_group_ids = [var.private_sg_id]       # aws_security_group.vault.id
  key_name               = var.private_key_name      # ec2-lab01

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  ebs_block_device {
    device_name = "/dev/sdg"
    encrypted   = true
  }

  tags = {
    Name        = "Vault Service Instance"
    Terraform   = "true"
    Environment = "Production"
    Description = "Vault Service EC2 instance"
  }
}