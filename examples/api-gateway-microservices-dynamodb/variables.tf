/**
 * Variables for the API Gateway with Microservices and DynamoDB Example
 */

# API Gateway settings
variable "api_name" {
  description = "Name of the API Gateway REST API"
  type        = string
  default     = "example-api"
}

variable "api_description" {
  description = "Description of the API Gateway REST API"
  type        = string
  default     = "Example API with Microservices and DynamoDB"
}

variable "endpoint_types" {
  description = "List of API Gateway endpoint types"
  type        = list(string)
  default     = ["REGIONAL"]
}

# Custom domain settings
variable "create_custom_domain" {
  description = "Whether to create a custom domain for the API Gateway"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Custom domain name for the API Gateway"
  type        = string
  default     = "api.example.com"
}

variable "base_path" {
  description = "Base path mapping for the custom domain"
  type        = string
  default     = "v1"
}

variable "stage_name" {
  description = "Name of the API Gateway deployment stage"
  type        = string
  default     = "prod"
}

# Security settings
variable "create_waf_acl" {
  description = "Whether to create a WAF WebACL for the API Gateway"
  type        = bool
  default     = false
}

variable "use_customer_managed_key" {
  description = "Whether to use a customer managed KMS key for DynamoDB encryption"
  type        = bool
  default     = false
}

# DynamoDB settings
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "example-data"
}

variable "dynamodb_hash_key" {
  description = "Hash key (partition key) name for the DynamoDB table"
  type        = string
  default     = "id"
}

variable "dynamodb_range_key" {
  description = "Range key (sort key) name for the DynamoDB table"
  type        = string
  default     = "createdAt"
}

variable "dynamodb_attributes" {
  description = "List of DynamoDB attributes in addition to the primary keys"
  type        = list(object({
    name = string
    type = string
  }))
  default = [
    {
      name = "userType"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    }
  ]
}

variable "dynamodb_global_secondary_indexes" {
  description = "List of global secondary indexes for the DynamoDB table"
  type        = list(any)
  default = [
    {
      name               = "UserTypeIndex"
      hash_key           = "userType"
      range_key          = "createdAt"
      projection_type    = "INCLUDE"
      non_key_attributes = ["id", "email"]
    },
    {
      name               = "EmailIndex"
      hash_key           = "email"
      projection_type    = "ALL"
    }
  ]
}

# CORS settings
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

# Lambda functions
variable "lambda_functions" {
  description = "Map of Lambda functions to create for the microservices"
  type        = map(any)
  default     = {
    users = {
      name            = "example-users-service"
      description     = "Users microservice"
      handler         = "index.handler"
      runtime         = "nodejs18.x"
      filename        = "lambda/example-function.zip"
      source_code_hash = null  # Will be updated in terraform.tfvars
      environment_variables = {
        STAGE = "example"
      }
    },
    items = {
      name            = "example-items-service"
      description     = "Items microservice"
      handler         = "index.handler"
      runtime         = "nodejs18.x"
      filename        = "lambda/example-function.zip"
      source_code_hash = null  # Will be updated in terraform.tfvars
    }
  }
}

# Additional tags
variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {
    Example = "true"
  }
} 