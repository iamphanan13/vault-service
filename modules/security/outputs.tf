output "public_sg_id" {
  description = "ID of the public security group"
  value       = aws_security_group.public_sg.id
}

output "private_sg_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private_sg.id
}

output "kms_vpc_endpoint_sg_id" {
  description = "ID of the KMS VPC Endpoint security group"
  value       = aws_security_group.kms_vpc_endpoint_sg.id
}

output "rds_sg_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}


output "nlb_sg_id" {
  description = "ID of the Network Load Balancer security group"
  value       = aws_security_group.nlb_sg.id
}

