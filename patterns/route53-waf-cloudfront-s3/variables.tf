/**
 * # Route53 hosted zone with WAF ACL security and cloudfront distribution and s3 static content with kms key encryption at rest Pattern - Variables
 *
 * This file contains all the variables used in the Route53 with WAF, CloudFront, and S3 pattern.
 */

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Domain variables
variable "domain_name" {
  description = "Domain name for the Route53 hosted zone"
  type        = string
}

variable "create_route53_zone" {
  description = "Whether to create a new Route53 hosted zone"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "ID of an existing Route53 hosted zone (if not creating a new one)"
  type        = string
  default     = null
}

# S3 bucket variables
variable "bucket_name" {
  description = "Name of the S3 bucket for static content"
  type        = string
}

variable "enable_bucket_versioning" {
  description = "Whether to enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

# KMS variables
variable "create_kms_key" {
  description = "Whether to create a new KMS key for S3 bucket encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of an existing KMS key for S3 bucket encryption (if not creating a new one)"
  type        = string
  default     = null
}

variable "kms_key_deletion_window_in_days" {
  description = "Waiting period before KMS key deletion"
  type        = number
  default     = 30
}

variable "kms_key_enable_rotation" {
  description = "Whether to enable automatic rotation for the KMS key"
  type        = bool
  default     = true
}

variable "kms_key_alias" {
  description = "Alias for the KMS key"
  type        = string
  default     = "s3-static-content-encryption"
}

variable "kms_key_policy" {
  description = "Policy for the KMS key"
  type        = string
  default     = null
}

# CloudFront variables
variable "cloudfront_comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
  default     = "CloudFront distribution for static content"
}

variable "cloudfront_default_root_object" {
  description = "Default root object for the CloudFront distribution"
  type        = string
  default     = "index.html"
}

variable "cloudfront_price_class" {
  description = "Price class for the CloudFront distribution (PriceClass_All, PriceClass_200, PriceClass_100)"
  type        = string
  default     = "PriceClass_100"
}

variable "cloudfront_enable_ipv6" {
  description = "Whether to enable IPv6 for the CloudFront distribution"
  type        = bool
  default     = true
}

variable "cloudfront_allowed_methods" {
  description = "HTTP methods that CloudFront processes and forwards to the S3 bucket"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cloudfront_cached_methods" {
  description = "HTTP methods for which CloudFront caches responses"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cloudfront_viewer_protocol_policy" {
  description = "Protocol policy for viewer connections (redirect-to-https, https-only, allow-all)"
  type        = string
  default     = "redirect-to-https"
}

variable "cloudfront_cache_policy_id" {
  description = "ID of the cache policy for the CloudFront distribution"
  type        = string
  default     = null
}

variable "cloudfront_origin_request_policy_id" {
  description = "ID of the origin request policy for the CloudFront distribution"
  type        = string
  default     = null
}

variable "cloudfront_enable_compression" {
  description = "Whether to enable compression for the CloudFront distribution"
  type        = bool
  default     = true
}

variable "cloudfront_function_associations" {
  description = "CloudFront function associations"
  type = list(object({
    event_type   = string
    function_arn = string
  }))
  default = []
}

variable "cloudfront_custom_error_responses" {
  description = "Custom error responses for the CloudFront distribution"
  type = list(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = number
  }))
  default = []
}

variable "cloudfront_aliases" {
  description = "Alternate domain names for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "cloudfront_ssl_support_method" {
  description = "SSL support method for the CloudFront distribution (sni-only, vip)"
  type        = string
  default     = "sni-only"
}

variable "cloudfront_minimum_protocol_version" {
  description = "Minimum TLS protocol version for the CloudFront distribution"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "cloudfront_geo_restriction_type" {
  description = "Method to use for geographic restrictions (whitelist, blacklist, none)"
  type        = string
  default     = "none"
}

variable "cloudfront_geo_restriction_locations" {
  description = "ISO 3166-1-alpha-2 country codes for geographic restrictions"
  type        = list(string)
  default     = []
}

# SSL Certificate variables
variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the CloudFront distribution"
  type        = string
  default     = null
}

# WAF variables
variable "waf_acl_arn" {
  description = "ARN of the WAF ACL to associate with the CloudFront distribution"
  type        = string
  default     = null
} 