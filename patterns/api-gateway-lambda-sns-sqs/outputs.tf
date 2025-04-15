/**
 * # API Gateway with Lambda, SNS, and SQS Pattern - Outputs
 *
 * This file defines all the outputs exposed by the API Gateway with Lambda, SNS, and SQS pattern.
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

output "api_endpoint_url" {
  description = "URL of the API endpoint"
  value       = "${module.api_gateway.invoke_url}${var.api_resource_path}"
}

# Lambda outputs
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = module.lambda.function_invoke_arn
}

output "lambda_function_url" {
  description = "Function URL of the Lambda function (if enabled)"
  value       = module.lambda.function_url
}

# SNS outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.this.name
}

# SQS outputs
output "sqs_queue_id" {
  description = "ID of the SQS queue"
  value       = aws_sqs_queue.this.id
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.this.url
}

# Dead Letter Queue outputs
output "dlq_id" {
  description = "ID of the Dead Letter Queue"
  value       = var.create_sqs_dlq ? aws_sqs_queue.dlq[0].id : var.sqs_dlq_arn
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = var.create_sqs_dlq ? aws_sqs_queue.dlq[0].arn : var.sqs_dlq_arn
}

output "dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = var.create_sqs_dlq ? aws_sqs_queue.dlq[0].url : null
}

# SQS Processor Lambda outputs
output "sqs_processor_function_name" {
  description = "Name of the SQS processor Lambda function"
  value       = var.create_separate_sqs_processor ? module.sqs_processor[0].function_name : null
}

output "sqs_processor_function_arn" {
  description = "ARN of the SQS processor Lambda function"
  value       = var.create_separate_sqs_processor ? module.sqs_processor[0].function_arn : null
} 