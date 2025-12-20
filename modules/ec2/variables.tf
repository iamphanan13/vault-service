
variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

variable "private_vault_2_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}
variable "private_ami_id" {
  description = "ID of the private AMI"
  type        = string
}

variable "private_instance_type" {
  description = "Instance type of the private instance"
  type        = string
}

variable "private_sg_id" {
  description = "ID of the private security group"
  type        = string
}

variable "private_key_name" {
  description = "Name of the private key"
  type        = string
}


# Public Instance Variables

variable "public_ami_id" {
  description = "ID of the public AMI"
  type        = string
}

variable "public_instance_type" {
  description = "Instance type of the public instance"
  type        = string
}

variable "public_sg_id" {
  description = "ID of the public security group"
  type        = string
}

variable "public_key_name" {
  description = "Name of the public key"
  type        = string
}


variable "public_root_block_encrypted" {
  description = "Whether the root block device should be encrypted for the public instance"
  type        = bool
}

variable "public_root_block_volume_size" {
  description = "Size (in GiB) of the root block device for the public instance"
  type        = number
}

variable "public_root_block_volume_type" {
  description = "Type of the root block device for the public instance"
  type        = string
}

variable "public_root_block_delete_on_termination" {
  description = "Whether the root block device is deleted on termination for the public instance"
  type        = bool
}

variable "public_ebs_block_ebs_volume_size" {
  description = "Size (in GiB) of the EBS volume attached to the public instance"
  type        = number
}

variable "public_ebs_block_ebs_volume_type" {
  description = "Type of the EBS volume attached to the public instance"
  type        = string
}

variable "public_ebs_block_encrypted" {
  description = "Whether the EBS volume attached to the public instance is encrypted"
  type        = bool
}

variable "public_ebs_block_delete_on_termination" {
  description = "Whether the EBS volume is deleted on instance termination for the public instance"
  type        = bool
}

variable "private_root_block_encrypted" {
  description = "Whether the root block device should be encrypted for the private instance"
  type        = bool
}

variable "private_root_block_volume_size" {
  description = "Size (in GiB) of the root block device for the private instance"
  type        = number
}

variable "private_root_block_volume_type" {
  description = "Type of the root block device for the private instance"
  type        = string
}

variable "private_root_block_delete_on_termination" {
  description = "Whether the root block device is deleted on termination for the private instance"
  type        = bool
}

variable "private_ebs_block_ebs_volume_size" {
  description = "Size (in GiB) of the EBS volume attached to the private instance"
  type        = number
}

variable "private_ebs_block_ebs_volume_type" {
  description = "Type of the EBS volume attached to the private instance"
  type        = string
}

variable "private_ebs_block_encrypted" {
  description = "Whether the EBS volume attached to the private instance is encrypted"
  type        = bool
}

variable "private_ebs_block_delete_on_termination" {
  description = "Whether the EBS volume is deleted on instance termination for the private instance"
  type        = bool
}


variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}


variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "nlb_sg_id" {
  type = string
}

variable "vault_nlb_subnets" {
  type = list(string)
}
