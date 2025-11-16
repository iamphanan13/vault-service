module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = "vault"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_count  = 2
  private_subnet_count = 2
  enable_nat_gateway   = false # Set to false to disable NAT Gateway
}

module "ec2" {
  source = "./modules/ec2"
  # This block for Instance in Public Subnet
  public_subnet_id                        = module.vpc.public_subnet_ids[0]
  public_instance_type                    = "t3.micro"
  public_ami_id                           = "ami-00c1c82da03d97cc0"
  public_sg_id                            = module.security.public_sg_id
  public_key_name                         = "ec2-lab01"
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
  private_instance_type                    = "t3.micro"
  private_ami_id                           = "ami-0fe287fd4d8319cdc"
  private_sg_id                            = module.security.private_sg_id
  private_key_name                         = "ec2-lab01"
  private_root_block_encrypted             = true
  private_root_block_volume_size           = 8
  private_root_block_volume_type           = "gp3"
  private_root_block_delete_on_termination = true
  private_ebs_block_ebs_volume_size        = 8
  private_ebs_block_ebs_volume_type        = "gp3"
  private_ebs_block_encrypted              = true
  private_ebs_block_delete_on_termination  = true
}

module "security" {
  source       = "./modules/security"
  vpc_name     = "var.vpc_name"
  vpc_id       = module.vpc.vpc_id
  my_public_ip = "${var.my_ip}/32"
  public_sg_id = module.security.public_sg_id
}