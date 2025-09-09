data "aws_route53_zone" "main" {
  name       = "app.salvador.com." # Ensure the domain name ends with a dot
  depends_on = [aws_route53_zone.main]
}

resource "aws_route53_zone" "main" {
  name = "app.salvador.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"
  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = true
  }
}