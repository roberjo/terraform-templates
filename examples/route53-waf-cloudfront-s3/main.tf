provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

module "static_website" {
  source = "../../patterns/route53-waf-cloudfront-s3"

  # Pass all variables defined in terraform.tfvars
  aws_region                          = var.aws_region
  default_tags                        = var.default_tags
  tags                                = var.tags
  domain_name                         = var.domain_name
  create_route53_zone                 = var.create_route53_zone
  route53_zone_id                     = var.route53_zone_id
  bucket_name                         = var.bucket_name
  enable_bucket_versioning            = var.enable_bucket_versioning
  create_kms_key                      = var.create_kms_key
  kms_key_arn                         = var.kms_key_arn
  kms_key_deletion_window_in_days     = var.kms_key_deletion_window_in_days
  kms_key_enable_rotation             = var.kms_key_enable_rotation
  kms_key_alias                       = var.kms_key_alias
  kms_key_policy                      = var.kms_key_policy
  cloudfront_comment                  = var.cloudfront_comment
  cloudfront_default_root_object      = var.cloudfront_default_root_object
  cloudfront_price_class              = var.cloudfront_price_class
  cloudfront_enable_ipv6              = var.cloudfront_enable_ipv6
  cloudfront_allowed_methods          = var.cloudfront_allowed_methods
  cloudfront_cached_methods           = var.cloudfront_cached_methods
  cloudfront_viewer_protocol_policy   = var.cloudfront_viewer_protocol_policy
  cloudfront_cache_policy_id          = var.cloudfront_cache_policy_id
  cloudfront_origin_request_policy_id = var.cloudfront_origin_request_policy_id
  cloudfront_enable_compression       = var.cloudfront_enable_compression
  cloudfront_function_associations    = var.cloudfront_function_associations
  cloudfront_custom_error_responses   = var.cloudfront_custom_error_responses
  cloudfront_aliases                  = var.cloudfront_aliases
  cloudfront_ssl_support_method       = var.cloudfront_ssl_support_method
  cloudfront_minimum_protocol_version = var.cloudfront_minimum_protocol_version
  cloudfront_geo_restriction_type     = var.cloudfront_geo_restriction_type
  cloudfront_geo_restriction_locations = var.cloudfront_geo_restriction_locations
  acm_certificate_arn                 = var.acm_certificate_arn
  waf_acl_arn                         = var.waf_acl_arn
}

# Define necessary variables for the example
variable "aws_region" {
  description = "AWS region for the example deployment."
  type        = string
}

variable "default_tags" {
  description = "Default tags for all resources in the example."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Specific tags for resources in the example."
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "Domain name for the Route53 hosted zone."
  type        = string
}

variable "create_route53_zone" {
  description = "Whether to create a new Route53 hosted zone."
  type        = bool
}

variable "route53_zone_id" {
  description = "ID of an existing Route53 hosted zone."
  type        = string
  default     = null
}

variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
}

variable "enable_bucket_versioning" {
  description = "Enable S3 bucket versioning."
  type        = bool
}

variable "create_kms_key" {
  description = "Whether to create a new KMS key."
  type        = bool
}

variable "kms_key_arn" {
  description = "ARN of an existing KMS key."
  type        = string
  default     = null
}

variable "kms_key_deletion_window_in_days" {
  description = "KMS key deletion window."
  type        = number
}

variable "kms_key_enable_rotation" {
  description = "Enable KMS key rotation."
  type        = bool
}

variable "kms_key_alias" {
  description = "Alias for the KMS key."
  type        = string
}

variable "kms_key_policy" {
  description = "Policy for the KMS key."
  type        = string
  default     = null
}

variable "cloudfront_comment" {
  description = "CloudFront distribution comment."
  type        = string
}

variable "cloudfront_default_root_object" {
  description = "CloudFront default root object."
  type        = string
}

variable "cloudfront_price_class" {
  description = "CloudFront price class."
  type        = string
}

variable "cloudfront_enable_ipv6" {
  description = "Enable IPv6 for CloudFront."
  type        = bool
}

variable "cloudfront_allowed_methods" {
  description = "CloudFront allowed HTTP methods."
  type        = list(string)
}

variable "cloudfront_cached_methods" {
  description = "CloudFront cached HTTP methods."
  type        = list(string)
}

variable "cloudfront_viewer_protocol_policy" {
  description = "CloudFront viewer protocol policy."
  type        = string
}

variable "cloudfront_cache_policy_id" {
  description = "CloudFront cache policy ID."
  type        = string
  default     = null
}

variable "cloudfront_origin_request_policy_id" {
  description = "CloudFront origin request policy ID."
  type        = string
  default     = null
}

variable "cloudfront_enable_compression" {
  description = "Enable CloudFront compression."
  type        = bool
}

variable "cloudfront_function_associations" {
  description = "CloudFront function associations."
  type = list(object({
    event_type   = string
    function_arn = string
  }))
  default = []
}

variable "cloudfront_custom_error_responses" {
  description = "CloudFront custom error responses."
  type = list(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = number
  }))
  default = []
}

variable "cloudfront_aliases" {
  description = "CloudFront alternate domain names."
  type        = list(string)
}

variable "cloudfront_ssl_support_method" {
  description = "CloudFront SSL support method."
  type        = string
}

variable "cloudfront_minimum_protocol_version" {
  description = "CloudFront minimum TLS protocol version."
  type        = string
}

variable "cloudfront_geo_restriction_type" {
  description = "CloudFront geo restriction type."
  type        = string
}

variable "cloudfront_geo_restriction_locations" {
  description = "CloudFront geo restriction locations."
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront."
  type        = string
  default     = null # Make required if cloudfront_aliases is set
}

variable "waf_acl_arn" {
  description = "WAF ACL ARN for CloudFront."
  type        = string
  default     = null
}


# Example outputs (optional, could mirror pattern outputs)
output "website_url" {
  description = "URL of the deployed website (first CloudFront alias)"
  value       = length(module.static_website.cloudfront_aliases) > 0 ? "https://${module.static_website.cloudfront_aliases[0]}" : module.static_website.cloudfront_distribution_domain_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = module.static_website.s3_bucket_id
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.static_website.cloudfront_distribution_id
} 