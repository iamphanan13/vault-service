variable "vpc_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}


variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number

}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number

}

# variable "rds_subnet_count" {
#   description = "Number of private subnets"
#   type        = number

# }


variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false
}

# variable "tags" {
#   description = "A map of tags to assign to the resource"
#   type        = map(string)
#   default     = {}
# }





variable "vpc_endpoint_sg_id" {
  description = "Security Group ID for VPC Endpoint"
  type        = string
}
