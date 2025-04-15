# AWS Lambda Terraform Module

This Terraform module creates an AWS Lambda function with associated IAM roles, CloudWatch logging, and optional features like event source mappings and function URLs.

## Features

- Creates Lambda function with configurable settings
- Automatically creates IAM roles with appropriate permissions
- Sets up CloudWatch logging with configurable retention
- Supports event source mappings (e.g., for SQS, DynamoDB)
- Optional function URL endpoint
- Dead letter queue configuration
- X-Ray tracing support
- VPC configuration

## Usage

```hcl
module "lambda_function" {
  source = "../../modules/lambda"

  function_name = "my-function"
  description   = "Example Lambda function"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  timeout       = 10
  memory_size   = 256
  
  # Source code
  filename         = "${path.module}/lambda/function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")
  
  # Environment variables
  environment_variables = {
    ENVIRONMENT = "production"
    API_URL     = "https://api.example.com"
  }
  
  # Custom IAM policy
  create_lambda_function_policy = true
  lambda_function_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/my-table"
      }
    ]
  })
  
  # CloudWatch logs
  log_retention_in_days = 30
  
  # Function URL
  create_function_url = true
  function_url_authorization_type = "NONE"
  function_url_cors = {
    allow_origins = ["https://example.com"]
    allow_methods = ["GET", "POST"]
  }
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Required IAM Permissions

The module automatically creates the following IAM permissions:

1. Lambda execution role with basic permissions
2. CloudWatch Logs permissions for Lambda logging
3. Optional custom policy for specific Lambda function needs

To deploy this module, you need IAM permissions to:
- Create/update IAM roles and policies
- Create/update Lambda functions
- Create/update CloudWatch Log groups

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| function_name | Name of the Lambda function | `string` | n/a | yes |
| description | Description of the Lambda function | `string` | `""` | no |
| handler | Lambda function handler (e.g., index.handler) | `string` | n/a | yes |
| runtime | Lambda function runtime | `string` | `"nodejs18.x"` | no |
| timeout | Lambda function timeout in seconds | `number` | `3` | no |
| memory_size | Lambda function memory size in MB | `number` | `128` | no |
| filename | Path to the function's deployment package | `string` | `null` | no |
| source_code_hash | Base64-encoded hash of the package file | `string` | `null` | no |
| s3_bucket | S3 bucket containing the function's deployment package | `string` | `null` | no |
| s3_key | S3 key of the function's deployment package | `string` | `null` | no |
| s3_object_version | S3 object version of the function's deployment package | `string` | `null` | no |
| environment_variables | Map of environment variables | `map(string)` | `{}` | no |
| subnet_ids | List of subnet IDs for VPC configuration | `list(string)` | `null` | no |
| security_group_ids | List of security group IDs for VPC configuration | `list(string)` | `null` | no |
| dead_letter_target_arn | ARN for dead letter queue | `string` | `null` | no |
| tracing_mode | X-Ray tracing mode | `string` | `null` | no |
| layers | List of Lambda layer ARNs to attach | `list(string)` | `[]` | no |
| reserved_concurrent_executions | Amount of reserved concurrent executions | `number` | `-1` | no |
| log_retention_in_days | Number of days to retain Lambda logs | `number` | `14` | no |
| log_kms_key_id | KMS key ARN for encrypting logs | `string` | `null` | no |
| create_lambda_function_policy | Whether to create a custom IAM policy | `bool` | `false` | no |
| lambda_function_policy | JSON policy document for the Lambda function | `string` | `"{}"` | no |
| managed_policy_arns | List of managed IAM policy ARNs to attach | `list(string)` | `[]` | no |
| use_name_prefix | Whether to use name_prefix for IAM resources | `bool` | `false` | no |
| event_source_mappings | List of event source mapping configurations | `list(any)` | `[]` | no |
| create_function_url | Whether to create a Lambda function URL | `bool` | `false` | no |
| function_url_authorization_type | Authorization type for the function URL | `string` | `"NONE"` | no |
| function_url_cors | CORS settings for the function URL | `object` | `{}` | no |
| tags | A map of tags to assign to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_arn | ARN of the Lambda function |
| function_name | Name of the Lambda function |
| function_qualified_arn | ARN identifying your Lambda function version |
| function_invoke_arn | ARN to be used for invoking Lambda function from API Gateway |
| function_version | Latest published version of the Lambda function |
| function_last_modified | Date Lambda function was last modified |
| function_source_code_hash | Base64-encoded representation of the Lambda function source code |
| role_arn | ARN of the IAM role created for the Lambda function |
| role_name | Name of the IAM role created for the Lambda function |
| role_unique_id | Unique ID of the IAM role created for the Lambda function |
| log_group_name | Name of the CloudWatch log group for the Lambda function |
| log_group_arn | ARN of the CloudWatch log group for the Lambda function |
| event_source_mapping_ids | List of event source mapping IDs |
| event_source_mapping_arns | List of event source mapping ARNs |
| function_url | Lambda function URL (if enabled) |

## Notes on Lambda Function URLs

When enabling function URLs (`create_function_url = true`), be aware of the following:

1. For public endpoints, set `function_url_authorization_type = "NONE"`
2. For private endpoints, set `function_url_authorization_type = "AWS_IAM"`
3. Configure CORS settings through the `function_url_cors` variable if your function will be accessed from web browsers

## Event Source Mapping Example

To set up an event source mapping for an SQS queue:

```hcl
module "lambda_function" {
  source = "../../modules/lambda"
  
  function_name = "sqs-consumer"
  # ... other settings ...
  
  event_source_mappings = [
    {
      event_source_arn = aws_sqs_queue.queue.arn
      batch_size = 10
      maximum_batching_window_in_seconds = 30
    }
  ]
  
  # Add SQS permissions
  create_lambda_function_policy = true
  lambda_function_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.queue.arn
      }
    ]
  })
}
``` 