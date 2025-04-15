/**
 * Outputs for the API Gateway with Microservices and DynamoDB Pattern
 */

# API Gateway outputs
output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = module.api_gateway.rest_api_id
}

output "api_gateway_name" {
  description = "Name of the API Gateway REST API"
  value       = module.api_gateway.rest_api_name
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway REST API"
  value       = module.api_gateway.rest_api_execution_arn
}

output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway stage"
  value       = module.api_gateway.invoke_url
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway deployment stage"
  value       = module.api_gateway.stage_name
}

output "api_gateway_domain_name" {
  description = "Custom domain name of the API Gateway (if enabled)"
  value       = module.api_gateway.domain_name
}

output "api_gateway_domain_regional_domain_name" {
  description = "Regional domain name of the API Gateway custom domain (if enabled)"
  value       = module.api_gateway.domain_regional_domain_name
}

# DynamoDB outputs
output "dynamodb_table_id" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "dynamodb_table_hash_key" {
  description = "Hash key (partition key) of the DynamoDB table"
  value       = aws_dynamodb_table.this.hash_key
}

output "dynamodb_table_range_key" {
  description = "Range key (sort key) of the DynamoDB table (if applicable)"
  value       = aws_dynamodb_table.this.range_key
}

output "dynamodb_stream_arn" {
  description = "ARN of the DynamoDB table stream (if enabled)"
  value       = aws_dynamodb_table.this.stream_arn
}

output "dynamodb_stream_label" {
  description = "Timestamp of the DynamoDB table stream (if enabled)"
  value       = aws_dynamodb_table.this.stream_label
}

# Lambda function outputs
output "lambda_function_names" {
  description = "Names of the Lambda functions created for microservices"
  value       = { for k, v in module.lambda_functions : k => v.function_name }
}

output "lambda_function_arns" {
  description = "ARNs of the Lambda functions created for microservices"
  value       = { for k, v in module.lambda_functions : k => v.function_arn }
}

output "lambda_function_invoke_arns" {
  description = "Invoke ARNs of the Lambda functions created for microservices"
  value       = { for k, v in module.lambda_functions : k => v.function_invoke_arn }
}

output "lambda_function_urls" {
  description = "URLs of the Lambda functions (if enabled)"
  value       = { for k, v in module.lambda_functions : k => v.function_url }
}

# API Gateway resource paths
output "api_gateway_resource_paths" {
  description = "Paths of the API Gateway resources created for microservices"
  value       = { for k, v in aws_api_gateway_resource.microservices : k => "/${k}" }
}

# Full API URLs for each microservice
output "microservice_urls" {
  description = "Full URLs for each microservice"
  value = { 
    for k, v in var.lambda_functions : k => var.create_custom_domain
      ? "https://${var.domain_name}${var.base_path == "" ? "" : "/${var.base_path}"}/${k}"
      : "${module.api_gateway.invoke_url}/${k}"
  }
} 