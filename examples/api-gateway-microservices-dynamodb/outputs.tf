/**
 * Outputs for the API Gateway with Microservices and DynamoDB Example
 */

output "api_gateway_invoke_url" {
  description = "Base URL for the API Gateway"
  value       = module.api_microservices.api_gateway_invoke_url
}

output "api_gateway_custom_domain_url" {
  description = "Custom domain URL for the API Gateway (if enabled)"
  value       = var.create_custom_domain ? "https://${var.domain_name}/${var.base_path}" : null
}

output "api_gateway_domain_regional_domain_name" {
  description = "Regional domain name of the API Gateway custom domain (if enabled)"
  value       = module.api_microservices.api_gateway_domain_regional_domain_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.api_microservices.dynamodb_table_id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.api_microservices.dynamodb_table_arn
}

output "lambda_function_names" {
  description = "Names of the Lambda functions created for microservices"
  value       = module.api_microservices.lambda_function_names
}

output "lambda_function_arns" {
  description = "ARNs of the Lambda functions created for microservices"
  value       = module.api_microservices.lambda_function_arns
}

output "microservice_urls" {
  description = "URLs for each microservice endpoint"
  value       = module.api_microservices.microservice_urls
}

output "acm_certificate_validation_instructions" {
  description = "Instructions for validating the ACM certificate (if created)"
  value       = var.create_custom_domain ? "Validate the ACM certificate by adding the appropriate DNS records. Then update Route53 with an A record alias pointing to the API Gateway domain: ${module.api_microservices.api_gateway_domain_regional_domain_name}" : null
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL (if created)"
  value       = var.create_waf_acl ? aws_wafv2_web_acl.api[0].arn : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key for DynamoDB encryption (if created)"
  value       = var.use_customer_managed_key ? aws_kms_key.dynamodb[0].arn : null
} 