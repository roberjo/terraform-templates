/**
 * # API Gateway with Lambda, SNS, and SQS Pattern
 *
 * This pattern creates an API Gateway that integrates with a Lambda function
 * which processes incoming messages and publishes them to an SNS topic for fanout.
 * The SNS topic then delivers messages to an SQS queue for asynchronous processing.
 */

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

# Create API Gateway
module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name        = var.api_name
  description     = var.api_description
  endpoint_types  = var.endpoint_types
  
  # Custom domain configuration
  create_custom_domain = var.create_custom_domain
  domain_name          = var.domain_name
  certificate_arn      = var.certificate_arn
  base_path            = var.base_path
  
  # Stage configuration
  stage_name = var.stage_name
  
  # CloudWatch logging
  cloudwatch_role_arn = var.cloudwatch_role_arn
  
  # WAF integration
  waf_acl_arn = var.waf_acl_arn
  
  # Deployment trigger to ensure updates propagate
  deployment_trigger = {
    redeployment = timestamp()
  }
  
  tags = var.tags
}

# SNS Topic for message fanout
resource "aws_sns_topic" "this" {
  name = var.sns_topic_name
  
  # Enable server-side encryption if KMS key ARN is provided
  kms_master_key_id = var.sns_kms_key_arn != null ? var.sns_kms_key_arn : "alias/aws/sns"
  
  # Configure DLQ for failed message delivery if provided
  dynamic "redrive_policy" {
    for_each = var.sns_dlq_arn != null ? [1] : []
    content {
      dead_letter_target_arn = var.sns_dlq_arn
    }
  }
  
  tags = var.tags
}

# SQS Queue for message processing
resource "aws_sqs_queue" "this" {
  name = var.sqs_queue_name
  
  # Queue configuration
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  
  # Enable encryption
  sqs_managed_sse_enabled = var.sqs_use_managed_sse
  kms_master_key_id       = !var.sqs_use_managed_sse && var.sqs_kms_key_arn != null ? var.sqs_kms_key_arn : null
  
  # DLQ configuration
  redrive_policy = var.sqs_dlq_arn != null ? jsonencode({
    deadLetterTargetArn = var.sqs_dlq_arn
    maxReceiveCount     = var.sqs_max_receive_count
  }) : null
  
  tags = var.tags
}

# Dead Letter Queue for SQS (if not provided externally)
resource "aws_sqs_queue" "dlq" {
  count = var.create_sqs_dlq ? 1 : 0
  
  name = "${var.sqs_queue_name}-dlq"
  
  # DLQ configuration
  message_retention_seconds = var.sqs_dlq_message_retention
  
  # Enable encryption
  sqs_managed_sse_enabled = var.sqs_use_managed_sse
  kms_master_key_id       = !var.sqs_use_managed_sse && var.sqs_kms_key_arn != null ? var.sqs_kms_key_arn : null
  
  tags = var.tags
}

# Subscribe SQS queue to SNS topic
resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.this.arn
  
  # Set filter policy if provided
  filter_policy = var.sns_subscription_filter_policy != null ? jsonencode(var.sns_subscription_filter_policy) : null
}

# SQS queue policy to allow SNS to send messages
resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action = "sqs:SendMessage"
        Resource = aws_sqs_queue.this.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.this.arn
          }
        }
      }
    ]
  })
}

# Lambda function to process API requests
module "lambda" {
  source = "../../modules/lambda"

  function_name = var.lambda_function_name
  description   = var.lambda_description
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  
  # Source code
  filename         = var.lambda_filename
  source_code_hash = var.lambda_source_code_hash
  s3_bucket        = var.lambda_s3_bucket
  s3_key           = var.lambda_s3_key
  
  # Environment variables
  environment_variables = merge(
    {
      SNS_TOPIC_ARN = aws_sns_topic.this.arn
    },
    var.lambda_environment_variables
  )
  
  # Lambda permissions
  create_lambda_function_policy = true
  lambda_function_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          aws_sns_topic.this.arn
        ]
      }
    ]
  })
  
  # VPC configuration if specified
  subnet_ids         = var.lambda_subnet_ids
  security_group_ids = var.lambda_security_group_ids
  
  # Lambda DLQ if specified
  dead_letter_target_arn = var.lambda_dlq_arn
  
  # Tracing
  tracing_mode = var.lambda_tracing_mode
  
  # Optional event source mappings to handle SQS messages directly
  event_source_mappings = var.lambda_process_sqs_messages ? [
    {
      event_source_arn = aws_sqs_queue.this.arn
      batch_size       = var.lambda_sqs_batch_size
      enabled          = true
    }
  ] : []
  
  tags = var.tags
}

# SQS message processor Lambda (if different from API handler)
module "sqs_processor" {
  count  = var.create_separate_sqs_processor ? 1 : 0
  source = "../../modules/lambda"

  function_name = var.sqs_processor_function_name
  description   = var.sqs_processor_description
  handler       = var.sqs_processor_handler
  runtime       = var.sqs_processor_runtime
  timeout       = var.sqs_processor_timeout
  memory_size   = var.sqs_processor_memory_size
  
  # Source code
  filename         = var.sqs_processor_filename
  source_code_hash = var.sqs_processor_source_code_hash
  s3_bucket        = var.sqs_processor_s3_bucket
  s3_key           = var.sqs_processor_s3_key
  
  # Environment variables
  environment_variables = var.sqs_processor_environment_variables
  
  # Event source mapping for SQS queue
  event_source_mappings = [
    {
      event_source_arn = aws_sqs_queue.this.arn
      batch_size       = var.sqs_processor_batch_size
      enabled          = true
    }
  ]
  
  # VPC configuration if specified
  subnet_ids         = var.sqs_processor_subnet_ids
  security_group_ids = var.sqs_processor_security_group_ids
  
  # Lambda DLQ if specified
  dead_letter_target_arn = var.sqs_processor_dlq_arn
  
  # Tracing
  tracing_mode = var.sqs_processor_tracing_mode
  
  tags = var.tags
}

# API Gateway resource for messages endpoint
resource "aws_api_gateway_resource" "messages" {
  rest_api_id = module.api_gateway.rest_api_id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = var.api_resource_path
}

# POST method for messages endpoint
resource "aws_api_gateway_method" "post" {
  rest_api_id      = module.api_gateway.rest_api_id
  resource_id      = aws_api_gateway_resource.messages.id
  http_method      = "POST"
  authorization_type = var.api_authorization_type
  authorizer_id    = var.api_authorizer_id
  api_key_required = var.require_api_key
  
  request_parameters = var.api_request_parameters
}

# Integration with Lambda
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.post.http_method
  
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.function_invoke_arn
}

# Method response
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
  
  # CORS headers if enabled
  response_parameters = var.enable_cors ? {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  } : {}
}

# CORS support if enabled
resource "aws_api_gateway_method" "options" {
  count = var.enable_cors ? 1 : 0
  
  rest_api_id   = module.api_gateway.rest_api_id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "OPTIONS"
  authorization_type = "NONE"
}

# CORS integration
resource "aws_api_gateway_integration" "options" {
  count = var.enable_cors ? 1 : 0
  
  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options[0].http_method
  
  type = "MOCK"
  
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# CORS method response
resource "aws_api_gateway_method_response" "options_200" {
  count = var.enable_cors ? 1 : 0
  
  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options[0].http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  
  response_models = {
    "application/json" = "Empty"
  }
}

# CORS integration response
resource "aws_api_gateway_integration_response" "options" {
  count = var.enable_cors ? 1 : 0
  
  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.messages.id
  http_method = aws_api_gateway_method.options[0].http_method
  status_code = aws_api_gateway_method_response.options_200[0].status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allow_origin}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${var.cors_allow_methods}'"
    "method.response.header.Access-Control-Allow-Headers" = "'${var.cors_allow_headers}'"
  }
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  
  # Allow invocation from specified API Gateway
  source_arn = "${module.api_gateway.rest_api_execution_arn}/*/${aws_api_gateway_method.post.http_method}/${var.api_resource_path}"
}

# API Usage Plan (if API key is required)
resource "aws_api_gateway_usage_plan" "this" {
  count = var.require_api_key ? 1 : 0
  
  name        = "${var.api_name}-usage-plan"
  description = "Usage plan for ${var.api_name}"
  
  api_stages {
    api_id = module.api_gateway.rest_api_id
    stage  = module.api_gateway.stage_name
  }
  
  # Throttling configuration
  throttle_settings {
    burst_limit = var.usage_plan_throttle_burst
    rate_limit  = var.usage_plan_throttle_rate
  }
  
  # Quota configuration
  quota_settings {
    limit  = var.usage_plan_quota_limit
    period = var.usage_plan_quota_period
  }
} 