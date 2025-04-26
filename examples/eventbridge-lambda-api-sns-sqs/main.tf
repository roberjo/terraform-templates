provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

module "event_processor" {
  source = "../../patterns/eventbridge-lambda-api-sns-sqs"

  # Pass variables from terraform.tfvars
  aws_region                        = var.aws_region
  name_prefix                       = var.name_prefix
  default_tags                      = var.default_tags
  tags                              = var.tags
  scheduler_name                    = var.scheduler_name
  scheduler_description             = var.scheduler_description
  schedule_expression               = var.schedule_expression
  scheduler_state                   = var.scheduler_state
  api_endpoint                      = var.api_endpoint
  api_key                           = var.api_key
  batch_size                        = var.batch_size
  lambda_function_name              = var.lambda_function_name
  lambda_description                = var.lambda_description
  lambda_handler                    = var.lambda_handler
  lambda_runtime                    = var.lambda_runtime
  lambda_memory_size                = var.lambda_memory_size
  lambda_timeout                    = var.lambda_timeout
  lambda_source_path                = var.lambda_source_path
  lambda_layers                     = var.lambda_layers
  lambda_environment_variables      = var.lambda_environment_variables
  lambda_reserved_concurrency       = var.lambda_reserved_concurrency
  lambda_publish_version            = var.lambda_publish_version
  sns_topic_name                    = var.sns_topic_name
  sns_kms_key_arn                   = var.sns_kms_key_arn
  sns_fifo_topic                    = var.sns_fifo_topic
  sns_dlq_arn                       = var.sns_dlq_arn
  create_sns_dlq                    = var.create_sns_dlq
  sns_raw_message_delivery          = var.sns_raw_message_delivery
  sns_filter_policy                 = var.sns_filter_policy
  sns_filter_policy_scope           = var.sns_filter_policy_scope
  sqs_queue_name                    = var.sqs_queue_name
  sqs_visibility_timeout            = var.sqs_visibility_timeout
  sqs_message_retention_seconds     = var.sqs_message_retention_seconds
  sqs_max_message_size              = var.sqs_max_message_size
  sqs_delay_seconds                 = var.sqs_delay_seconds
  sqs_receive_wait_time_seconds     = var.sqs_receive_wait_time_seconds
  sqs_kms_key_arn                   = var.sqs_kms_key_arn
  create_sqs_dlq                    = var.create_sqs_dlq
  sqs_max_receive_count             = var.sqs_max_receive_count
  create_separate_sqs_processor     = var.create_separate_sqs_processor
  sqs_processor_function_name       = var.sqs_processor_function_name
  sqs_processor_description         = var.sqs_processor_description
  sqs_processor_handler             = var.sqs_processor_handler
  sqs_processor_runtime             = var.sqs_processor_runtime
  sqs_processor_memory_size         = var.sqs_processor_memory_size
  sqs_processor_timeout             = var.sqs_processor_timeout
  sqs_processor_source_path         = var.sqs_processor_source_path
  sqs_processor_layers              = var.sqs_processor_layers
  sqs_processor_environment_variables = var.sqs_processor_environment_variables
  sqs_processor_reserved_concurrency = var.sqs_processor_reserved_concurrency
  sqs_processor_publish_version     = var.sqs_processor_publish_version
  sqs_processor_batch_size          = var.sqs_processor_batch_size
  sqs_processor_max_batching_window = var.sqs_processor_max_batching_window
  sqs_processor_enabled             = var.sqs_processor_enabled
}

# Define necessary variables for the example
variable "aws_region" {
  description = "AWS region for the example deployment."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names in the example."
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

variable "scheduler_name" {
  description = "Name of the EventBridge scheduler."
  type        = string
  default     = null
}

variable "scheduler_description" {
  description = "Description of the EventBridge scheduler."
  type        = string
  default     = null
}

variable "schedule_expression" {
  description = "Schedule expression for the EventBridge scheduler."
  type        = string
}

variable "scheduler_state" {
  description = "State of the EventBridge scheduler (ENABLED or DISABLED)."
  type        = string
  default     = "ENABLED"
}

variable "api_endpoint" {
  description = "API endpoint URL to retrieve data from."
  type        = string
}

variable "api_key" {
  description = "API key for authentication."
  type        = string
  sensitive   = true
  default     = null
}

variable "batch_size" {
  description = "Number of items to process in each batch."
  type        = number
  default     = null
}

variable "lambda_function_name" {
  description = "Name of the primary Lambda function."
  type        = string
  default     = null
}

variable "lambda_description" {
  description = "Description of the primary Lambda function."
  type        = string
  default     = null
}

variable "lambda_handler" {
  description = "Handler for the primary Lambda function."
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for the primary Lambda function."
  type        = string
}

variable "lambda_memory_size" {
  description = "Memory size for the primary Lambda function."
  type        = number
  default     = null
}

variable "lambda_timeout" {
  description = "Timeout for the primary Lambda function."
  type        = number
  default     = null
}

variable "lambda_source_path" {
  description = "Path to the primary Lambda function source code."
  type        = string
}

variable "lambda_layers" {
  description = "List of Lambda layer ARNs for the primary function."
  type        = list(string)
  default     = []
}

variable "lambda_environment_variables" {
  description = "Environment variables for the primary Lambda function."
  type        = map(string)
  default     = {}
}

variable "lambda_reserved_concurrency" {
  description = "Reserved concurrency for the primary Lambda function."
  type        = number
  default     = null
}

variable "lambda_publish_version" {
  description = "Whether to publish a new version for the primary Lambda function."
  type        = bool
  default     = null
}

variable "sns_topic_name" {
  description = "Name of the SNS topic."
  type        = string
  default     = null
}

variable "sns_kms_key_arn" {
  description = "ARN of the KMS key for SNS topic encryption."
  type        = string
  default     = null
}

variable "sns_fifo_topic" {
  description = "Whether the SNS topic is a FIFO topic."
  type        = bool
  default     = null
}

variable "sns_dlq_arn" {
  description = "ARN of an existing SQS queue for the SNS DLQ."
  type        = string
  default     = null
}

variable "create_sns_dlq" {
  description = "Whether to create a DLQ for the SNS topic."
  type        = bool
  default     = null
}

variable "sns_raw_message_delivery" {
  description = "Enable raw message delivery for SNS to SQS."
  type        = bool
  default     = null
}

variable "sns_filter_policy" {
  description = "JSON filter policy for the SNS subscription."
  type        = string
  default     = null
}

variable "sns_filter_policy_scope" {
  description = "Scope of the SNS filter policy."
  type        = string
  default     = null
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue."
  type        = string
  default     = null
}

variable "sqs_visibility_timeout" {
  description = "Visibility timeout for the SQS queue."
  type        = number
  default     = null
}

variable "sqs_message_retention_seconds" {
  description = "Message retention period for the SQS queue."
  type        = number
  default     = null
}

variable "sqs_max_message_size" {
  description = "Maximum message size for the SQS queue."
  type        = number
  default     = null
}

variable "sqs_delay_seconds" {
  description = "Delay for messages in the SQS queue."
  type        = number
  default     = null
}

variable "sqs_receive_wait_time_seconds" {
  description = "Wait time for polling messages from the SQS queue."
  type        = number
  default     = null
}

variable "sqs_kms_key_arn" {
  description = "ARN of the KMS key for SQS queue encryption."
  type        = string
  default     = null
}

variable "create_sqs_dlq" {
  description = "Whether to create a DLQ for the SQS queue."
  type        = bool
  default     = null
}

variable "sqs_max_receive_count" {
  description = "Maximum receive count for the SQS DLQ."
  type        = number
  default     = null
}

variable "create_separate_sqs_processor" {
  description = "Whether to create a separate Lambda function to process SQS messages."
  type        = bool
  default     = null
}

variable "sqs_processor_function_name" {
  description = "Name of the SQS processor Lambda function."
  type        = string
  default     = null
}

variable "sqs_processor_description" {
  description = "Description of the SQS processor Lambda function."
  type        = string
  default     = null
}

variable "sqs_processor_handler" {
  description = "Handler for the SQS processor Lambda function."
  type        = string
  default     = null
}

variable "sqs_processor_runtime" {
  description = "Runtime for the SQS processor Lambda function."
  type        = string
  default     = null
}

variable "sqs_processor_memory_size" {
  description = "Memory size for the SQS processor Lambda function."
  type        = number
  default     = null
}

variable "sqs_processor_timeout" {
  description = "Timeout for the SQS processor Lambda function."
  type        = number
  default     = null
}

variable "sqs_processor_source_path" {
  description = "Path to the SQS processor Lambda function source code."
  type        = string
  default     = null
}

variable "sqs_processor_layers" {
  description = "List of Lambda layer ARNs for the SQS processor function."
  type        = list(string)
  default     = []
}

variable "sqs_processor_environment_variables" {
  description = "Environment variables for the SQS processor Lambda function."
  type        = map(string)
  default     = {}
}

variable "sqs_processor_reserved_concurrency" {
  description = "Reserved concurrency for the SQS processor Lambda function."
  type        = number
  default     = null
}

variable "sqs_processor_publish_version" {
  description = "Whether to publish a new version for the SQS processor Lambda function."
  type        = bool
  default     = null
}

variable "sqs_processor_batch_size" {
  description = "Batch size for the SQS processor Lambda function."
  type        = number
  default     = null
}

variable "sqs_processor_max_batching_window" {
  description = "Maximum batching window for the SQS processor Lambda function."
  type        = number
  default     = null
}

variable "sqs_processor_enabled" {
  description = "Whether the SQS processor Lambda function is enabled."
  type        = bool
  default     = null
}

# Example Outputs
output "lambda_function_arn" {
  description = "ARN of the primary Lambda function created"
  value       = module.event_processor.lambda_function_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic created"
  value       = module.event_processor.sns_topic_arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue created"
  value       = module.event_processor.sqs_queue_url
}

output "scheduler_arn" {
  description = "ARN of the EventBridge Scheduler created"
  value       = module.event_processor.scheduler_arn
} 