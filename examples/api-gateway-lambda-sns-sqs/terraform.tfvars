/**
 * # API Gateway with Lambda, SNS, and SQS Pattern - Example Configuration
 *
 * Fill in the required values, especially placeholders.
 */

aws_region = "us-east-1"

default_tags = {
  Environment = "dev"
  Project     = "ExampleMessageAPI"
  Terraform   = "true"
}

tags = {
  Owner = "example-team"
}

# API Gateway Configuration
api_name        = "example-message-api"
api_description = "Example API for asynchronous message processing"
endpoint_types  = ["REGIONAL"]
stage_name      = "v1"

# Custom Domain Configuration (optional)
create_custom_domain = false
# domain_name         = "api.my-example.com" # Change to your domain
# certificate_arn     = "arn:aws:acm:us-east-1:123456789012:certificate/YOUR-CERTIFICATE-ID" # Replace with your cert ARN in us-east-1
# base_path           = "messages"

# API Configuration
api_resource_path    = "process"
api_authorization_type = "NONE" # Could be AWS_IAM, COGNITO_USER_POOLS, etc.
require_api_key      = false

# CORS Configuration (Enable if API will be called from a web browser)
enable_cors       = true
cors_allow_origin = "*" # Be more specific in production (e.g., "https://myfrontend.com")
cors_allow_methods = "OPTIONS,POST"
cors_allow_headers = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"

# SNS Topic Configuration
sns_topic_name = "example-message-topic"
# sns_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/YOUR-KMS-KEY-ID" # Optional KMS encryption

# SQS Queue Configuration
sqs_queue_name          = "example-message-queue"
sqs_visibility_timeout  = 60
sqs_message_retention   = 345600 # 4 days
sqs_max_message_size    = 262144 # 256 KB
sqs_use_managed_sse     = true
create_sqs_dlq          = true
sqs_max_receive_count   = 5
# sqs_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/YOUR-KMS-KEY-ID" # Optional KMS encryption

# API Lambda Function Configuration
lambda_function_name = "example-api-handler"
lambda_description   = "Processes incoming API requests and publishes to SNS"
lambda_handler       = "index.handler" # Update based on your code (filename.handler_function)
lambda_runtime       = "nodejs18.x" # Match your Lambda code's runtime
lambda_timeout       = 10
lambda_memory_size   = 128

# ** REQUIRED: UPDATE ONE OF THE FOLLOWING FOR LAMBDA CODE **
# Option 1: Local zip file (provide path and uncomment)
# lambda_filename = "./path/to/your/api-handler.zip"
# Option 2: S3 object (provide bucket/key and uncomment)
# lambda_s3_bucket = "your-lambda-deployment-bucket"
# lambda_s3_key    = "path/in/bucket/api-handler.zip"

# Lambda Environment Variables
lambda_environment_variables = {
  LOG_LEVEL = "INFO"
}

# SQS Processor Lambda Configuration
create_separate_sqs_processor = true # Set to false if the API Lambda also handles SQS messages
sqs_processor_function_name   = "example-sqs-processor"
sqs_processor_description     = "Processes messages from the SQS queue"
sqs_processor_handler         = "index.handler" # Update based on your code (filename.handler_function)
sqs_processor_runtime         = "nodejs18.x" # Match your Lambda code's runtime
sqs_processor_timeout         = 30
sqs_processor_memory_size     = 128
sqs_processor_batch_size      = 10

# ** REQUIRED if create_separate_sqs_processor=true: UPDATE ONE OF THE FOLLOWING FOR LAMBDA CODE **
# Option 1: Local zip file (provide path and uncomment)
# sqs_processor_filename = "./path/to/your/sqs-processor.zip"
# Option 2: S3 object (provide bucket/key and uncomment)
# sqs_processor_s3_bucket = "your-lambda-deployment-bucket"
# sqs_processor_s3_key    = "path/in/bucket/sqs-processor.zip"

# SQS Processor Lambda Environment Variables
sqs_processor_environment_variables = {
  LOG_LEVEL = "INFO"
}

# Other Optional Settings
# waf_acl_arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/YOUR-WAF-ACL-ID" # WAF for Regional API Gateway
# usage_plan_throttle_burst = 10
# usage_plan_throttle_rate  = 20
# usage_plan_quota_limit    = 5000
# sns_dlq_arn = "arn:aws:sqs:us-east-1:123456789012:my-sns-dlq"
# sqs_dlq_arn = "arn:aws:sqs:us-east-1:123456789012:my-sqs-dlq"
# lambda_process_sqs_messages = false # If primary lambda handles SQS
# lambda_sqs_batch_size = 5         # If primary lambda handles SQS 