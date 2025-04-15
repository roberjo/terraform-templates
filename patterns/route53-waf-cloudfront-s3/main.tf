/**
 * # Route53 hosted zone with WAF ACL security and cloudfront distribution and s3 static content with kms key encryption at rest Pattern
 *
 * This pattern creates a complete serverless architecture with Route53 hosted zone entries pointing to a cloudfront distribution connected to a s3 bucket for static content files with kms encryption at rest.
 */

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

# Create KMS key for S3 bucket encryption
resource "aws_kms_key" "s3_key" {
  count = var.create_kms_key ? 1 : 0
  
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.kms_key_enable_rotation
  policy                  = var.kms_key_policy
  
  tags = var.tags
}

resource "aws_kms_alias" "s3_key_alias" {
  count = var.create_kms_key ? 1 : 0
  
  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.s3_key[0].key_id
}

# Create S3 bucket for static content
resource "aws_s3_bucket" "content" {
  bucket = var.bucket_name
  
  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "content" {
  bucket = aws_s3_bucket.content.id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "content" {
  depends_on = [aws_s3_bucket_ownership_controls.content]
  
  bucket = aws_s3_bucket.content.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "content" {
  bucket = aws_s3_bucket.content.id
  
  versioning_configuration {
    status = var.enable_bucket_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "content" {
  bucket = aws_s3_bucket.content.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.create_kms_key || var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.create_kms_key ? aws_kms_key.s3_key[0].arn : var.kms_key_arn
    }
  }
}

# S3 bucket policy to allow CloudFront access
resource "aws_s3_bucket_policy" "content" {
  bucket = aws_s3_bucket.content.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.content.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}

# Create CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for ${var.bucket_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Create CloudFront distribution
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = var.cloudfront_enable_ipv6
  comment             = var.cloudfront_comment
  default_root_object = var.cloudfront_default_root_object
  price_class         = var.cloudfront_price_class
  
  # S3 origin
  origin {
    domain_name              = aws_s3_bucket.content.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.content.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }
  
  # Default cache behavior
  default_cache_behavior {
    allowed_methods        = var.cloudfront_allowed_methods
    cached_methods         = var.cloudfront_cached_methods
    target_origin_id       = "S3-${aws_s3_bucket.content.bucket}"
    viewer_protocol_policy = var.cloudfront_viewer_protocol_policy
    
    cache_policy_id          = var.cloudfront_cache_policy_id
    origin_request_policy_id = var.cloudfront_origin_request_policy_id
    
    compress = var.cloudfront_enable_compression
    
    dynamic "function_association" {
      for_each = var.cloudfront_function_associations
      
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }
  
  # Custom error responses
  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_responses
    
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }
  
  # Custom domain and SSL
  dynamic "aliases" {
    for_each = length(var.cloudfront_aliases) > 0 ? [1] : []
    
    content {
      aliases = var.cloudfront_aliases
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = var.acm_certificate_arn == null
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn != null ? var.cloudfront_ssl_support_method : null
    minimum_protocol_version       = var.acm_certificate_arn != null ? var.cloudfront_minimum_protocol_version : "TLSv1"
  }
  
  # WAF integration
  web_acl_id = var.waf_acl_arn
  
  # Geo restrictions
  dynamic "restrictions" {
    for_each = length(var.cloudfront_geo_restriction_locations) > 0 ? [1] : []
    
    content {
      geo_restriction {
        restriction_type = var.cloudfront_geo_restriction_type
        locations        = var.cloudfront_geo_restriction_locations
      }
    }
  }
  
  tags = var.tags
  
  depends_on = [aws_s3_bucket_policy.content]
}

# Create Route53 records
resource "aws_route53_zone" "this" {
  count = var.create_route53_zone ? 1 : 0
  
  name = var.domain_name
  
  tags = var.tags
}

resource "aws_route53_record" "a" {
  count = length(var.cloudfront_aliases) > 0 ? length(var.cloudfront_aliases) : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.this[0].zone_id : var.route53_zone_id
  name    = var.cloudfront_aliases[count.index]
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aaaa" {
  count = var.cloudfront_enable_ipv6 && length(var.cloudfront_aliases) > 0 ? length(var.cloudfront_aliases) : 0
  
  zone_id = var.create_route53_zone ? aws_route53_zone.this[0].zone_id : var.route53_zone_id
  name    = var.cloudfront_aliases[count.index]
  type    = "AAAA"
  
  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
} 