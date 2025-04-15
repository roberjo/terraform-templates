/**
 * # Route53 hosted zone with WAF ACL security and cloudfront distribution and s3 static content with kms key encryption at rest Pattern - Outputs
 *
 * This file contains all the outputs for the Route53 with WAF, CloudFront, and S3 pattern.
 */

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.content.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.content.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.content.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.content.bucket_regional_domain_name
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = var.create_kms_key ? aws_kms_key.s3_key[0].id : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = var.create_kms_key ? aws_kms_key.s3_key[0].arn : null
}

output "kms_key_alias" {
  description = "Alias of the KMS key"
  value       = var.create_kms_key ? aws_kms_alias.s3_key_alias[0].name : null
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.arn
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "Route53 zone ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "cloudfront_origin_access_control_id" {
  description = "ID of the CloudFront origin access control"
  value       = aws_cloudfront_origin_access_control.this.id
}

output "route53_zone_id" {
  description = "ID of the Route53 zone"
  value       = var.create_route53_zone ? aws_route53_zone.this[0].zone_id : var.route53_zone_id
}

output "route53_zone_name_servers" {
  description = "Name servers of the Route53 zone"
  value       = var.create_route53_zone ? aws_route53_zone.this[0].name_servers : null
}

output "route53_a_records" {
  description = "A records created in Route53"
  value       = length(var.cloudfront_aliases) > 0 ? aws_route53_record.a[*].fqdn : null
}

output "route53_aaaa_records" {
  description = "AAAA records created in Route53"
  value       = var.cloudfront_enable_ipv6 && length(var.cloudfront_aliases) > 0 ? aws_route53_record.aaaa[*].fqdn : null
} 