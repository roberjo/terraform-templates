/**
 * # API Gateway with Direct DynamoDB Integration Pattern - Outputs
 *
 * This file defines all the outputs exposed by the API Gateway with Direct DynamoDB Integration pattern.
 */

# API Gateway outputs
output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.rest_api_id
}

output "api_gateway_name" {
  description = "Name of the API Gateway"
  value       = module.api_gateway.rest_api_name
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = module.api_gateway.rest_api_execution_arn
}

output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = module.api_gateway.invoke_url
}

output "api_gateway_stage_name" {
  description = "Stage name of the API Gateway"
  value       = module.api_gateway.stage_name
}

# DynamoDB outputs
output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.this.id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "dynamodb_table_hash_key" {
  description = "Hash key of the DynamoDB table"
  value       = aws_dynamodb_table.this.hash_key
}

output "dynamodb_table_range_key" {
  description = "Range key of the DynamoDB table"
  value       = aws_dynamodb_table.this.range_key
}

# API Endpoints
output "api_endpoint_urls" {
  description = "Map of API endpoint URLs"
  value = {
    for endpoint_key, endpoint in var.api_endpoints :
    endpoint_key => "${module.api_gateway.invoke_url}${endpoint_key}"
  }
} 