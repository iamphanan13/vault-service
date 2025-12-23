resource "aws_route53_zone" "service_internal" {
  name = "service.internal"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = "service.internal"
  }
}

resource "aws_route53_record" "vault" {
  zone_id = aws_route53_zone.service_internal.zone_id
  name    = "vault.service.internal"
  type    = "A"

  alias {
    name = var.vault_nlb_name
    zone_id = var.vault_nlb_zone_id
    evaluate_target_health = true
  }
}