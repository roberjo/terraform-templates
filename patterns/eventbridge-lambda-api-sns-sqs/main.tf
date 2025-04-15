/**
 * # EventBridge Lambda API SNS SQS Pattern
 *
 * This pattern sets up a complete data processing pipeline:
 * 1. EventBridge scheduler invokes a Lambda function on a schedule
 * 2. Lambda retrieves data from an external API
 * 3. Data is published to an SNS topic
 * 4. SNS message is sent to an SQS queue
 * 5. Either the same Lambda or a separate Lambda processes the messages from SQS
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

# EventBridge Scheduler IAM Role
resource "aws_iam_role" "scheduler_execution_role" {
  name = "${var.name_prefix}-scheduler-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "scheduler_execution_policy" {
  name = "${var.name_prefix}-scheduler-execution-policy"
  role = aws_iam_role.scheduler_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = module.lambda_function.lambda_function_arn
      }
    ]
  })
}

# EventBridge Scheduler
resource "aws_scheduler_schedule" "api_data_processor" {
  name        = var.scheduler_name != "" ? var.scheduler_name : "${var.name_prefix}-api-data-processor"
  description = var.scheduler_description

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule_expression
  state               = var.scheduler_state

  target {
    arn      = module.lambda_function.lambda_function_arn
    role_arn = aws_iam_role.scheduler_execution_role.arn

    input = jsonencode({
      api_endpoint = var.api_endpoint
      api_key      = var.api_key
      batch_size   = var.batch_size
    })
  }

  tags = var.tags
}

# Lambda Function
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = var.lambda_function_name != "" ? var.lambda_function_name : "${var.name_prefix}-api-processor"
  description   = var.lambda_description
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  publish       = var.lambda_publish_version

  source_path = var.lambda_source_path
  layers      = var.lambda_layers

  memory_size                    = var.lambda_memory_size
  timeout                        = var.lambda_timeout
  reserved_concurrent_executions = var.lambda_reserved_concurrency

  environment_variables = merge(
    {
      SNS_TOPIC_ARN = aws_sns_topic.api_data_topic.arn
    },
    var.lambda_environment_variables
  )

  allowed_triggers = {
    EventBridgeScheduler = {
      principal  = "scheduler.amazonaws.com"
      source_arn = aws_scheduler_schedule.api_data_processor.arn
    }
  }

  attach_policy_statements = true
  policy_statements = {
    SNSPublish = {
      effect    = "Allow",
      actions   = ["sns:Publish"],
      resources = [aws_sns_topic.api_data_topic.arn]
    }
  }

  tags = var.tags
}

# SNS Topic for API Data
resource "aws_sns_topic" "api_data_topic" {
  name              = var.sns_topic_name != "" ? var.sns_topic_name : "${var.name_prefix}-api-data-topic"
  kms_master_key_id = var.sns_kms_key_arn != "" ? var.sns_kms_key_arn : null
  fifo_topic        = var.sns_fifo_topic

  tags = var.tags
}

# Optional SNS Dead Letter Queue
resource "aws_sqs_queue" "sns_dlq" {
  count = var.sns_dlq_arn == "" && var.create_sns_dlq ? 1 : 0

  name                       = "${var.name_prefix}-sns-dlq"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 1209600  # 14 days
  
  tags = var.tags
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "api_data_topic_policy" {
  arn    = aws_sns_topic.api_data_topic.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.name_prefix}-sns-topic-policy"
    Statement = [
      {
        Sid       = "AllowLambdaPublish"
        Effect    = "Allow"
        Principal = {
          AWS = module.lambda_function.lambda_role_arn
        }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.api_data_topic.arn
      }
    ]
  })
}

# SQS Queue
resource "aws_sqs_queue" "api_data_queue" {
  name                       = var.sqs_queue_name != "" ? var.sqs_queue_name : "${var.name_prefix}-api-data-queue"
  visibility_timeout_seconds = var.sqs_visibility_timeout
  message_retention_seconds  = var.sqs_message_retention_seconds
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
  
  # Enable SQS DLQ if specified
  redrive_policy = var.create_sqs_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.api_data_dlq[0].arn
    maxReceiveCount     = var.sqs_max_receive_count
  }) : null

  # Server-side encryption if specified
  kms_master_key_id                 = var.sqs_kms_key_arn != "" ? var.sqs_kms_key_arn : null
  kms_data_key_reuse_period_seconds = var.sqs_kms_key_arn != "" ? 300 : null

  tags = var.tags
}

# Optional SQS Dead Letter Queue
resource "aws_sqs_queue" "api_data_dlq" {
  count = var.create_sqs_dlq ? 1 : 0

  name                       = "${var.name_prefix}-api-data-dlq"
  message_retention_seconds  = 1209600  # 14 days
  
  # Server-side encryption if specified
  kms_master_key_id                 = var.sqs_kms_key_arn != "" ? var.sqs_kms_key_arn : null
  kms_data_key_reuse_period_seconds = var.sqs_kms_key_arn != "" ? 300 : null

  tags = var.tags
}

# SNS to SQS Subscription
resource "aws_sns_topic_subscription" "sns_to_sqs" {
  topic_arn            = aws_sns_topic.api_data_topic.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.api_data_queue.arn
  raw_message_delivery = var.sns_raw_message_delivery
  
  filter_policy        = var.sns_filter_policy != "" ? var.sns_filter_policy : null
  filter_policy_scope  = var.sns_filter_policy != "" ? var.sns_filter_policy_scope : null
  
  depends_on = [aws_sns_topic.api_data_topic, aws_sqs_queue.api_data_queue]
}

# SQS Queue Policy - Allow SNS to send messages
resource "aws_sqs_queue_policy" "api_data_queue_policy" {
  queue_url = aws_sqs_queue.api_data_queue.url

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.name_prefix}-sqs-policy"
    Statement = [
      {
        Sid       = "AllowSNSToSendMessage"
        Effect    = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.api_data_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.api_data_topic.arn
          }
        }
      }
    ]
  })
}

# Optional separate SQS processor Lambda function
module "sqs_processor_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"
  
  count = var.create_separate_sqs_processor ? 1 : 0

  function_name = var.sqs_processor_function_name != "" ? var.sqs_processor_function_name : "${var.name_prefix}-sqs-processor"
  description   = var.sqs_processor_description
  handler       = var.sqs_processor_handler
  runtime       = var.sqs_processor_runtime
  publish       = var.sqs_processor_publish_version

  source_path = var.sqs_processor_source_path
  layers      = var.sqs_processor_layers

  memory_size                    = var.sqs_processor_memory_size
  timeout                        = var.sqs_processor_timeout
  reserved_concurrent_executions = var.sqs_processor_reserved_concurrency

  environment_variables = var.sqs_processor_environment_variables

  attach_policy_statements = true
  policy_statements = {
    SQSReceive = {
      effect    = "Allow",
      actions   = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      resources = [aws_sqs_queue.api_data_queue.arn]
    }
  }

  tags = var.tags
}

# SQS Event Source Mapping - only create if using a separate SQS processor
resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  count = var.create_separate_sqs_processor ? 1 : 0
  
  event_source_arn = aws_sqs_queue.api_data_queue.arn
  function_name    = module.sqs_processor_lambda[0].lambda_function_arn
  
  batch_size                         = var.sqs_processor_batch_size
  maximum_batching_window_in_seconds = var.sqs_processor_max_batching_window
  
  enabled = var.sqs_processor_enabled
} 