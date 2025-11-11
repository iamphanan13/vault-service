variable "my_ip" {
  description = "My public IP address"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "vault"
}