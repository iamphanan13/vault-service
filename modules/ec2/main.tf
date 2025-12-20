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
    encrypted             = var.public_root_block_encrypted             // bool
    volume_size           = var.public_root_block_volume_size           // number
    volume_type           = var.public_root_block_volume_type           // string
    delete_on_termination = var.public_root_block_delete_on_termination // bool
  }

  ebs_block_device {
    device_name           = "/dev/sdg"
    encrypted             = var.public_ebs_block_encrypted             // bool
    volume_size           = var.public_ebs_block_ebs_volume_size       // number
    volume_type           = var.public_ebs_block_ebs_volume_type       // string
    delete_on_termination = var.public_ebs_block_delete_on_termination // bool
  }
  tags = {
    Name        = "Bastion Host Instance"
    Terraform   = "true"
    Environment = "Production"
    Description = "Bastion Host EC2 instance"
  }
}
# IAM Role for Vault Instance
resource "aws_iam_role" "vault_s3_role" {
  name = "vault-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_policy" "vault_s3_policy" {
  name   = "vault-s3-access"
  policy = data.aws_iam_policy_document.vault_policy.json
}



resource "aws_iam_role_policy_attachment" "vault_s3_policy_attachment" {
  role       = aws_iam_role.vault_s3_role.name
  policy_arn = aws_iam_policy.vault_s3_policy.arn
}



resource "aws_iam_instance_profile" "vault_s3_instance_profile" {
  name = "vault-s3-instance-profile"
  role = aws_iam_role.vault_s3_role.name
}

resource "aws_instance" "vault_1" {
  ami                    = var.private_ami_id        # "ami-0c625341be5acdd55"
  instance_type          = var.private_instance_type # "t3.micro"
  subnet_id              = var.private_subnet_id     # aws_subnet.private[0].id
  vpc_security_group_ids = [var.private_sg_id]
  key_name               = var.private_key_name # aws_security_group.vault.id

  private_ip = "10.0.10.10"

  iam_instance_profile = aws_iam_instance_profile.vault_s3_instance_profile.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted             = var.private_root_block_encrypted             // bool
    volume_size           = var.private_root_block_volume_size           // number
    volume_type           = var.private_root_block_volume_type           // string
    delete_on_termination = var.private_root_block_delete_on_termination // bool
  }

  ebs_block_device {
    device_name           = "/dev/sdg"
    encrypted             = var.private_ebs_block_encrypted             // bool
    volume_size           = var.private_ebs_block_ebs_volume_size       // number
    volume_type           = var.private_ebs_block_ebs_volume_type       // string
    delete_on_termination = var.private_ebs_block_delete_on_termination // bool
  }

  user_data_base64 = base64encode(file("${path.module}/scripts/vault-scripts-1.sh"))

  tags = {
    Name        = "vault-1"
    Terraform   = "true"
    Environment = "Production"
    Description = "Vault Service EC2 instance"
  }
}

resource "aws_instance" "vault_2" {
  ami                    = var.private_ami_id            # "ami-0c625341be5acdd55"
  instance_type          = var.private_instance_type     # "t3.micro"
  subnet_id              = var.private_vault_2_subnet_id # aws_subnet.private[0].id
  vpc_security_group_ids = [var.private_sg_id]
  key_name               = var.private_key_name # aws_security_group.vault.id

  private_ip = "10.0.11.10"

  iam_instance_profile = aws_iam_instance_profile.vault_s3_instance_profile.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted             = var.private_root_block_encrypted             // bool
    volume_size           = var.private_root_block_volume_size           // number
    volume_type           = var.private_root_block_volume_type           // string
    delete_on_termination = var.private_root_block_delete_on_termination // bool
  }

  ebs_block_device {
    device_name           = "/dev/sdg"
    encrypted             = var.private_ebs_block_encrypted             // bool
    volume_size           = var.private_ebs_block_ebs_volume_size       // number
    volume_type           = var.private_ebs_block_ebs_volume_type       // string
    delete_on_termination = var.private_ebs_block_delete_on_termination // bool
  }

  user_data_base64 = base64encode(file("${path.module}/scripts/vault-scripts-2.sh"))

  tags = {
    Name        = "vault-2"
    Terraform   = "true"
    Environment = "Production"
    Description = "Vault Service EC2 instance"
  }
}


resource "aws_lb" "vault_nlb" {
  name               = "vault-nlb"
  load_balancer_type = "network"
  internal           = true
  subnets            = var.vault_nlb_subnets
  security_groups    = [var.nlb_sg_id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "vault" {
  name        = "vault-tg"
  port        = 8200
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2

    protocol = "HTTPS"
    path     = "/v1/sys/health"
    port     = "8200"

    matcher = "200,429"

  }
}


resource "aws_lb_target_group_attachment" "vault_1" {
  for_each = {
    vault1 = aws_instance.vault_1.id
    vault2 = aws_instance.vault_2.id
  }

  target_group_arn = aws_lb_target_group.vault.arn
  target_id        = each.value
  port             = 8200
}

resource "aws_lb_listener" "vault_listener" {
  load_balancer_arn = aws_lb.vault_nlb.arn
  port              = 8200
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }
}
