output "public_ip_instance" {
  value = aws_instance.bastion.public_ip
}

# output "private_ip_instance" {
#   value = aws_instance.vault.private_ip
# }

output "vault_nlb_name" {
  value = aws_lb.vault_nlb.dns_name
}

output "vault_nlb_zone_id" {
  value = aws_lb.vault_nlb.zone_id
}
