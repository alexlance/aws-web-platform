resource aws_s3_bucket "main" {
  bucket = var.domain
  tags = {
    Name = var.domain
  }
}

resource aws_s3_bucket_ownership_controls "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource aws_s3_bucket_public_access_block "main" {
  bucket = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource aws_s3_bucket_acl "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "log-delivery-write"
}

resource aws_s3_bucket_server_side_encryption_configuration "main" {
  bucket = var.domain
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
