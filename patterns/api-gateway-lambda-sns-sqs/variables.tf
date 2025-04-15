/**
 * # API Gateway with Lambda, SNS, and SQS Pattern - Variables
 *
 * This file contains all the variables used in the API Gateway with Lambda, SNS, and SQS pattern.
 */

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# API Gateway Variables
variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "api-gateway-lambda-sns-sqs"
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API Gateway with Lambda, SNS, and SQS integration"
}

variable "endpoint_types" {
  description = "A list of endpoint types for the API Gateway (EDGE, REGIONAL, or PRIVATE)"
  type        = list(string)
  default     = ["REGIONAL"]
}

variable "stage_name" {
  description = "Name of the API Gateway deployment stage"
  type        = string
  default     = "dev"
}

variable "create_custom_domain" {
  description = "Whether to create a custom domain for the API Gateway"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Custom domain name for the API Gateway"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the custom domain"
  type        = string
  default     = null
}

variable "base_path" {
  description = "Base path for the custom domain mapping"
  type        = string
  default     = null
}

variable "cloudwatch_role_arn" {
  description = "ARN of the IAM role for CloudWatch"
  type        = string
  default     = null
}

variable "waf_acl_arn" {
  description = "ARN of the WAF ACL to associate with the API Gateway"
  type        = string
  default     = null
}

# API Resource and Method configuration
variable "api_resource_path" {
  description = "Path part for the API resource"
  type        = string
  default     = "messages"
}

variable "api_authorization_type" {
  description = "Authorization type for API Gateway methods"
  type        = string
  default     = "NONE"
}

variable "api_authorizer_id" {
  description = "ID of the API Gateway authorizer"
  type        = string
  default     = null
}

variable "require_api_key" {
  description = "Whether to require an API key for API Gateway methods"
  type        = bool
  default     = false
}

variable "api_request_parameters" {
  description = "Request parameters for the API method"
  type        = map(bool)
  default     = {}
}

# Usage Plan Configuration
variable "usage_plan_throttle_burst" {
  description = "Usage plan throttle burst limit"
  type        = number
  default     = 5
}

variable "usage_plan_throttle_rate" {
  description = "Usage plan throttle rate limit"
  type        = number
  default     = 10
}

variable "usage_plan_quota_limit" {
  description = "Usage plan quota limit"
  type        = number
  default     = 1000
}

variable "usage_plan_quota_period" {
  description = "Usage plan quota period"
  type        = string
  default     = "MONTH"
}

# CORS Configuration
variable "enable_cors" {
  description = "Whether to enable CORS for API Gateway endpoints"
  type        = bool
  default     = false
}

variable "cors_allow_origin" {
  description = "Allowed origin for CORS"
  type        = string
  default     = "*"
}

variable "cors_allow_methods" {
  description = "Allowed methods for CORS"
  type        = string
  default     = "OPTIONS,POST"
}

variable "cors_allow_headers" {
  description = "Allowed headers for CORS"
  type        = string
  default     = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
}

# SNS Topic Variables
variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "message-processor-topic"
}

variable "sns_kms_key_arn" {
  description = "ARN of the KMS key for SNS topic encryption"
  type        = string
  default     = null
}

variable "sns_dlq_arn" {
  description = "ARN of the dead letter queue for SNS topic"
  type        = string
  default     = null
}

variable "sns_subscription_filter_policy" {
  description = "Filter policy for SNS subscription"
  type        = map(any)
  default     = null
}

# SQS Queue Variables
variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "message-processor-queue"
}

variable "sqs_visibility_timeout" {
  description = "Visibility timeout in seconds for the SQS queue"
  type        = number
  default     = 60
}

variable "sqs_message_retention" {
  description = "Message retention period in seconds for the SQS queue"
  type        = number
  default     = 86400 # 1 day
}

variable "sqs_max_message_size" {
  description = "Maximum message size in bytes for the SQS queue"
  type        = number
  default     = 262144 # 256 KB
}

variable "sqs_delay_seconds" {
  description = "Delay in seconds for messages in the SQS queue"
  type        = number
  default     = 0
}

variable "sqs_use_managed_sse" {
  description = "Whether to use SQS managed server-side encryption"
  type        = bool
  default     = true
}

variable "sqs_kms_key_arn" {
  description = "ARN of the KMS key for SQS queue encryption"
  type        = string
  default     = null
}

variable "sqs_dlq_arn" {
  description = "ARN of the dead letter queue for SQS queue"
  type        = string
  default     = null
}

variable "sqs_max_receive_count" {
  description = "Maximum number of times a message can be received before being sent to the DLQ"
  type        = number
  default     = 5
}

variable "create_sqs_dlq" {
  description = "Whether to create a dead letter queue for the SQS queue"
  type        = bool
  default     = true
}

variable "sqs_dlq_message_retention" {
  description = "Message retention period in seconds for the SQS DLQ"
  type        = number
  default     = 1209600 # 14 days
}

# Lambda Function Variables
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "api-message-handler"
}

variable "lambda_description" {
  description = "Description of the Lambda function"
  type        = string
  default     = "Processes API requests and publishes to SNS"
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

variable "lambda_timeout" {
  description = "Timeout in seconds for the Lambda function"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Memory size in MB for the Lambda function"
  type        = number
  default     = 128
}

variable "lambda_filename" {
  description = "Path to the Lambda deployment package"
  type        = string
  default     = null
}

variable "lambda_source_code_hash" {
  description = "Base64-encoded SHA256 hash of the Lambda deployment package"
  type        = string
  default     = null
}

variable "lambda_s3_bucket" {
  description = "S3 bucket containing the Lambda deployment package"
  type        = string
  default     = null
}

variable "lambda_s3_key" {
  description = "S3 key of the Lambda deployment package"
  type        = string
  default     = null
}

variable "lambda_environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "lambda_subnet_ids" {
  description = "List of subnet IDs for the Lambda function VPC configuration"
  type        = list(string)
  default     = null
}

variable "lambda_security_group_ids" {
  description = "List of security group IDs for the Lambda function VPC configuration"
  type        = list(string)
  default     = null
}

variable "lambda_dlq_arn" {
  description = "ARN of the dead letter queue for Lambda function"
  type        = string
  default     = null
}

variable "lambda_tracing_mode" {
  description = "X-Ray tracing mode for Lambda function (PassThrough or Active)"
  type        = string
  default     = null
}

variable "lambda_process_sqs_messages" {
  description = "Whether the main Lambda function should process SQS messages directly"
  type        = bool
  default     = false
}

variable "lambda_sqs_batch_size" {
  description = "Batch size for Lambda SQS event source mapping"
  type        = number
  default     = 10
}

# SQS Processor Lambda Variables
variable "create_separate_sqs_processor" {
  description = "Whether to create a separate Lambda function for processing SQS messages"
  type        = bool
  default     = true
}

variable "sqs_processor_function_name" {
  description = "Name of the SQS processor Lambda function"
  type        = string
  default     = "sqs-message-processor"
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

variable "sqs_processor_timeout" {
  description = "Timeout in seconds for the SQS processor Lambda function"
  type        = number
  default     = 30
}

variable "sqs_processor_memory_size" {
  description = "Memory size in MB for the SQS processor Lambda function"
  type        = number
  default     = 256
}

variable "sqs_processor_filename" {
  description = "Path to the SQS processor Lambda deployment package"
  type        = string
  default     = null
}

variable "sqs_processor_source_code_hash" {
  description = "Base64-encoded SHA256 hash of the SQS processor Lambda deployment package"
  type        = string
  default     = null
}

variable "sqs_processor_s3_bucket" {
  description = "S3 bucket containing the SQS processor Lambda deployment package"
  type        = string
  default     = null
}

variable "sqs_processor_s3_key" {
  description = "S3 key of the SQS processor Lambda deployment package"
  type        = string
  default     = null
}

variable "sqs_processor_environment_variables" {
  description = "Environment variables for the SQS processor Lambda function"
  type        = map(string)
  default     = {}
}

variable "sqs_processor_subnet_ids" {
  description = "List of subnet IDs for the SQS processor Lambda function VPC configuration"
  type        = list(string)
  default     = null
}

variable "sqs_processor_security_group_ids" {
  description = "List of security group IDs for the SQS processor Lambda function VPC configuration"
  type        = list(string)
  default     = null
}

variable "sqs_processor_dlq_arn" {
  description = "ARN of the dead letter queue for SQS processor Lambda function"
  type        = string
  default     = null
}

variable "sqs_processor_tracing_mode" {
  description = "X-Ray tracing mode for SQS processor Lambda function (PassThrough or Active)"
  type        = string
  default     = null
}

variable "sqs_processor_batch_size" {
  description = "Batch size for SQS processor Lambda event source mapping"
  type        = number
  default     = 10
} 