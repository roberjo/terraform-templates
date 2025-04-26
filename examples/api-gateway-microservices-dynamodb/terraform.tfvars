# --- General AWS Configuration --- #
# Specify the AWS region where resources will be created.
aws_region = "us-east-1"

# Default tags applied to all resources created by this example.
# Helps with organization and cost tracking.
default_tags = {
  Environment = "dev"
  Project     = "ExampleMicroservicesAPI"
  Terraform   = "true"
}

# Specific tags for resources in this example.
tags = {
  Owner = "example-team"
}

# --- API Gateway Configuration --- #
# The name for your API Gateway.
api_name = "example-microservices-api"
# A description for your API Gateway.
api_description = "Example API Gateway using Microservices Pattern"
# Endpoint type. REGIONAL is common for general use.
endpoint_types = ["REGIONAL"]
# Name of the deployment stage (e.g., v1, dev, prod).
stage_name = "v1"

# --- API Gateway Custom Domain (Optional) --- #
# Set to true to enable a custom domain.
create_custom_domain = false
# Your custom domain name (e.g., api.example.com).
# domain_name = "api.example-micro.com"
# ARN of the ACM certificate (must be in the same region as API Gateway) validating the domain.
# certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/YOUR-CERT-ARN"
# Base path mapping for the custom domain (e.g., "api").
# base_path = "api"

# --- API Gateway Security & Logging --- #
# Authorization type (NONE, AWS_IAM, COGNITO_USER_POOLS, etc.).
api_authorization_type = "NONE"
# Optional Authorizer ID if using CUSTOM or COGNITO_USER_POOLS.
# api_authorizer_id = "your-authorizer-id"
# Optional WAF Web ACL ARN to protect the API stage.
# waf_acl_arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/YOUR-WAF-ACL-ID"
# Optional IAM Role ARN for CloudWatch logging.
# cloudwatch_role_arn = "arn:aws:iam::123456789012:role/api-gw-cloudwatch-role"
# Optional: Define required request parameters, e.g., {"method.request.header.Authorization" = true}
request_parameters = {}

# --- API Gateway CORS --- #
# Enable CORS if the API will be called from web browsers on different domains.
enable_cors = true
# Allowed origin for CORS. Use '*' for any origin (less secure) or specify your frontend URL.
cors_allow_origin = "*"

# --- DynamoDB Table Configuration --- #
# Name for the DynamoDB table.
dynamodb_table_name = "example-microservices-data"
# Billing mode: PAY_PER_REQUEST or PROVISIONED.
dynamodb_billing_mode = "PAY_PER_REQUEST"
# dynamodb_read_capacity  = 5  # Required if billing_mode = PROVISIONED
# dynamodb_write_capacity = 5 # Required if billing_mode = PROVISIONED

# Primary Key definition:
# Name of the hash (partition) key attribute.
dynamodb_hash_key = "pk"
# Type of the hash key attribute (S, N, or B).
dynamodb_hash_key_type = "S"
# Optional name of the range (sort) key attribute.
dynamodb_range_key = "sk"
# Optional type of the range key attribute (S, N, or B).
dynamodb_range_key_type = "S"

# Define ALL attributes used in the primary key, LSIs, and GSIs.
dynamodb_attributes = [
  { name = "pk", type = "S" },
  { name = "sk", type = "S" },
  # Add other attributes used as keys in indexes if needed:
  # { name = "gsi1pk", type = "S" },
  # { name = "gsi1sk", type = "N" },
]

# Enable server-side encryption (recommended).
dynamodb_enable_encryption = true
# Optional: ARN of a KMS key for encryption (uses AWS-managed key if null).
# dynamodb_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/YOUR-KMS-KEY-ARN"
# Enable Point-in-Time Recovery (PITR) for backups (recommended for production).
dynamodb_enable_point_in_time_recovery = false
# Optional: Specify an attribute name (Number type) for DynamoDB TTL.
# dynamodb_ttl_attribute_name = "expiresAt"
# Optional: Enable DynamoDB Streams.
dynamodb_stream_enabled = false
# dynamodb_stream_view_type = "NEW_AND_OLD_IMAGES"

# --- DynamoDB Secondary Indexes (Optional) --- #
# Define Global Secondary Indexes (GSIs).
dynamodb_global_secondary_indexes = [
  # Example GSI:
  # {
  #   name            = "GSI1"             # Name of the index
  #   hash_key        = "gsi1pk"           # Hash key attribute name for the index
  #   range_key       = "gsi1sk"           # Optional range key attribute name
  #   projection_type = "ALL"              # What attributes to project (ALL, KEYS_ONLY, INCLUDE)
  #   # non_key_attributes = ["attr1"]    # Required if projection_type is INCLUDE
  #   # read_capacity   = 5                # Required if table billing_mode is PROVISIONED
  #   # write_capacity  = 5                # Required if table billing_mode is PROVISIONED
  # }
]

# Define Local Secondary Indexes (LSIs).
dynamodb_local_secondary_indexes = []

# --- Lambda Functions (Microservices) Configuration --- #
# Define each microservice as an entry in this map.
# The map key (e.g., "users", "orders") determines the API Gateway base path for that service (e.g., /v1/users, /v1/orders).
lambda_functions = {
  # Example "users" microservice
  "users" = {
    # Required: Lambda function name
    name = "example-users-service"
    # Required: Lambda handler (filename.handler_function)
    handler = "index.handler"
    # Required: Lambda runtime (e.g., nodejs18.x, python3.9)
    runtime = "nodejs18.x"
    # Required: Path to the Lambda deployment package (.zip file)
    # ** REPLACE THIS PLACEHOLDER PATH **
    filename = "./path/to/your/users-lambda.zip"
    # Optional: Precompute the hash for change detection (recommended if using local file)
    # source_code_hash = filebase64sha256("./path/to/your/users-lambda.zip")

    # Optional: S3 location for Lambda code (alternative to filename)
    # s3_bucket = "your-lambda-bucket"
    # s3_key    = "path/to/users-lambda.zip"
    # s3_object_version = "version-id" # Optional: specific version

    # Optional: Lambda function description
    description = "Handles user-related requests"
    # Optional: Timeout in seconds (default: 3)
    timeout = 10
    # Optional: Memory size in MB (default: 128)
    memory_size = 128
    # Optional: Environment variables for the Lambda function
    environment_variables = {
      LOG_LEVEL      = "INFO"
      DYNAMODB_TABLE = "example-microservices-data" # Pass table name to Lambda
    }
    # Optional: List of Lambda layer ARNs
    # layers = ["arn:aws:lambda:us-east-1:123456789012:layer:my-layer:1"]
    # Optional: VPC configuration
    # subnet_ids = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"]
    # security_group_ids = ["sg-zzzzzzzz"]
    # Optional: X-Ray tracing mode (Active or PassThrough)
    # tracing_mode = "Active"
    # Optional: Dead-letter queue ARN
    # dlq_arn = "arn:aws:sqs:us-east-1:123456789012:my-lambda-dlq"
  },

  # Example "orders" microservice
  "orders" = {
    name    = "example-orders-service"
    handler = "main.lambda_handler"
    runtime = "python3.9"
    # ** REPLACE THIS PLACEHOLDER PATH **
    filename = "./path/to/your/orders-lambda.zip"
    # source_code_hash = filebase64sha256("./path/to/your/orders-lambda.zip")
    timeout = 15
    memory_size = 256
    environment_variables = {
      DYNAMODB_TABLE = "example-microservices-data"
      REGION         = "us-east-1"
    }
  }

  # Add more microservices here following the same structure
} 