# Configure the AWS Provider
# Specifies the region where resources will be deployed and default tags.
provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources created by this configuration.
  default_tags {
    tags = var.default_tags
  }
}

# Instantiate the API Gateway Microservices to DynamoDB Pattern Module
# This module encapsulates the creation of API Gateway, multiple Lambda functions (microservices),
# a DynamoDB table, and associated IAM roles.
module "api_microservices" {
  # Source points to the pattern directory relative to this example.
  source = "../../patterns/api-gateway-microservices-dynamodb"

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
  api_authorization_type              = var.api_authorization_type
  api_authorizer_id                   = var.api_authorizer_id
  request_parameters                  = var.request_parameters
  enable_cors                         = var.enable_cors
  cors_allow_origin                   = var.cors_allow_origin

  # DynamoDB Configuration
  dynamodb_table_name                 = var.dynamodb_table_name
  dynamodb_billing_mode               = var.dynamodb_billing_mode
  dynamodb_read_capacity              = var.dynamodb_read_capacity
  dynamodb_write_capacity             = var.dynamodb_write_capacity
  dynamodb_hash_key                   = var.dynamodb_hash_key
  dynamodb_hash_key_type              = var.dynamodb_hash_key_type
  dynamodb_range_key                  = var.dynamodb_range_key
  dynamodb_range_key_type             = var.dynamodb_range_key_type
  dynamodb_attributes                 = var.dynamodb_attributes
  dynamodb_global_secondary_indexes   = var.dynamodb_global_secondary_indexes
  dynamodb_local_secondary_indexes    = var.dynamodb_local_secondary_indexes
  dynamodb_enable_encryption          = var.dynamodb_enable_encryption
  dynamodb_kms_key_arn                = var.dynamodb_kms_key_arn
  dynamodb_enable_point_in_time_recovery = var.dynamodb_enable_point_in_time_recovery
  dynamodb_ttl_attribute_name         = var.dynamodb_ttl_attribute_name
  dynamodb_stream_enabled             = var.dynamodb_stream_enabled
  dynamodb_stream_view_type           = var.dynamodb_stream_view_type

  # Lambda Functions Configuration (Map defining each microservice)
  lambda_functions                    = var.lambda_functions
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
  default     = false
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

# Base path mapping for the custom domain (e.g., "users", "items").
variable "base_path" {
  description = "Base path mapping for the custom domain."
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

# Authorization type for API methods (e.g., "NONE", "AWS_IAM", "COGNITO_USER_POOLS").
variable "api_authorization_type" {
  description = "Default authorization type for API Gateway methods."
  type        = string
  default     = "NONE"
}

# Optional Authorizer ID if using CUSTOM or COGNITO_USER_POOLS authorization.
variable "api_authorizer_id" {
  description = "Authorizer ID for API Gateway methods."
  type        = string
  default     = null
}

# Optional configuration for request parameters.
variable "request_parameters" {
  description = "Request parameters configuration for API Gateway methods."
  type        = map(bool)
  default     = {}
}

# Enable Cross-Origin Resource Sharing (CORS) preflight OPTIONS method.
variable "enable_cors" {
  description = "Enable CORS for API Gateway."
  type        = bool
  default     = true
}

# The Access-Control-Allow-Origin header value for CORS.
variable "cors_allow_origin" {
  description = "CORS allowed origin (e.g., '*' or 'https://example.com')."
  type        = string
  default     = "*"
}

# --- DynamoDB Variables --- #

# Name for the DynamoDB table.
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

# Billing mode for the DynamoDB table (PAY_PER_REQUEST or PROVISIONED).
variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode."
  type        = string
  default     = "PAY_PER_REQUEST"
}

# Read capacity units (RCU) if billing mode is PROVISIONED.
variable "dynamodb_read_capacity" {
  description = "DynamoDB read capacity (only if billing_mode is PROVISIONED)."
  type        = number
  default     = 5
}

# Write capacity units (WCU) if billing mode is PROVISIONED.
variable "dynamodb_write_capacity" {
  description = "DynamoDB write capacity (only if billing_mode is PROVISIONED)."
  type        = number
  default     = 5
}

# Name of the primary hash key (partition key) attribute.
variable "dynamodb_hash_key" {
  description = "DynamoDB hash key attribute name."
  type        = string
}

# Type of the primary hash key attribute (S, N, or B).
variable "dynamodb_hash_key_type" {
  description = "DynamoDB hash key attribute type."
  type        = string
  default     = "S"
}

# Optional name of the primary range key (sort key) attribute.
variable "dynamodb_range_key" {
  description = "DynamoDB range key attribute name."
  type        = string
  default     = null
}

# Optional type of the primary range key attribute (S, N, or B).
variable "dynamodb_range_key_type" {
  description = "DynamoDB range key attribute type."
  type        = string
  default     = "S"
}

# List of attribute definitions for the table (must include all key attributes).
variable "dynamodb_attributes" {
  description = "DynamoDB attribute definitions."
  type = list(object({
    name = string
    type = string # S, N, or B
  }))
  default = []
}

# Configuration for Global Secondary Indexes (GSIs).
variable "dynamodb_global_secondary_indexes" {
  description = "DynamoDB Global Secondary Index configurations."
  type        = any # More specific type defined in module
  default     = []
}

# Configuration for Local Secondary Indexes (LSIs).
variable "dynamodb_local_secondary_indexes" {
  description = "DynamoDB Local Secondary Index configurations."
  type        = any # More specific type defined in module
  default     = []
}

# Enable server-side encryption (recommended).
variable "dynamodb_enable_encryption" {
  description = "Enable DynamoDB server-side encryption."
  type        = bool
  default     = true
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
  default     = true
}

# Optional attribute name to enable Time To Live (TTL) feature.
variable "dynamodb_ttl_attribute_name" {
  description = "DynamoDB TTL attribute name."
  type        = string
  default     = null
}

# Enable DynamoDB Streams.
variable "dynamodb_stream_enabled" {
  description = "Enable DynamoDB Streams."
  type        = bool
  default     = false
}

# View type for DynamoDB Streams if enabled.
variable "dynamodb_stream_view_type" {
  description = "DynamoDB Stream view type."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

# --- Lambda Functions Variable --- #

# A map defining the configuration for each Lambda microservice.
# The key of the map typically represents the microservice name (e.g., "users", "orders").
variable "lambda_functions" {
  description = "Map defining Lambda functions for microservices."
  # Type is 'any' here as the exact structure is complex and validated within the module.
  # See the pattern's variables.tf and the example terraform.tfvars for the expected structure.
  type = any
}

# --- Example Outputs --- #

# The base URL to invoke the deployed API stage.
output "api_gateway_invoke_url" {
  description = "Invoke URL for the API Gateway stage"
  value       = module.api_microservices.api_gateway_invoke_url
}

# The URL for the custom domain, if configured.
output "api_gateway_custom_domain_url" {
  description = "URL for the custom domain if configured"
  value       = module.api_microservices.api_gateway_custom_domain_url
}

# The name of the created DynamoDB table.
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table created"
  value       = module.api_microservices.dynamodb_table_id # Corrected from original example output
}

# The ARN of the created DynamoDB table.
output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table created"
  value       = module.api_microservices.dynamodb_table_arn
}

# Map of microservice names to their Lambda function ARNs.
output "lambda_function_arns" {
  description = "ARNs of the Lambda functions created for microservices"
  value       = module.api_microservices.lambda_function_arns
}

# Map of microservice names to their base URLs.
output "microservice_urls" {
  description = "Invoke URLs for each microservice endpoint"
  value       = module.api_microservices.microservice_urls
} 