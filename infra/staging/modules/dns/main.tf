resource "aws_route53_zone" "main" {
  name = var.root_domain
  tags = var.tags
}
# TODO: ドメイン取得元でネームサーバーを↑のホストゾーンに向ける必要がある
resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.root_domain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "cert_validation_main" {
  for_each = {
    for dvo in var.acm_main_domain_valid_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"

  zone_id = aws_route53_zone.main.zone_id
}
