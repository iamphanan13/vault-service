variable "my_ip" {
  description = "My public IP address"
  type        = string
}

variable "key_name" {
  description = "Key for Instance"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "vault"
}