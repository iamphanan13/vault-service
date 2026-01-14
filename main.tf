module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = "vault"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_count  = 2
  private_subnet_count = 2
  # rds_subnet_count     = 2
  enable_nat_gateway = false # Set to false to disable NAT Gateway
  vpc_endpoint_sg_id = module.security.kms_vpc_endpoint_sg_id

}

# module "rds" {
#   source               = "./modules/rds"
#   db_subnet_group_name = module.vpc.db_subnet_group_name
#   rds_sg_id            = module.security.rds_sg_id
# }


module "route53" {
  source            = "./modules/route53"
  vpc_id            = module.vpc.vpc_id
  vault_nlb_name    = module.ec2.vault_nlb_name
  vault_nlb_zone_id = module.ec2.vault_nlb_zone_id
}

module "ec2" {
  source = "./modules/ec2"
  # This block for Instance in Public Subnet
  public_subnet_id                        = module.vpc.public_subnet_ids[0]
  public_instance_type                    = "t3.micro"
  public_ami_id                           = "ami-0ae6ec98e800a5d64"
  public_sg_id                            = module.security.public_sg_id
  public_key_name                         = var.key_name
  public_root_block_encrypted             = true
  public_root_block_volume_size           = 8
  public_root_block_volume_type           = "gp3"
  public_root_block_delete_on_termination = true
  public_ebs_block_ebs_volume_size        = 8
  public_ebs_block_ebs_volume_type        = "gp3"
  public_ebs_block_encrypted              = true
  public_ebs_block_delete_on_termination  = true


  # This Part for Instance in Private Subnet
  private_subnet_id                        = module.vpc.private_subnet_ids[0]
  private_vault_2_subnet_id                = module.vpc.private_subnet_ids[1]
  private_instance_type                    = "t3.micro"
  private_ami_id                           = "ami-0aed7b2b20a72b61c"
  private_sg_id                            = module.security.private_sg_id
  private_key_name                         = var.key_name
  private_root_block_encrypted             = true
  private_root_block_volume_size           = 8
  private_root_block_volume_type           = "gp3"
  private_root_block_delete_on_termination = true
  private_ebs_block_ebs_volume_size        = 8
  private_ebs_block_ebs_volume_type        = "gp3"
  private_ebs_block_encrypted              = true
  private_ebs_block_delete_on_termination  = true

  dynamodb_table_arn = module.dynamodb.dynamodb_table_arn
  vpc_id             = module.vpc.vpc_id
  nlb_sg_id          = module.security.nlb_sg_id
  vault_nlb_subnets  = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "security" {
  source       = "./modules/security"
  vpc_name     = "var.vpc_name"
  vpc_id       = module.vpc.vpc_id
  my_public_ip = "${var.my_ip}/32"
  public_sg_id = module.security.public_sg_id

}
