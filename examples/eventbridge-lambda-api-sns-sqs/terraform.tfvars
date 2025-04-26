/**
 * # EventBridge with Lambda, SNS, and SQS Pattern - Example Configuration
 *
 * This is an example configuration for the EventBridge with Lambda, SNS, and SQS pattern.
 * Fill in the required values, especially placeholders.
 */

aws_region = "us-east-1"

name_prefix = "eb-api-example"

default_tags = {
  Environment = "dev"
  Project     = "ExampleDataProcessing"
  Terraform   = "true"
}

tags = {
  Owner = "example-team"
}

# EventBridge Scheduler Configuration
scheduler_name        = "example-api-scheduler"
scheduler_description = "Scheduler that triggers Lambda to retrieve data from example API"
schedule_expression   = "rate(1 hour)" # Run hourly
scheduler_state       = "ENABLED"

# API Configuration
api_endpoint = "https://jsonplaceholder.typicode.com/todos" # Example public API
# api_key      = "YOUR_API_KEY_HERE" # Uncomment and replace if API requires a key
batch_size   = 10

# Lambda Function Configuration
lambda_function_name   = "example-api-processor"
lambda_description     = "Retrieves data from example API and publishes to SNS"
lambda_handler         = "index.handler" # Assumes a default handler name
lambda_runtime         = "nodejs18.x" # Match the runtime of your Lambda code
lambda_timeout         = 30
lambda_memory_size     = 128
lambda_publish_version = false

# Path to Lambda deployment package - ** REQUIRED: UPDATE THIS PATH **
lambda_source_path = "./path/to/your/api-processor-lambda.zip"

# Lambda Environment Variables
lambda_environment_variables = {
  LOG_LEVEL = "INFO"
}

# SNS Topic Configuration
sns_topic_name = "example-api-data-topic"
sns_fifo_topic = false
create_sns_dlq = true

# SQS Queue Configuration
sqs_queue_name                = "example-api-data-queue"
sqs_visibility_timeout        = 60
sqs_message_retention_seconds = 345600 # 4 days
sqs_max_message_size          = 262144 # 256 KB
sqs_delay_seconds             = 0
sqs_receive_wait_time_seconds = 0
create_sqs_dlq                = true
sqs_max_receive_count         = 5

# SQS Processor Lambda Configuration
create_separate_sqs_processor = true # Set to false if the primary lambda also handles SQS
sqs_processor_function_name   = "example-sqs-data-processor"
sqs_processor_description     = "Processes messages from example SQS queue"
sqs_processor_handler         = "index.handler" # Assumes a default handler name
sqs_processor_runtime         = "nodejs18.x" # Match the runtime of your Lambda code
sqs_processor_timeout         = 30
sqs_processor_memory_size     = 128
sqs_processor_batch_size      = 10
sqs_processor_max_batching_window = 0

# Path to SQS processor Lambda deployment package - ** REQUIRED if create_separate_sqs_processor=true **
sqs_processor_source_path = "./path/to/your/sqs-processor-lambda.zip"

# SQS processor Lambda Environment Variables
sqs_processor_environment_variables = {
  LOG_LEVEL = "INFO"
}

# Other Optional Settings (defaults are generally fine for examples)
# sns_kms_key_arn                   = "arn:aws:kms:us-east-1:123456789012:key/..."
# sns_dlq_arn                       = "arn:aws:sqs:us-east-1:123456789012:my-sns-dlq"
# sns_raw_message_delivery          = false
# sns_filter_policy                 = "{\"attribute_name\": [\"value1\"]}"
# sns_filter_policy_scope           = "MessageAttributes"
# sqs_kms_key_arn                   = "arn:aws:kms:us-east-1:123456789012:key/..."
# lambda_layers                     = ["arn:aws:lambda:us-east-1:123456789012:layer:my-layer:1"]
# lambda_reserved_concurrency       = -1
# sqs_processor_layers              = ["arn:aws:lambda:us-east-1:123456789012:layer:my-layer:1"]
# sqs_processor_reserved_concurrency = -1
# sqs_processor_publish_version     = false
# sqs_processor_enabled             = true 