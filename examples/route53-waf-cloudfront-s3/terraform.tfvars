###########################
# General Configuration #
###########################
aws_region = "us-east-1"

default_tags = {
  Environment = "dev"
  Project     = "static-website-example"
  Terraform   = "true"
}

tags = {
  Owner       = "example-team"
  Application = "example-website"
}

###########################
# Domain Configuration   #
###########################
domain_name         = "my-example-domain.com" # Change to your domain
create_route53_zone = true
# route53_zone_id   = "Z1234567890ABCDEFGHIJ" # Uncomment if using existing zone

###########################
# S3 Bucket Configuration #
###########################
bucket_name             = "my-example-domain-com-static-content" # Change to a globally unique name
enable_bucket_versioning = true

###########################
# KMS Configuration      #
###########################
create_kms_key                  = true
kms_key_deletion_window_in_days = 7 # Use lower value for examples
kms_key_enable_rotation         = true
kms_key_alias                   = "s3-example-static-content-encryption"
# kms_key_arn                   = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-ab12-cd34-ef56-abcdef123456" # Uncomment if using existing KMS key

###########################
# CloudFront Configuration #
###########################
cloudfront_comment             = "CloudFront distribution for my-example-domain.com static content"
cloudfront_default_root_object = "index.html"
cloudfront_price_class         = "PriceClass_100"
cloudfront_enable_ipv6         = true
cloudfront_allowed_methods     = ["GET", "HEAD", "OPTIONS"]
cloudfront_cached_methods      = ["GET", "HEAD"]
cloudfront_viewer_protocol_policy = "redirect-to-https"
cloudfront_enable_compression  = true

# CloudFront Cache and Origin Request Policies (Using managed policies as defaults)
cloudfront_cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
cloudfront_origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin

# CloudFront Aliases (Custom Domains) - MUST match domain_name or subdomains
cloudfront_aliases = ["my-example-domain.com", "www.my-example-domain.com"]
cloudfront_ssl_support_method = "sni-only"
cloudfront_minimum_protocol_version = "TLSv1.2_2021"

# CloudFront Custom Error Responses
cloudfront_custom_error_responses = [
  {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
    error_caching_min_ttl = 10
  },
  {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
    error_caching_min_ttl = 10
  }
]

# CloudFront Geo Restrictions
cloudfront_geo_restriction_type = "none"
# cloudfront_geo_restriction_locations = ["US", "CA", "GB", "DE"] # Uncomment if using geo restrictions

###########################
# SSL Certificate        #
###########################
# NOTE: You MUST provide a valid ACM certificate ARN in us-east-1 for the domain(s) specified in cloudfront_aliases.
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/YOUR-CERTIFICATE-ID-HERE" # ** REPLACE THIS PLACEHOLDER **

###########################
# WAF Configuration      #
###########################
# waf_acl_arn = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/example-waf-acl/abcd1234-ab12-cd34-ef56-abcdef123456" # Optional: Uncomment and provide WAF ACL ARN 