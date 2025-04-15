/**
 * API Gateway Module Outputs
 */

output "rest_api_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.this.id
}

output "rest_api_name" {
  description = "Name of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.this.name
}

output "rest_api_arn" {
  description = "ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.this.arn
}

output "rest_api_execution_arn" {
  description = "Execution ARN of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "root_resource_id" {
  description = "Resource ID of the API Gateway REST API root resource"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = aws_api_gateway_deployment.this.id
}

output "stage_id" {
  description = "ID of the API Gateway stage"
  value       = aws_api_gateway_stage.this.id
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.this.stage_name
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.this.arn
}

output "invoke_url" {
  description = "Invoke URL of the API Gateway stage"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "domain_name" {
  description = "Custom domain name of the API Gateway"
  value       = var.create_custom_domain ? aws_api_gateway_domain_name.this[0].domain_name : null
}

output "domain_regional_domain_name" {
  description = "Regional domain name of the API Gateway custom domain"
  value       = var.create_custom_domain ? aws_api_gateway_domain_name.this[0].regional_domain_name : null
} 