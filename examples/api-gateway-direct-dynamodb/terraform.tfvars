# --- General AWS Configuration --- #
# Specify the AWS region where resources will be created.
aws_region = "us-east-1"

# Default tags applied to all resources created by this example.
# Helps with organization and cost tracking.
default_tags = {
  Environment = "dev"
  Project     = "ExampleItemsAPI"
  Terraform   = "true"
}

# Specific tags for resources in this example.
tags = {
  Owner = "example-team"
}

# --- API Gateway Configuration --- #
# The name for your API Gateway.
api_name = "example-items-api"
# A description for your API Gateway.
api_description = "Example Items API with direct DynamoDB integration"
# Endpoint type. REGIONAL is common for general use.
endpoint_types = ["REGIONAL"]
# Name of the deployment stage (e.g., v1, dev, prod).
stage_name = "v1"

# --- API Gateway Custom Domain (Optional) --- #
# Set to true to enable a custom domain.
create_custom_domain = false
# Your custom domain name (e.g., api.example.com).
# domain_name = "api.example.com"
# ARN of the ACM certificate (must be in the same region as API Gateway) validating the domain.
# certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/YOUR-CERT-ARN"
# Base path mapping for the custom domain (e.g., "items").
# base_path = "items"

# --- API Gateway Authorization & Security --- #
# Authorization type (NONE, AWS_IAM, COGNITO_USER_POOLS, etc.).
api_authorization = "NONE"
# Set to true if API methods should require an API key.
require_api_key = false
# Optional WAF Web ACL ARN to protect the API stage.
# waf_acl_arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/YOUR-WAF-ACL-ID"

# --- API Gateway CORS (Cross-Origin Resource Sharing) --- #
# Enable CORS if the API will be called from web browsers hosted on different domains.
enable_cors = true
# Allowed origin for CORS requests. Use '*' for any origin (less secure), or specify your frontend URL (e.g., "https://my.frontend.com").
cors_allow_origin = "*"

# --- DynamoDB Table Configuration --- #
# Name for the DynamoDB table.
dynamodb_table_name = "example-items-table"
# Billing mode: PAY_PER_REQUEST (on-demand) or PROVISIONED.
dynamodb_billing_mode = "PAY_PER_REQUEST"
# Read/Write capacity units (only used if billing_mode is PROVISIONED).
# dynamodb_read_capacity  = 5
# dynamodb_write_capacity = 5

# Primary Key definition:
# Name of the hash (partition) key attribute.
dynamodb_hash_key = "itemID"
# Optional name of the range (sort) key attribute.
# dynamodb_range_key = "timestamp"

# Define all attributes used in the primary key, LSIs, and GSIs.
# Type must be S (String), N (Number), or B (Binary).
dynamodb_attributes = [
  {
    name = "itemID" # Hash key
    type = "S"
  },
  # Add other attributes used as keys in indexes, e.g.:
  # {
  #   name = "status"
  #   type = "S"
  # },
  # {
  #   name = "createdAt"
  #   type = "N"
  # }
]

# Enable server-side encryption (recommended).
dynamodb_enable_encryption = true
# Optional: ARN of a KMS key for encryption (uses AWS-managed key if null).
# dynamodb_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/YOUR-KMS-KEY-ARN"

# Enable Point-in-Time Recovery (PITR) for backups (recommended for production).
dynamodb_enable_point_in_time_recovery = false
# Optional: Specify an attribute name (must be Number type) for DynamoDB TTL.
# dynamodb_ttl_attribute_name = "expiresAt"

# --- DynamoDB Secondary Indexes (Optional) --- #
# Define Global Secondary Indexes (GSIs).
dynamodb_global_secondary_indexes = [
  # Example GSI:
  # {
  #   name            = "StatusIndex"      # Name of the index
  #   hash_key        = "status"           # Hash key of the index
  #   range_key       = "createdAt"        # Optional range key of the index
  #   projection_type = "ALL"              # What attributes to project (ALL, KEYS_ONLY, INCLUDE)
  #   # non_key_attributes = ["attr1", "attr2"] # Required if projection_type is INCLUDE
  #   # read_capacity   = 5                  # Required if table billing_mode is PROVISIONED
  #   # write_capacity  = 5                  # Required if table billing_mode is PROVISIONED
  # }
]

# Define Local Secondary Indexes (LSIs).
# Note: LSIs must use the same hash key as the table, but a different range key.
# They must be defined when the table is created.
dynamodb_local_secondary_indexes = [
  # Example LSI:
  # {
  #   name            = "ItemIDTimestampIndex"
  #   range_key       = "timestamp"        # Must be different from table's range key (if any)
  #   projection_type = "KEYS_ONLY"      # What attributes to project (ALL, KEYS_ONLY, INCLUDE)
  #   # non_key_attributes = ["attr1"]    # Required if projection_type is INCLUDE
  # }
]

# --- API Endpoint Integrations --- #
# Defines the API resources and methods and maps them to DynamoDB actions.
# The key of the map ("items" and "item" below) defines the resource path segment.
# The `collection_name` variable defines the base path (e.g., /v1/items).

# The name of the base resource path (e.g., /items)
collection_name = "items"

api_endpoints = {
  # Corresponds to /items
  "collection" = {
    # GET /items -> Scan or Query the table
    collection_operation = "GET"
    query_type           = "Scan" # Use "Query" to use key_condition (requires index if not primary key)
    # index_name        = "StatusIndex" # Optional: Specify GSI/LSI name for Query/Scan
    # key_condition     = "status = :statusVal" # Optional: Query condition (use with query_type="Query")
    # filter_expression = "attribute_exists(description)" # Optional: Filter results after Scan/Query
    # expression_names  = { "#st" = "status" } # Optional: Aliases for attribute names
    # expression_values = { ":statusVal" = { "S" = "active" } } # Optional: Values for expressions
    limit = 10 # Optional: Limit the number of items returned

    # POST /items -> PutItem into the table
    # collection_operation = "POST" # Uncomment to enable POST on the collection
    # auto_generate_id   = true # If true, the module generates a UUID for the hash key ('itemID' in this example)
  },

  # Corresponds to /items/{itemID}
  "item" = {
    # GET /items/{itemID} -> GetItem from the table
    item_operation = "GET"

    # PUT /items/{itemID} -> UpdateItem in the table
    # item_operation    = "PUT" # Uncomment to enable PUT on the item resource
    # update_expression = "SET #d = :desc, #u = :updated" # Required for PUT
    # expression_names  = { "#d" = "description", "#u" = "updatedAt" } # Optional
    # expression_values = { ":desc" = { "S" = "$input.path('$.description')" }, ":updated" = { "N" = "$context.requestTimeEpoch" } } # Required for PUT
    # condition_expression = "attribute_exists(itemID)" # Optional: Condition for the update

    # DELETE /items/{itemID} -> DeleteItem from the table
    # item_operation = "DELETE" # Uncomment to enable DELETE on the item resource
    # condition_expression = "attribute_exists(itemID)" # Optional: Condition for the delete
  }
}

# --- API Gateway Usage Plan (Optional) --- #
# Define throttling and quota limits for API keys associated with this API.
# Requires `require_api_key = true`.
# usage_plan_quota_limit  = 5000
# usage_plan_quota_period = "MONTH"
# usage_plan_throttle_rate  = 10  # requests per second
# usage_plan_throttle_burst = 5   # concurrent requests 