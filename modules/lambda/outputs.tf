/**
 * Lambda Module Outputs
 */

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_qualified_arn" {
  description = "ARN identifying your Lambda function version"
  value       = aws_lambda_function.this.qualified_arn
}

output "function_invoke_arn" {
  description = "ARN to be used for invoking Lambda function from API Gateway"
  value       = aws_lambda_function.this.invoke_arn
}

output "function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.this.version
}

output "function_last_modified" {
  description = "Date Lambda function was last modified"
  value       = aws_lambda_function.this.last_modified
}

output "function_source_code_hash" {
  description = "Base64-encoded representation of the Lambda function source code"
  value       = aws_lambda_function.this.source_code_hash
}

output "role_arn" {
  description = "ARN of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "Name of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda.name
}

output "role_unique_id" {
  description = "Unique ID of the IAM role created for the Lambda function"
  value       = aws_iam_role.lambda.unique_id
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for the Lambda function"
  value       = aws_cloudwatch_log_group.lambda.arn
}

output "event_source_mapping_ids" {
  description = "List of event source mapping IDs"
  value       = [for mapping in aws_lambda_event_source_mapping.this : mapping.id]
}

output "event_source_mapping_arns" {
  description = "List of event source mapping ARNs"
  value       = [for mapping in aws_lambda_event_source_mapping.this : mapping.function_arn]
}

output "function_url" {
  description = "Lambda function URL (if enabled)"
  value       = var.create_function_url ? aws_lambda_function_url.this[0].function_url : null
} 