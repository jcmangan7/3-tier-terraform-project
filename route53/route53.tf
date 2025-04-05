resource "aws_route53_record" "dns_record" {
  zone_id = var.zone_id  # you must get this from the AWS console in Route 53 based on the dns name you used
  name    = var.dns_name # name of your registered domain in route 53
  type    = "A"

  alias {
    name                   = var.apci_jupiter_alb_dns_name
    zone_id                = var.apci_jupiter_alb_zone_id # the zone id for your ALB
    evaluate_target_health = true
  }
}