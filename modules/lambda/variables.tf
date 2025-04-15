/**
 * Lambda Module Variables
 */

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Lambda function handler (e.g., index.handler)"
  type        = string
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "nodejs18.x"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "filename" {
  description = "Path to the function's deployment package (ZIP file)"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded hash of the package file"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the function's deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the function's deployment package"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the function's deployment package"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Lambda function VPC configuration"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs for the Lambda function VPC configuration"
  type        = list(string)
  default     = null
}

variable "dead_letter_target_arn" {
  description = "ARN of an SNS topic or SQS queue for the Lambda function's dead letter queue"
  type        = string
  default     = null
}

variable "tracing_mode" {
  description = "X-Ray tracing mode (PassThrough or Active)"
  type        = string
  default     = null
  
  validation {
    condition     = var.tracing_mode == null ? true : contains(["PassThrough", "Active"], var.tracing_mode)
    error_message = "Tracing mode must be PassThrough or Active."
  }
}

variable "layers" {
  description = "List of Lambda layer ARNs to attach to the function"
  type        = list(string)
  default     = []
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for the Lambda function"
  type        = number
  default     = -1
}

variable "log_retention_in_days" {
  description = "Number of days to retain Lambda function logs"
  type        = number
  default     = 14
  
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_in_days)
    error_message = "Log retention days must be one of: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "log_kms_key_id" {
  description = "KMS key ARN to use for encrypting Lambda logs"
  type        = string
  default     = null
}

variable "create_lambda_function_policy" {
  description = "Whether to create a custom IAM policy for the Lambda function"
  type        = bool
  default     = false
}

variable "lambda_function_policy" {
  description = "JSON policy document for the Lambda function"
  type        = string
  default     = "{}"
}

variable "managed_policy_arns" {
  description = "List of managed IAM policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "use_name_prefix" {
  description = "Whether to use name_prefix for IAM resources instead of fixed names"
  type        = bool
  default     = false
}

variable "event_source_mappings" {
  description = "List of event source mapping configurations"
  type        = list(any)
  default     = []
}

variable "create_function_url" {
  description = "Whether to create a Lambda function URL"
  type        = bool
  default     = false
}

variable "function_url_authorization_type" {
  description = "Authorization type for the function URL (NONE or AWS_IAM)"
  type        = string
  default     = "NONE"
  
  validation {
    condition     = contains(["NONE", "AWS_IAM"], var.function_url_authorization_type)
    error_message = "Authorization type must be NONE or AWS_IAM."
  }
}

variable "function_url_cors" {
  description = "CORS settings for the function URL"
  type = object({
    allow_credentials = optional(bool, false)
    allow_origins     = optional(list(string), ["*"])
    allow_methods     = optional(list(string), ["*"])
    allow_headers     = optional(list(string), ["*"])
    expose_headers    = optional(list(string), [])
    max_age           = optional(number, 0)
  })
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
} 