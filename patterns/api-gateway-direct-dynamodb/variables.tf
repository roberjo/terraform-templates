/**
 * # API Gateway with Direct DynamoDB Integration Pattern - Variables
 *
 * This file contains all the variables used in the API Gateway with Direct DynamoDB Integration pattern.
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
  default     = "api-gateway-dynamodb"
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API Gateway with direct DynamoDB integration"
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

# API Gateway Authorization
variable "api_authorization" {
  description = "Authorization type for API Gateway methods"
  type        = string
  default     = "NONE"
}

variable "require_api_key" {
  description = "Whether to require an API key for API Gateway methods"
  type        = bool
  default     = false
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

# DynamoDB Table Variables
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "api-gateway-items-table"
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.dynamodb_billing_mode)
    error_message = "Allowed values for dynamodb_billing_mode are \"PAY_PER_REQUEST\" or \"PROVISIONED\"."
  }
}

variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity (only used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity (only used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_hash_key" {
  description = "DynamoDB hash key"
  type        = string
  default     = "id"
}

variable "dynamodb_range_key" {
  description = "DynamoDB range key"
  type        = string
  default     = "sort_key"
}

variable "dynamodb_attributes" {
  description = "Additional DynamoDB attributes"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "dynamodb_global_secondary_indexes" {
  description = "DynamoDB global secondary indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    write_capacity     = number
    read_capacity      = number
    projection_type    = string
    non_key_attributes = list(string)
  }))
  default = []
}

variable "dynamodb_local_secondary_indexes" {
  description = "Local Secondary Indexes for the DynamoDB table"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  default = []
}

variable "dynamodb_enable_encryption" {
  description = "Whether to enable server-side encryption for the DynamoDB table"
  type        = bool
  default     = true
}

variable "dynamodb_kms_key_arn" {
  description = "ARN of the KMS key for server-side encryption (null for AWS owned key)"
  type        = string
  default     = null
}

variable "dynamodb_enable_point_in_time_recovery" {
  description = "Whether to enable point-in-time recovery for the DynamoDB table"
  type        = bool
  default     = false
}

variable "dynamodb_ttl_attribute_name" {
  description = "Name of the TTL attribute for the DynamoDB table"
  type        = string
  default     = null
}

# API Endpoints Configuration
variable "api_endpoints" {
  description = "Map of API endpoints to configure with DynamoDB integration"
  type = map(object({
    collection_operation = optional(string) # GET or POST
    item_operation       = optional(string) # GET, PUT, or DELETE
    query_type           = optional(string) # Scan or Query (for GET collection_operation)
    index_name           = optional(string) # GSI or LSI name to use for Query
    key_condition        = optional(string) # Key condition expression for Query
    expression_names     = optional(map(string))
    expression_values    = optional(map(string))
    filter_expression    = optional(string)
    scan_index_forward   = optional(bool)
    limit                = optional(number)
    auto_generate_id     = optional(bool, true) # Whether to auto-generate an ID for PutItem
    range_key_value      = optional(string)
    update_expression    = optional(string)
    condition_expression = optional(string)
  }))
  default = {}
}

variable "collection_name" {
  description = "Name of the collection resource in API Gateway"
  type        = string
  default     = "items"
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