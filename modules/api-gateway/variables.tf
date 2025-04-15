/**
 * API Gateway Module Variables
 */

variable "api_name" {
  description = "Name of the API Gateway REST API"
  type        = string
}

variable "description" {
  description = "Description of the API Gateway REST API"
  type        = string
  default     = "API Gateway created with Terraform"
}

variable "endpoint_types" {
  description = "List of endpoint types. This can be EDGE, REGIONAL or PRIVATE"
  type        = list(string)
  default     = ["REGIONAL"]
  
  validation {
    condition     = length(var.endpoint_types) > 0 && alltrue([for t in var.endpoint_types : contains(["EDGE", "REGIONAL", "PRIVATE"], t)])
    error_message = "Endpoint types must be one or more of: EDGE, REGIONAL, PRIVATE."
  }
}

variable "binary_media_types" {
  description = "List of binary media types supported by the API Gateway"
  type        = list(string)
  default     = []
}

variable "create_custom_domain" {
  description = "Whether to create a custom domain name for the API Gateway"
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
  description = "Name of the stage for the API Gateway deployment"
  type        = string
  default     = "api"
}

variable "deployment_trigger" {
  description = "Map used as a deployment trigger. When the value changes, a new deployment will be created"
  type        = map(any)
  default     = { redeployment = "1" }
}

variable "enable_caching" {
  description = "Whether to enable caching for the API Gateway stage"
  type        = bool
  default     = false
}

variable "cache_cluster_size" {
  description = "Size of the cache cluster for the API Gateway stage (0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, 237)"
  type        = string
  default     = "0.5"
}

variable "access_log_settings" {
  description = "Settings for access logging of the API Gateway stage"
  type = object({
    destination_arn = string
    format          = string
  })
  default = null
}

variable "method_settings" {
  description = "Method settings for the API Gateway stage"
  type = object({
    method_path = string
    settings    = map(any)
  })
  default = null
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

variable "tags" {
  description = "Map of tags to assign to the API Gateway resources"
  type        = map(string)
  default     = {}
} 