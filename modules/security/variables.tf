variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "my_public_ip" {
  description = "My public IP address"
  type        = string
}

variable "public_sg_id" {
  description = "ID of the public security group"
  type        = string
}