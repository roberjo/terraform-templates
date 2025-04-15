/**
 * Variables for the API Gateway with Microservices and DynamoDB Pattern
 */

# AWS general settings
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
  description = "Additional tags to apply to resources created by this pattern"
  type        = map(string)
  default     = {}
}

# API Gateway settings
variable "api_name" {
  description = "Name of the API Gateway REST API"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway REST API"
  type        = string
  default     = "API Gateway with Microservices and DynamoDB"
}

variable "endpoint_types" {
  description = "List of API Gateway endpoint types"
  type        = list(string)
  default     = ["REGIONAL"]
}

variable "create_custom_domain" {
  description = "Whether to create a custom domain for the API Gateway"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Custom domain name for the API Gateway (required if create_custom_domain is true)"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the custom domain (required if create_custom_domain is true)"
  type        = string
  default     = null
}

variable "base_path" {
  description = "Base path mapping for the custom domain"
  type        = string
  default     = ""
}

variable "stage_name" {
  description = "Name of the API Gateway deployment stage"
  type        = string
  default     = "prod"
}

variable "cloudwatch_role_arn" {
  description = "ARN of the IAM role for CloudWatch logs"
  type        = string
  default     = null
}

variable "waf_acl_arn" {
  description = "ARN of the WAF WebACL to associate with the API Gateway stage"
  type        = string
  default     = null
}

variable "api_authorization_type" {
  description = "Authorization type for API Gateway methods (NONE, AWS_IAM, CUSTOM, COGNITO_USER_POOLS)"
  type        = string
  default     = "NONE"
}

variable "api_authorizer_id" {
  description = "Authorizer ID for API Gateway methods when using CUSTOM or COGNITO_USER_POOLS authorization"
  type        = string
  default     = null
}

variable "request_parameters" {
  description = "Request parameters configuration for API Gateway methods"
  type        = map(bool)
  default     = {}
}

variable "enable_cors" {
  description = "Whether to enable CORS for the API Gateway"
  type        = bool
  default     = true
}

variable "cors_allow_origin" {
  description = "Allowed origin for CORS"
  type        = string
  default     = "*"
}

# DynamoDB settings
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_read_capacity" {
  description = "Read capacity units for the DynamoDB table (when using PROVISIONED billing mode)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "Write capacity units for the DynamoDB table (when using PROVISIONED billing mode)"
  type        = number
  default     = 5
}

variable "dynamodb_hash_key" {
  description = "Hash key (partition key) name for the DynamoDB table"
  type        = string
}

variable "dynamodb_hash_key_type" {
  description = "Hash key (partition key) type for the DynamoDB table (S, N, or B)"
  type        = string
  default     = "S"
}

variable "dynamodb_range_key" {
  description = "Range key (sort key) name for the DynamoDB table"
  type        = string
  default     = null
}

variable "dynamodb_range_key_type" {
  description = "Range key (sort key) type for the DynamoDB table (S, N, or B)"
  type        = string
  default     = "S"
}

variable "dynamodb_attributes" {
  description = "List of DynamoDB attributes in addition to the primary keys"
  type        = list(object({
    name = string
    type = string
  }))
  default     = []
}

variable "dynamodb_global_secondary_indexes" {
  description = "List of global secondary indexes for the DynamoDB table"
  type        = list(any)
  default     = []
}

variable "dynamodb_local_secondary_indexes" {
  description = "List of local secondary indexes for the DynamoDB table"
  type        = list(any)
  default     = []
}

variable "dynamodb_enable_encryption" {
  description = "Whether to enable server-side encryption for the DynamoDB table"
  type        = bool
  default     = true
}

variable "dynamodb_kms_key_arn" {
  description = "ARN of the KMS key for DynamoDB server-side encryption (null for AWS owned CMK)"
  type        = string
  default     = null
}

variable "dynamodb_enable_point_in_time_recovery" {
  description = "Whether to enable point-in-time recovery for the DynamoDB table"
  type        = bool
  default     = true
}

variable "dynamodb_ttl_attribute_name" {
  description = "Name of the TTL attribute for the DynamoDB table"
  type        = string
  default     = null
}

variable "dynamodb_stream_enabled" {
  description = "Whether to enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "dynamodb_stream_view_type" {
  description = "DynamoDB Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

# Lambda function settings
variable "lambda_functions" {
  description = "Map of Lambda functions to create for the microservices"
  type        = map(any)
  default     = {}
} 