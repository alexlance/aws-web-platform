resource "aws_acm_certificate" "main" {
  provider          = aws.virginia
  domain_name       = var.domain
  subject_alternative_names = ["www.${var.domain}"]
  validation_method = "DNS"
}

output "dns_validation_record" {
  value = aws_acm_certificate.main.domain_validation_options
}

resource "aws_acm_certificate" "api" {
  provider          = aws.virginia
  domain_name       = "api.${var.domain}"
  validation_method = "DNS"
}

output "dns_api_validation_record" {
  value = aws_acm_certificate.api.domain_validation_options
}
