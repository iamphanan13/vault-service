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
  policy = file("${path.module}/policies/vault-s3-policy.json")
}



resource "aws_iam_role_policy_attachment" "vault_s3_policy_attachment" {
  role       = aws_iam_role.vault_s3_role.name
  policy_arn = aws_iam_policy.vault_s3_policy.arn
}



resource "aws_iam_instance_profile" "vault_s3_instance_profile" {
  name = "vault-s3-instance-profile"
  role = aws_iam_role.vault_s3_role.name
}

resource "aws_launch_template" "vault" {
  name_prefix   = "vault-lt-"
  image_id      = var.private_ami_id
  instance_type = var.private_instance_type
  key_name      = var.private_key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.vault_s3_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.private_sg_id]
    subnet_id                   = var.private_subnet_id
  }

  metadata_options {
    http_tokens = "required"
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted             = var.private_root_block_encrypted
      volume_size           = var.private_root_block_volume_size
      volume_type           = var.private_root_block_volume_type
      delete_on_termination = var.private_root_block_delete_on_termination
    }
  }

  user_data = base64encode(file("${path.module}/scripts/vault-scripts.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "Vault Service Instance"
      Terraform   = "true"
      Environment = "Production"
      Description = "Vault Service EC2 instance"
    }
  }
}

resource "aws_autoscaling_group" "vault" {
  name                = "vault-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [var.private_subnet_id]

  launch_template {
    id      = aws_launch_template.vault.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Vault Service Instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "vault_cpu_policy" {
  name                   = "vault-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.vault.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 45.0
  }
}
