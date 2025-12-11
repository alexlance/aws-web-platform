resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = ["s3:Get*"]
        Resource = "${aws_s3_bucket.main.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "Cloudfront OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.domain} website"
  default_root_object = "index.html"
  retain_on_delete    = false
  aliases = [
    var.domain,
    "www.${var.domain}"
  ]

  origin {
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name
    origin_id   = "origin-${var.name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_path = "/website"
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-${var.name}"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      query_string_cache_keys = ["version"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
  }


  # price_class = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name      = var.name
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.main.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1"
  }

  logging_config {
    bucket          = "${var.domain}.s3.amazonaws.com"
    include_cookies = false
    prefix          = "logs"
  }

}

output "url_static" {
  value = aws_cloudfront_distribution.main.domain_name
}


