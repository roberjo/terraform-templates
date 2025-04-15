/**
 * # API Gateway with Direct DynamoDB Integration Pattern - Outputs
 *
 * This file contains all the outputs for the API Gateway with Direct DynamoDB Integration pattern.
 */

# API Gateway outputs
output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway_dynamodb.api_gateway_id
}

output "api_gateway_name" {
  description = "Name of the API Gateway"
  value       = module.api_gateway_dynamodb.api_gateway_name
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = module.api_gateway_dynamodb.api_gateway_execution_arn
}

output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = module.api_gateway_dynamodb.api_gateway_invoke_url
}

output "api_gateway_stage_name" {
  description = "Stage name of the API Gateway"
  value       = module.api_gateway_dynamodb.api_gateway_stage_name
}

# DynamoDB outputs
output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = module.api_gateway_dynamodb.dynamodb_table_id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.api_gateway_dynamodb.dynamodb_table_arn
}

output "dynamodb_table_hash_key" {
  description = "Hash key of the DynamoDB table"
  value       = module.api_gateway_dynamodb.dynamodb_table_hash_key
}

output "dynamodb_table_range_key" {
  description = "Range key of the DynamoDB table"
  value       = module.api_gateway_dynamodb.dynamodb_table_range_key
}

# API Endpoints outputs
output "api_endpoint_urls" {
  description = "Map of API endpoint URLs"
  value       = module.api_gateway_dynamodb.api_endpoint_urls
} 