/**
 * # EventBridge Lambda API SNS SQS Pattern Outputs
 *
 * Output values for the EventBridge Lambda API SNS SQS pattern.
 */

output "scheduler_arn" {
  description = "ARN of the EventBridge scheduler"
  value       = aws_scheduler_schedule.scheduler.arn
}

output "scheduler_id" {
  description = "ID of the EventBridge scheduler"
  value       = aws_scheduler_schedule.scheduler.id
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.lambda_function.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_function_role_arn" {
  description = "ARN of the Lambda function execution role"
  value       = aws_iam_role.lambda_role.arn
}

output "lambda_function_role_name" {
  description = "Name of the Lambda function execution role"
  value       = aws_iam_role.lambda_role.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.topic.arn
}

output "sns_topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.topic.name
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.queue.arn
}

output "sqs_queue_id" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.queue.id
}

output "sqs_queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.queue.name
}

output "sqs_dlq_arn" {
  description = "ARN of the SQS dead-letter queue"
  value       = var.create_sqs_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "sqs_dlq_id" {
  description = "URL of the SQS dead-letter queue"
  value       = var.create_sqs_dlq ? aws_sqs_queue.dlq[0].id : null
}

output "sqs_dlq_name" {
  description = "Name of the SQS dead-letter queue"
  value       = var.create_sqs_dlq ? aws_sqs_queue.dlq[0].name : null
}

output "sns_dlq_arn" {
  description = "ARN of the SNS dead-letter queue"
  value       = var.create_sns_dlq ? aws_sqs_queue.sns_dlq[0].arn : null
}

output "sns_dlq_id" {
  description = "URL of the SNS dead-letter queue"
  value       = var.create_sns_dlq ? aws_sqs_queue.sns_dlq[0].id : null
}

output "sns_dlq_name" {
  description = "Name of the SNS dead-letter queue"
  value       = var.create_sns_dlq ? aws_sqs_queue.sns_dlq[0].name : null
}

output "sqs_processor_lambda_arn" {
  description = "ARN of the SQS processor Lambda function"
  value       = var.create_separate_sqs_processor ? aws_lambda_function.sqs_processor[0].arn : null
}

output "sqs_processor_lambda_name" {
  description = "Name of the SQS processor Lambda function"
  value       = var.create_separate_sqs_processor ? aws_lambda_function.sqs_processor[0].function_name : null
}

output "sqs_processor_lambda_invoke_arn" {
  description = "Invoke ARN of the SQS processor Lambda function"
  value       = var.create_separate_sqs_processor ? aws_lambda_function.sqs_processor[0].invoke_arn : null
}

output "sqs_processor_lambda_role_arn" {
  description = "ARN of the SQS processor Lambda function execution role"
  value       = var.create_separate_sqs_processor ? aws_iam_role.sqs_processor_role[0].arn : null
}

output "sqs_processor_lambda_role_name" {
  description = "Name of the SQS processor Lambda function execution role"
  value       = var.create_separate_sqs_processor ? aws_iam_role.sqs_processor_role[0].name : null
}

output "sns_topic_subscription_arn" {
  description = "ARN of the SNS topic subscription to SQS"
  value       = aws_sns_topic_subscription.sns_to_sqs.arn
} 