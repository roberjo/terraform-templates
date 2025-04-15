/**
 * # AWS Lambda Module
 *
 * This module creates an AWS Lambda function with associated IAM role, 
 * logging, and optional event source mappings.
 */

# IAM role for the Lambda function
resource "aws_iam_role" "lambda" {
  name = var.use_name_prefix ? null : var.function_name
  name_prefix = var.use_name_prefix ? "${var.function_name}-" : null
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  # Attach managed policies if provided
  dynamic "managed_policy_arns" {
    for_each = length(var.managed_policy_arns) > 0 ? [1] : []
    content {
      managed_policy_arns = var.managed_policy_arns
    }
  }
  
  tags = var.tags
}

# Lambda function IAM policy
resource "aws_iam_policy" "lambda" {
  count = var.create_lambda_function_policy ? 1 : 0
  
  name        = var.use_name_prefix ? null : "${var.function_name}-policy"
  name_prefix = var.use_name_prefix ? "${var.function_name}-policy-" : null
  description = "Policy for Lambda function ${var.function_name}"
  
  policy = var.lambda_function_policy
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda" {
  count = var.create_lambda_function_policy ? 1 : 0
  
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda[0].arn
}

# CloudWatch Logs policy
resource "aws_iam_policy" "lambda_logging" {
  name        = var.use_name_prefix ? null : "${var.function_name}-logging"
  name_prefix = var.use_name_prefix ? "${var.function_name}-logging-" : null
  description = "IAM policy for logging from Lambda ${var.function_name}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the logging policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Lambda function
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  role          = aws_iam_role.lambda.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  
  # Source code options
  filename         = var.filename != null ? var.filename : null
  source_code_hash = var.source_code_hash
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  s3_object_version = var.s3_object_version
  
  # Environment variables
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }
  
  # VPC configuration
  dynamic "vpc_config" {
    for_each = var.subnet_ids != null && var.security_group_ids != null ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }
  
  # Dead letter configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }
  
  # Tracing config
  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }
  
  # Layers
  layers = var.layers
  
  # Reserved concurrent executions
  reserved_concurrent_executions = var.reserved_concurrent_executions
  
  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.log_kms_key_id
  
  tags = var.tags
}

# Event source mappings
resource "aws_lambda_event_source_mapping" "this" {
  count = length(var.event_source_mappings)
  
  function_name    = aws_lambda_function.this.function_name
  event_source_arn = var.event_source_mappings[count.index].event_source_arn
  
  enabled                            = lookup(var.event_source_mappings[count.index], "enabled", true)
  batch_size                         = lookup(var.event_source_mappings[count.index], "batch_size", 100)
  maximum_batching_window_in_seconds = lookup(var.event_source_mappings[count.index], "maximum_batching_window_in_seconds", 0)
  starting_position                  = lookup(var.event_source_mappings[count.index], "starting_position", null)
  starting_position_timestamp        = lookup(var.event_source_mappings[count.index], "starting_position_timestamp", null)
  parallelization_factor             = lookup(var.event_source_mappings[count.index], "parallelization_factor", null)
  maximum_record_age_in_seconds      = lookup(var.event_source_mappings[count.index], "maximum_record_age_in_seconds", null)
  bisect_batch_on_function_error     = lookup(var.event_source_mappings[count.index], "bisect_batch_on_function_error", null)
  maximum_retry_attempts             = lookup(var.event_source_mappings[count.index], "maximum_retry_attempts", null)
}

# Function URL (optional)
resource "aws_lambda_function_url" "this" {
  count = var.create_function_url ? 1 : 0
  
  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.function_url_authorization_type
  cors {
    allow_credentials = var.function_url_cors.allow_credentials
    allow_origins     = var.function_url_cors.allow_origins
    allow_methods     = var.function_url_cors.allow_methods
    allow_headers     = var.function_url_cors.allow_headers
    expose_headers    = var.function_url_cors.expose_headers
    max_age           = var.function_url_cors.max_age
  }
} 