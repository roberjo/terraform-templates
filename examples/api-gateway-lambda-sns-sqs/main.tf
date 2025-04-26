provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

module "api_processor" {
  source = "../../patterns/api-gateway-lambda-sns-sqs"

  # Pass variables from terraform.tfvars
  aws_region                          = var.aws_region
  default_tags                        = var.default_tags
  tags                                = var.tags
  api_name                            = var.api_name
  api_description                     = var.api_description
  endpoint_types                      = var.endpoint_types
  stage_name                          = var.stage_name
  create_custom_domain                = var.create_custom_domain
  domain_name                         = var.domain_name
  certificate_arn                     = var.certificate_arn
  base_path                           = var.base_path
  cloudwatch_role_arn                 = var.cloudwatch_role_arn
  waf_acl_arn                         = var.waf_acl_arn
  api_resource_path                   = var.api_resource_path
  api_authorization_type              = var.api_authorization_type
  api_authorizer_id                   = var.api_authorizer_id
  require_api_key                     = var.require_api_key
  api_request_parameters              = var.api_request_parameters
  usage_plan_throttle_burst           = var.usage_plan_throttle_burst
  usage_plan_throttle_rate            = var.usage_plan_throttle_rate
  usage_plan_quota_limit              = var.usage_plan_quota_limit
  usage_plan_quota_period             = var.usage_plan_quota_period
  enable_cors                         = var.enable_cors
  cors_allow_origin                   = var.cors_allow_origin
  cors_allow_methods                  = var.cors_allow_methods
  cors_allow_headers                  = var.cors_allow_headers
  sns_topic_name                      = var.sns_topic_name
  sns_kms_key_arn                     = var.sns_kms_key_arn
  sns_dlq_arn                         = var.sns_dlq_arn
  sns_subscription_filter_policy      = var.sns_subscription_filter_policy
  sqs_queue_name                      = var.sqs_queue_name
  sqs_visibility_timeout              = var.sqs_visibility_timeout
  sqs_message_retention               = var.sqs_message_retention
  sqs_max_message_size                = var.sqs_max_message_size
  sqs_delay_seconds                   = var.sqs_delay_seconds
  sqs_use_managed_sse                 = var.sqs_use_managed_sse
  sqs_kms_key_arn                     = var.sqs_kms_key_arn
  sqs_dlq_arn                         = var.sqs_dlq_arn
  sqs_max_receive_count             = var.sqs_max_receive_count
  create_sqs_dlq                      = var.create_sqs_dlq
  sqs_dlq_message_retention           = var.sqs_dlq_message_retention
  lambda_function_name                = var.lambda_function_name
  lambda_description                  = var.lambda_description
  lambda_handler                      = var.lambda_handler
  lambda_runtime                      = var.lambda_runtime
  lambda_timeout                      = var.lambda_timeout
  lambda_memory_size                  = var.lambda_memory_size
  lambda_filename                     = var.lambda_filename
  lambda_source_code_hash             = var.lambda_source_code_hash
  lambda_s3_bucket                    = var.lambda_s3_bucket
  lambda_s3_key                       = var.lambda_s3_key
  lambda_environment_variables        = var.lambda_environment_variables
  lambda_subnet_ids                   = var.lambda_subnet_ids
  lambda_security_group_ids           = var.lambda_security_group_ids
  lambda_dlq_arn                      = var.lambda_dlq_arn
  lambda_tracing_mode                 = var.lambda_tracing_mode
  lambda_process_sqs_messages         = var.lambda_process_sqs_messages
  lambda_sqs_batch_size               = var.lambda_sqs_batch_size
  create_separate_sqs_processor     = var.create_separate_sqs_processor
  sqs_processor_function_name         = var.sqs_processor_function_name
  sqs_processor_description           = var.sqs_processor_description
  sqs_processor_handler               = var.sqs_processor_handler
  sqs_processor_runtime               = var.sqs_processor_runtime
  sqs_processor_timeout               = var.sqs_processor_timeout
  sqs_processor_memory_size           = var.sqs_processor_memory_size
  sqs_processor_filename              = var.sqs_processor_filename
  sqs_processor_source_code_hash      = var.sqs_processor_source_code_hash
  sqs_processor_s3_bucket             = var.sqs_processor_s3_bucket
  sqs_processor_s3_key                = var.sqs_processor_s3_key
  sqs_processor_environment_variables = var.sqs_processor_environment_variables
  sqs_processor_subnet_ids            = var.sqs_processor_subnet_ids
  sqs_processor_security_group_ids    = var.sqs_processor_security_group_ids
  sqs_processor_dlq_arn               = var.sqs_processor_dlq_arn
  sqs_processor_tracing_mode          = var.sqs_processor_tracing_mode
  sqs_processor_batch_size            = var.sqs_processor_batch_size
}

# Define necessary variables for the example
variable "aws_region" {
  description = "AWS region for the example deployment."
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

# --- API Gateway --- #
variable "api_name" {
  description = "API Gateway name."
  type        = string
}

variable "api_description" {
  description = "API Gateway description."
  type        = string
  default     = null
}

variable "endpoint_types" {
  description = "API Gateway endpoint types."
  type        = list(string)
}

variable "stage_name" {
  description = "API Gateway deployment stage name."
  type        = string
}

variable "create_custom_domain" {
  description = "Whether to create a custom domain for API Gateway."
  type        = bool
  default     = null
}

variable "domain_name" {
  description = "Custom domain name for API Gateway."
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the custom domain."
  type        = string
  default     = null
}

variable "base_path" {
  description = "Base path for the custom domain mapping."
  type        = string
  default     = null
}

variable "cloudwatch_role_arn" {
  description = "IAM role ARN for CloudWatch logging."
  type        = string
  default     = null
}

variable "waf_acl_arn" {
  description = "WAF ACL ARN for API Gateway."
  type        = string
  default     = null
}

variable "api_resource_path" {
  description = "Path part for the API resource."
  type        = string
}

variable "api_authorization_type" {
  description = "Authorization type for API methods."
  type        = string
  default     = null
}

variable "api_authorizer_id" {
  description = "ID of the API Gateway authorizer."
  type        = string
  default     = null
}

variable "require_api_key" {
  description = "Whether to require an API key."
  type        = bool
  default     = null
}

variable "api_request_parameters" {
  description = "API method request parameters."
  type        = map(bool)
  default     = null
}

variable "usage_plan_throttle_burst" {
  description = "Usage plan throttle burst limit."
  type        = number
  default     = null
}

variable "usage_plan_throttle_rate" {
  description = "Usage plan throttle rate limit."
  type        = number
  default     = null
}

variable "usage_plan_quota_limit" {
  description = "Usage plan quota limit."
  type        = number
  default     = null
}

variable "usage_plan_quota_period" {
  description = "Usage plan quota period."
  type        = string
  default     = null
}

variable "enable_cors" {
  description = "Enable CORS for API Gateway."
  type        = bool
  default     = null
}

variable "cors_allow_origin" {
  description = "CORS allowed origin."
  type        = string
  default     = null
}

variable "cors_allow_methods" {
  description = "CORS allowed methods."
  type        = string
  default     = null
}

variable "cors_allow_headers" {
  description = "CORS allowed headers."
  type        = string
  default     = null
}

# --- SNS --- #
variable "sns_topic_name" {
  description = "SNS topic name."
  type        = string
}

variable "sns_kms_key_arn" {
  description = "KMS key ARN for SNS encryption."
  type        = string
  default     = null
}

variable "sns_dlq_arn" {
  description = "ARN of the DLQ for the SNS topic."
  type        = string
  default     = null
}

variable "sns_subscription_filter_policy" {
  description = "SNS subscription filter policy."
  type        = map(any)
  default     = null
}

# --- SQS --- #
variable "sqs_queue_name" {
  description = "SQS queue name."
  type        = string
}

variable "sqs_visibility_timeout" {
  description = "SQS visibility timeout."
  type        = number
}

variable "sqs_message_retention" {
  description = "SQS message retention period."
  type        = number
  default     = null
}

variable "sqs_max_message_size" {
  description = "SQS max message size."
  type        = number
  default     = null
}

variable "sqs_delay_seconds" {
  description = "SQS message delay."
  type        = number
  default     = null
}

variable "sqs_use_managed_sse" {
  description = "Use SQS managed SSE."
  type        = bool
  default     = null
}

variable "sqs_kms_key_arn" {
  description = "KMS key ARN for SQS encryption."
  type        = string
  default     = null
}

variable "sqs_dlq_arn" {
  description = "ARN of the DLQ for the SQS queue."
  type        = string
  default     = null
}

variable "sqs_max_receive_count" {
  description = "SQS max receive count for DLQ."
  type        = number
}

variable "create_sqs_dlq" {
  description = "Whether to create a DLQ for the SQS queue."
  type        = bool
}

variable "sqs_dlq_message_retention" {
  description = "SQS DLQ message retention period."
  type        = number
  default     = null
}

# --- Lambda (Primary - API Trigger) --- #
variable "lambda_function_name" {
  description = "Primary Lambda function name."
  type        = string
}

variable "lambda_description" {
  description = "Primary Lambda function description."
  type        = string
  default     = null
}

variable "lambda_handler" {
  description = "Primary Lambda function handler."
  type        = string
}

variable "lambda_runtime" {
  description = "Primary Lambda function runtime."
  type        = string
}

variable "lambda_timeout" {
  description = "Primary Lambda function timeout."
  type        = number
  default     = null
}

variable "lambda_memory_size" {
  description = "Primary Lambda function memory size."
  type        = number
  default     = null
}

variable "lambda_filename" {
  description = "Primary Lambda function deployment package filename."
  type        = string
  default     = null
}

variable "lambda_source_code_hash" {
  description = "Base64-encoded SHA256 hash of the primary Lambda deployment package."
  type        = string
  default     = null
}

variable "lambda_s3_bucket" {
  description = "S3 bucket containing the primary Lambda deployment package."
  type        = string
  default     = null
}

variable "lambda_s3_key" {
  description = "S3 key of the primary Lambda deployment package."
  type        = string
  default     = null
}

variable "lambda_environment_variables" {
  description = "Primary Lambda function environment variables."
  type        = map(string)
  default     = {}
}

variable "lambda_subnet_ids" {
  description = "Primary Lambda function subnet IDs for VPC configuration."
  type        = list(string)
  default     = null
}

variable "lambda_security_group_ids" {
  description = "Primary Lambda function security group IDs for VPC configuration."
  type        = list(string)
  default     = null
}

variable "lambda_dlq_arn" {
  description = "ARN of the DLQ for the primary Lambda function."
  type        = string
  default     = null
}

variable "lambda_tracing_mode" {
  description = "Primary Lambda function X-Ray tracing mode."
  type        = string
  default     = null
}

variable "lambda_process_sqs_messages" {
  description = "Whether the primary Lambda function also processes SQS messages."
  type        = bool
  default     = null
}

variable "lambda_sqs_batch_size" {
  description = "Batch size if the primary Lambda processes SQS messages."
  type        = number
  default     = null
}

# --- Lambda (SQS Processor) --- #
variable "create_separate_sqs_processor" {
  description = "Whether to create a separate SQS processor Lambda."
  type        = bool
}

variable "sqs_processor_function_name" {
  description = "SQS processor Lambda function name."
  type        = string
  default     = null
}

variable "sqs_processor_description" {
  description = "SQS processor Lambda function description."
  type        = string
  default     = null
}

variable "sqs_processor_handler" {
  description = "SQS processor Lambda function handler."
  type        = string
  default     = null
}

variable "sqs_processor_runtime" {
  description = "SQS processor Lambda function runtime."
  type        = string
  default     = null
}

variable "sqs_processor_timeout" {
  description = "SQS processor Lambda function timeout."
  type        = number
  default     = null
}

variable "sqs_processor_memory_size" {
  description = "SQS processor Lambda function memory size."
  type        = number
  default     = null
}

variable "sqs_processor_filename" {
  description = "SQS processor Lambda deployment package filename."
  type        = string
  default     = null
}

variable "sqs_processor_source_code_hash" {
  description = "Base64-encoded SHA256 hash of the SQS processor Lambda deployment package."
  type        = string
  default     = null
}

variable "sqs_processor_s3_bucket" {
  description = "S3 bucket containing the SQS processor Lambda deployment package."
  type        = string
  default     = null
}

variable "sqs_processor_s3_key" {
  description = "S3 key of the SQS processor Lambda deployment package."
  type        = string
  default     = null
}

variable "sqs_processor_environment_variables" {
  description = "SQS processor Lambda function environment variables."
  type        = map(string)
  default     = {}
}

variable "sqs_processor_subnet_ids" {
  description = "SQS processor Lambda function subnet IDs for VPC configuration."
  type        = list(string)
  default     = null
}

variable "sqs_processor_security_group_ids" {
  description = "SQS processor Lambda function security group IDs for VPC configuration."
  type        = list(string)
  default     = null
}

variable "sqs_processor_dlq_arn" {
  description = "ARN of the DLQ for the SQS processor Lambda function."
  type        = string
  default     = null
}

variable "sqs_processor_tracing_mode" {
  description = "SQS processor Lambda function X-Ray tracing mode."
  type        = string
  default     = null
}

variable "sqs_processor_batch_size" {
  description = "Batch size for the SQS processor Lambda."
  type        = number
  default     = null
}

# Example Outputs
output "api_gateway_invoke_url" {
  description = "Invoke URL for the API Gateway stage"
  value       = module.api_processor.api_gateway_invoke_url
}

output "api_gateway_custom_domain_url" {
  description = "URL for the custom domain if configured"
  value       = module.api_processor.api_gateway_custom_domain_url
}

output "lambda_function_arn" {
  description = "ARN of the primary Lambda function"
  value       = module.api_processor.lambda_function_arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.api_processor.sns_topic_arn
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = module.api_processor.sqs_queue_url
} 