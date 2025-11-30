output "public_ip_instance" {
  value = aws_instance.bastion.public_ip
}

# output "private_ip_instance" {
#   value = aws_instance.vault.private_ip
# }