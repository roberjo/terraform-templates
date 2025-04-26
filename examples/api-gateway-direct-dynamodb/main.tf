# Configure the AWS Provider
# Specifies the region where resources will be deployed and default tags.
provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources created by this configuration.
  default_tags {
    tags = var.default_tags
  }
}

# Instantiate the API Gateway to DynamoDB Pattern Module
# This module encapsulates the creation of API Gateway, DynamoDB table, and IAM roles.
module "api_dynamodb" {
  # Source points to the pattern directory relative to this example.
  source = "../../patterns/api-gateway-direct-dynamodb"

  # --- Pass variables defined in terraform.tfvars to the module --- #

  # General Configuration
  aws_region                          = var.aws_region
  default_tags                        = var.default_tags
  tags                                = var.tags

  # API Gateway Configuration
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
  api_authorization                   = var.api_authorization
  require_api_key                     = var.require_api_key
  collection_name                     = var.collection_name # e.g., "items", "users"
  enable_cors                         = var.enable_cors
  cors_allow_origin                   = var.cors_allow_origin

  # DynamoDB Configuration
  dynamodb_table_name                 = var.dynamodb_table_name
  dynamodb_billing_mode               = var.dynamodb_billing_mode
  dynamodb_read_capacity              = var.dynamodb_read_capacity
  dynamodb_write_capacity             = var.dynamodb_write_capacity
  dynamodb_hash_key                   = var.dynamodb_hash_key
  dynamodb_range_key                  = var.dynamodb_range_key
  dynamodb_attributes                 = var.dynamodb_attributes
  dynamodb_global_secondary_indexes   = var.dynamodb_global_secondary_indexes
  dynamodb_local_secondary_indexes    = var.dynamodb_local_secondary_indexes
  dynamodb_enable_encryption          = var.dynamodb_enable_encryption
  dynamodb_kms_key_arn                = var.dynamodb_kms_key_arn
  dynamodb_enable_point_in_time_recovery = var.dynamodb_enable_point_in_time_recovery
  dynamodb_ttl_attribute_name         = var.dynamodb_ttl_attribute_name

  # API Endpoint Integrations (Defining CRUD operations)
  api_endpoints                       = var.api_endpoints

  # Usage Plan Configuration
  usage_plan_quota_limit              = var.usage_plan_quota_limit
  usage_plan_quota_period             = var.usage_plan_quota_period
  usage_plan_throttle_rate            = var.usage_plan_throttle_rate
  usage_plan_throttle_burst           = var.usage_plan_throttle_burst
}

# --- Variable Definitions for the Example --- #
# These variables are used by this example configuration (main.tf)
# and are typically set in the terraform.tfvars file.

# AWS region where the infrastructure will be deployed.
variable "aws_region" {
  description = "AWS region for the example deployment."
  type        = string
}

# Default tags to apply to all resources created by this example.
variable "default_tags" {
  description = "Default tags for all resources in the example."
  type        = map(string)
  default     = {}
}

# Specific tags to apply to resources, potentially overriding default tags.
variable "tags" {
  description = "Specific tags for resources in the example."
  type        = map(string)
  default     = {}
}

# --- API Gateway Variables --- #

# Name for the API Gateway instance.
variable "api_name" {
  description = "API Gateway name."
  type        = string
}

# Optional description for the API Gateway.
variable "api_description" {
  description = "API Gateway description."
  type        = string
  default     = null
}

# List of endpoint types (e.g., ["REGIONAL"]).
variable "endpoint_types" {
  description = "API Gateway endpoint types."
  type        = list(string)
}

# Name of the deployment stage (e.g., "v1", "dev", "prod").
variable "stage_name" {
  description = "API Gateway deployment stage name."
  type        = string
}

# Set to true to configure a custom domain name for the API.
variable "create_custom_domain" {
  description = "Whether to create a custom domain for API Gateway."
  type        = bool
  default     = null
}

# The custom domain name (e.g., "api.example.com"). Required if create_custom_domain is true.
variable "domain_name" {
  description = "Custom domain name for API Gateway."
  type        = string
  default     = null
}

# ARN of the ACM certificate validating the custom domain name. Required if create_custom_domain is true.
variable "certificate_arn" {
  description = "ACM certificate ARN for the custom domain."
  type        = string
  default     = null
}

# Base path mapping for the custom domain (e.g., "items").
variable "base_path" {
  description = "Base path for the custom domain mapping."
  type        = string
  default     = null
}

# Optional ARN of an IAM role for API Gateway to write logs to CloudWatch.
variable "cloudwatch_role_arn" {
  description = "IAM role ARN for CloudWatch logging."
  type        = string
  default     = null
}

# Optional ARN of an AWS WAFv2 Web ACL to associate with the API Gateway stage.
variable "waf_acl_arn" {
  description = "WAF ACL ARN for API Gateway."
  type        = string
  default     = null
}

# Authorization type for API methods (e.g., "NONE", "AWS_IAM").
variable "api_authorization" {
  description = "Authorization type for API Gateway methods."
  type        = string
}

# Set to true to require an API key for accessing the methods.
variable "require_api_key" {
  description = "Whether to require an API key."
  type        = bool
}

# The base path for the collection resource (e.g., "/items", "/users").
variable "collection_name" {
  description = "Name of the collection resource in API Gateway (e.g., 'items')."
  type        = string
}

# Enable Cross-Origin Resource Sharing (CORS) preflight OPTIONS method.
variable "enable_cors" {
  description = "Enable CORS for API Gateway."
  type        = bool
}

# The Access-Control-Allow-Origin header value for CORS.
variable "cors_allow_origin" {
  description = "CORS allowed origin (e.g., '*' or 'https://example.com')."
  type        = string
}

# --- DynamoDB Variables --- #

# Name for the DynamoDB table.
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

# Billing mode for the DynamoDB table (PAY_PER_REQUEST or PROVISIONED).
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PAY_PER_REQUEST or PROVISIONED)."
  type        = string
}

# Read capacity units (RCU) if billing mode is PROVISIONED.
variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity (only if billing_mode is PROVISIONED)."
  type        = number
  default     = null
}

# Write capacity units (WCU) if billing mode is PROVISIONED.
variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity (only if billing_mode is PROVISIONED)."
  type        = number
  default     = null
}

# Name of the primary hash key (partition key) attribute.
variable "dynamodb_hash_key" {
  description = "DynamoDB hash key attribute name."
  type        = string
}

# Optional name of the primary range key (sort key) attribute.
variable "dynamodb_range_key" {
  description = "DynamoDB range key attribute name."
  type        = string
  default     = null
}

# List of attribute definitions for the table.
variable "dynamodb_attributes" {
  description = "DynamoDB attribute definitions."
  type = list(object({
    name = string
    type = string # S, N, or B
  }))
}

# Configuration for Global Secondary Indexes (GSIs).
variable "dynamodb_global_secondary_indexes" {
  description = "DynamoDB Global Secondary Index configurations."
  type        = any # More specific type in the module
  default     = []
}

# Configuration for Local Secondary Indexes (LSIs).
variable "dynamodb_local_secondary_indexes" {
  description = "DynamoDB Local Secondary Index configurations."
  type        = any # More specific type in the module
  default     = []
}

# Enable server-side encryption.
variable "dynamodb_enable_encryption" {
  description = "Enable DynamoDB server-side encryption."
  type        = bool
  default     = null
}

# Optional KMS key ARN for encryption (uses AWS-managed key if null).
variable "dynamodb_kms_key_arn" {
  description = "KMS key ARN for DynamoDB encryption."
  type        = string
  default     = null
}

# Enable Point-in-Time Recovery (PITR).
variable "dynamodb_enable_point_in_time_recovery" {
  description = "Enable DynamoDB Point-in-Time Recovery."
  type        = bool
  default     = null
}

# Optional attribute name to enable Time To Live (TTL) feature.
variable "dynamodb_ttl_attribute_name" {
  description = "DynamoDB TTL attribute name."
  type        = string
  default     = null
}

# --- API Endpoint Integration Variables --- #

# Map defining the API endpoints and their corresponding DynamoDB actions.
variable "api_endpoints" {
  description = "Map of API endpoints to configure with DynamoDB integrations."
  type        = any # More specific type in the module
}

# --- Usage Plan Variables --- #

# Quota limit for the API usage plan.
variable "usage_plan_quota_limit" {
  description = "Usage plan quota limit."
  type        = number
  default     = null
}

# Quota period for the API usage plan (DAY, WEEK, MONTH).
variable "usage_plan_quota_period" {
  description = "Usage plan quota period."
  type        = string
  default     = null
}

# Throttling rate limit for the API usage plan.
variable "usage_plan_throttle_rate" {
  description = "Usage plan throttle rate limit."
  type        = number
  default     = null
}

# Throttling burst limit for the API usage plan.
variable "usage_plan_throttle_burst" {
  description = "Usage plan throttle burst limit."
  type        = number
  default     = null
}

# --- Example Outputs --- #

# The base URL to invoke the deployed API stage.
output "api_gateway_invoke_url" {
  description = "Invoke URL for the API Gateway stage"
  value       = module.api_dynamodb.api_gateway_invoke_url
}

# The URL for the custom domain, if configured.
output "api_gateway_custom_domain_url" {
  description = "URL for the custom domain if configured"
  value       = module.api_dynamodb.api_gateway_custom_domain_url
}

# The name of the created DynamoDB table.
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table created"
  value       = module.api_dynamodb.dynamodb_table_name
}

# The ARN of the created DynamoDB table.
output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table created"
  value       = module.api_dynamodb.dynamodb_table_arn
} 