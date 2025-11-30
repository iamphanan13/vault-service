resource "aws_db_instance" "vault-rds" {
  allocated_storage           = 20
  db_name                     = "vault"
  engine                      = "mysql"
  engine_version              = "8.0.44"
  instance_class              = "db.t3.medium"
  username                    = "vault"
  manage_master_user_password = true
  parameter_group_name        = "default.mysql8.0"
  skip_final_snapshot         = true

  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = var.db_subnet_group_name

  tags = {
    Name        = "Vault RDS Instance"
    Terraform   = "true"
    Environment = "Production"
    Description = "Vault RDS instance"
  }
}