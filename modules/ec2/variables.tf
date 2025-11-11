
variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "private_subnet_id" {
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

variable "private_key_name" {
  description = "Name of the private key"
  type        = string
}