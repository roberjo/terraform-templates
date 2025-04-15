/**
 * # EventBridge Lambda API SNS SQS Pattern Variables
 *
 * Variable definitions for the EventBridge Lambda API SNS SQS pattern.
 */

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# EventBridge Scheduler Variables
variable "scheduler_name" {
  description = "Name of the EventBridge scheduler"
  type        = string
  default     = ""
}

variable "scheduler_description" {
  description = "Description of the EventBridge scheduler"
  type        = string
  default     = "Triggers Lambda function to process API data"
}

variable "schedule_expression" {
  description = "Schedule expression for the EventBridge scheduler (cron or rate expression)"
  type        = string
  default     = "rate(1 hour)"
}

variable "scheduler_state" {
  description = "State of the EventBridge scheduler (ENABLED or DISABLED)"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.scheduler_state)
    error_message = "Scheduler state must be either ENABLED or DISABLED."
  }
}

# API Variables
variable "api_endpoint" {
  description = "API endpoint URL to retrieve data from"
  type        = string
}

variable "api_key" {
  description = "API key for authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "batch_size" {
  description = "Number of items to process in each batch"
  type        = number
  default     = 10
}

# Lambda Function Variables
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = ""
}

variable "lambda_description" {
  description = "Description of the Lambda function"
  type        = string
  default     = "Processes data from API and publishes to SNS topic"
}

variable "lambda_handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 30
}

variable "lambda_source_path" {
  description = "Path to the Lambda function source code"
  type        = string
}

variable "lambda_layers" {
  description = "List of Lambda layer ARNs to attach to the function"
  type        = list(string)
  default     = []
}

variable "lambda_environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "lambda_reserved_concurrency" {
  description = "Reserved concurrency for the Lambda function"
  type        = number
  default     = -1
}

variable "lambda_publish_version" {
  description = "Whether to publish a new Lambda function version"
  type        = bool
  default     = false
}

# SNS Topic Variables
variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = ""
}

variable "sns_kms_key_arn" {
  description = "ARN of the KMS key for SNS topic encryption"
  type        = string
  default     = ""
}

variable "sns_fifo_topic" {
  description = "Whether the SNS topic is a FIFO topic"
  type        = bool
  default     = false
}

variable "sns_dlq_arn" {
  description = "ARN of an existing SQS queue to use as a dead-letter queue for the SNS topic"
  type        = string
  default     = ""
}

variable "create_sns_dlq" {
  description = "Whether to create a dead-letter queue for the SNS topic"
  type        = bool
  default     = false
}

variable "sns_raw_message_delivery" {
  description = "Whether to enable raw message delivery for the SNS to SQS subscription"
  type        = bool
  default     = false
}

variable "sns_filter_policy" {
  description = "JSON string filter policy for the SNS subscription"
  type        = string
  default     = ""
}

variable "sns_filter_policy_scope" {
  description = "Scope of the filter policy (MessageAttributes or MessageBody)"
  type        = string
  default     = "MessageAttributes"
  validation {
    condition     = contains(["MessageAttributes", "MessageBody"], var.sns_filter_policy_scope)
    error_message = "Filter policy scope must be either MessageAttributes or MessageBody."
  }
}

# SQS Queue Variables
variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = ""
}

variable "sqs_visibility_timeout" {
  description = "Visibility timeout for the SQS queue in seconds"
  type        = number
  default     = 30
}

variable "sqs_message_retention_seconds" {
  description = "Message retention period for the SQS queue in seconds"
  type        = number
  default     = 345600 # 4 days
}

variable "sqs_max_message_size" {
  description = "Maximum message size for the SQS queue in bytes"
  type        = number
  default     = 262144 # 256 KB
}

variable "sqs_delay_seconds" {
  description = "Delay for messages in the SQS queue in seconds"
  type        = number
  default     = 0
}

variable "sqs_receive_wait_time_seconds" {
  description = "Wait time for polling messages from the SQS queue in seconds"
  type        = number
  default     = 0
}

variable "sqs_kms_key_arn" {
  description = "ARN of the KMS key for SQS queue encryption"
  type        = string
  default     = ""
}

variable "create_sqs_dlq" {
  description = "Whether to create a dead-letter queue for the SQS queue"
  type        = bool
  default     = true
}

variable "sqs_max_receive_count" {
  description = "Maximum number of times a message can be received before being sent to the DLQ"
  type        = number
  default     = 5
}

# SQS Processor Lambda Variables
variable "create_separate_sqs_processor" {
  description = "Whether to create a separate Lambda function for processing SQS messages"
  type        = bool
  default     = false
}

variable "sqs_processor_function_name" {
  description = "Name of the SQS processor Lambda function"
  type        = string
  default     = ""
}

variable "sqs_processor_description" {
  description = "Description of the SQS processor Lambda function"
  type        = string
  default     = "Processes messages from SQS queue"
}

variable "sqs_processor_handler" {
  description = "Handler for the SQS processor Lambda function"
  type        = string
  default     = "index.handler"
}

variable "sqs_processor_runtime" {
  description = "Runtime for the SQS processor Lambda function"
  type        = string
  default     = "nodejs18.x"
}

variable "sqs_processor_memory_size" {
  description = "Memory size for the SQS processor Lambda function in MB"
  type        = number
  default     = 128
}

variable "sqs_processor_timeout" {
  description = "Timeout for the SQS processor Lambda function in seconds"
  type        = number
  default     = 30
}

variable "sqs_processor_source_path" {
  description = "Path to the SQS processor Lambda function source code"
  type        = string
  default     = ""
}

variable "sqs_processor_layers" {
  description = "List of Lambda layer ARNs to attach to the SQS processor function"
  type        = list(string)
  default     = []
}

variable "sqs_processor_environment_variables" {
  description = "Environment variables for the SQS processor Lambda function"
  type        = map(string)
  default     = {}
}

variable "sqs_processor_reserved_concurrency" {
  description = "Reserved concurrency for the SQS processor Lambda function"
  type        = number
  default     = -1
}

variable "sqs_processor_publish_version" {
  description = "Whether to publish a new SQS processor Lambda function version"
  type        = bool
  default     = false
}

variable "sqs_processor_batch_size" {
  description = "Number of records to process in each batch for the SQS processor"
  type        = number
  default     = 10
}

variable "sqs_processor_max_batching_window" {
  description = "Maximum batching window in seconds for the SQS processor"
  type        = number
  default     = 0
}

variable "sqs_processor_enabled" {
  description = "Whether the SQS event source mapping is enabled"
  type        = bool
  default     = true
} 