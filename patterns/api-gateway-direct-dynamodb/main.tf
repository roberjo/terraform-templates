/**
 * # API Gateway with Direct DynamoDB Integration Pattern
 *
 * This pattern creates an API Gateway REST API with direct integration to DynamoDB using
 * Velocity Template Language (VTL) mapping templates. It includes custom domain support,
 * optimized table design, and appropriate IAM permissions.
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
  
  tags = var.tags
}

# Create DynamoDB table with GSIs optimized for direct API access
resource "aws_dynamodb_table" "this" {
  name           = var.dynamodb_table_name
  billing_mode   = var.dynamodb_billing_mode
  read_capacity  = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_read_capacity : null
  write_capacity = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_write_capacity : null
  hash_key       = var.dynamodb_hash_key
  range_key      = var.dynamodb_range_key

  # Primary key attributes
  attribute {
    name = var.dynamodb_hash_key
    type = var.dynamodb_hash_key_type
  }

  dynamic "attribute" {
    for_each = var.dynamodb_range_key != null ? [1] : []
    content {
      name = var.dynamodb_range_key
      type = var.dynamodb_range_key_type
    }
  }

  # Additional attributes for GSIs and LSIs
  dynamic "attribute" {
    for_each = var.dynamodb_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global Secondary Indexes for flexible querying without Lambda
  dynamic "global_secondary_index" {
    for_each = var.dynamodb_global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      read_capacity      = var.dynamodb_billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", var.dynamodb_read_capacity) : null
      write_capacity     = var.dynamodb_billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", var.dynamodb_write_capacity) : null
    }
  }

  # Local Secondary Indexes
  dynamic "local_secondary_index" {
    for_each = var.dynamodb_local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  # Server-side encryption
  server_side_encryption {
    enabled     = var.dynamodb_enable_encryption
    kms_key_arn = var.dynamodb_kms_key_arn
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.dynamodb_enable_point_in_time_recovery
  }

  # TTL
  dynamic "ttl" {
    for_each = var.dynamodb_ttl_attribute_name != null ? [1] : []
    content {
      attribute_name = var.dynamodb_ttl_attribute_name
      enabled        = true
    }
  }

  tags = var.tags
}

# IAM role for API Gateway to access DynamoDB
resource "aws_iam_role" "api_gateway_dynamodb" {
  name = "${var.api_name}-dynamodb-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
  
  tags = var.tags
}

# IAM policy for API Gateway to access DynamoDB
resource "aws_iam_policy" "api_gateway_dynamodb" {
  name        = "${var.api_name}-dynamodb-policy"
  description = "Policy for API Gateway to access DynamoDB table ${var.dynamodb_table_name}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          aws_dynamodb_table.this.arn,
          "${aws_dynamodb_table.this.arn}/index/*"
        ]
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "api_gateway_dynamodb" {
  role       = aws_iam_role.api_gateway_dynamodb.name
  policy_arn = aws_iam_policy.api_gateway_dynamodb.arn
}

# Create API Gateway resources for each endpoint defined in the configuration
resource "aws_api_gateway_resource" "endpoint" {
  for_each = var.api_endpoints

  rest_api_id = module.api_gateway.rest_api_id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = each.key
}

# Create API resources for item-specific operations (GET, PUT, DELETE)
resource "aws_api_gateway_resource" "item" {
  for_each = { for k, v in var.api_endpoints : k => v if contains(["GET", "PUT", "DELETE"], v.item_operation) }

  rest_api_id = module.api_gateway.rest_api_id
  parent_id   = aws_api_gateway_resource.endpoint[each.key].id
  path_part   = "{id}"
}

# Create methods for collection-level operations (GET, POST)
resource "aws_api_gateway_method" "collection" {
  for_each = { for k, v in var.api_endpoints : k => v if contains(["GET", "POST"], v.collection_operation) }

  rest_api_id   = module.api_gateway.rest_api_id
  resource_id   = aws_api_gateway_resource.endpoint[each.key].id
  http_method   = each.value.collection_operation
  authorization_type = var.api_authorization_type
  authorizer_id = var.api_authorizer_id
  api_key_required = var.require_api_key

  request_parameters = {
    "method.request.header.Content-Type" = true
  }
}

# Create methods for item-level operations (GET, PUT, DELETE)
resource "aws_api_gateway_method" "item" {
  for_each = { for k, v in var.api_endpoints : k => v if contains(["GET", "PUT", "DELETE"], v.item_operation) }

  rest_api_id   = module.api_gateway.rest_api_id
  resource_id   = aws_api_gateway_resource.item[each.key].id
  http_method   = each.value.item_operation
  authorization_type = var.api_authorization_type
  authorizer_id = var.api_authorizer_id
  api_key_required = var.require_api_key

  request_parameters = {
    "method.request.path.id" = true
    "method.request.header.Content-Type" = each.value.item_operation == "PUT" ? true : false
  }
}

# Integration for collection GET operation (Scan or Query)
resource "aws_api_gateway_integration" "collection_get" {
  for_each = { for k, v in var.api_endpoints : k => v if v.collection_operation == "GET" }

  rest_api_id             = module.api_gateway.rest_api_id
  resource_id             = aws_api_gateway_resource.endpoint[each.key].id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/${each.value.query_type}" # Scan or Query
  credentials             = aws_iam_role.api_gateway_dynamodb.arn

  # Request mapping template for Scan or Query operation
  request_templates = {
    "application/json" = templatefile("${path.module}/templates/${lower(each.value.query_type)}_request.vtl", {
      table_name = aws_dynamodb_table.this.name
      index_name = each.value.index_name
      key_condition = lookup(each.value, "key_condition", null)
      expression_names = lookup(each.value, "expression_names", {})
      expression_values = lookup(each.value, "expression_values", {})
      filter_expression = lookup(each.value, "filter_expression", null)
      scan_index_forward = lookup(each.value, "scan_index_forward", true)
      limit = lookup(each.value, "limit", 20)
    })
  }
}

# Integration for collection POST operation (PutItem)
resource "aws_api_gateway_integration" "collection_post" {
  for_each = { for k, v in var.api_endpoints : k => v if v.collection_operation == "POST" }

  rest_api_id             = module.api_gateway.rest_api_id
  resource_id             = aws_api_gateway_resource.endpoint[each.key].id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/PutItem"
  credentials             = aws_iam_role.api_gateway_dynamodb.arn

  # Request mapping template for PutItem operation
  request_templates = {
    "application/json" = templatefile("${path.module}/templates/put_item_request.vtl", {
      table_name = aws_dynamodb_table.this.name
      hash_key = var.dynamodb_hash_key
      range_key = var.dynamodb_range_key
      auto_generate_id = each.value.auto_generate_id
    })
  }
}

# Integration for item GET operation (GetItem)
resource "aws_api_gateway_integration" "item_get" {
  for_each = { for k, v in var.api_endpoints : k => v if v.item_operation == "GET" }

  rest_api_id             = module.api_gateway.rest_api_id
  resource_id             = aws_api_gateway_resource.item[each.key].id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/GetItem"
  credentials             = aws_iam_role.api_gateway_dynamodb.arn

  # Request mapping template for GetItem operation
  request_templates = {
    "application/json" = templatefile("${path.module}/templates/get_item_request.vtl", {
      table_name = aws_dynamodb_table.this.name
      hash_key = var.dynamodb_hash_key
      range_key = var.dynamodb_range_key
      range_key_value = lookup(each.value, "range_key_value", "")
    })
  }
}

# Integration for item PUT operation (UpdateItem)
resource "aws_api_gateway_integration" "item_put" {
  for_each = { for k, v in var.api_endpoints : k => v if v.item_operation == "PUT" }

  rest_api_id             = module.api_gateway.rest_api_id
  resource_id             = aws_api_gateway_resource.item[each.key].id
  http_method             = "PUT"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/UpdateItem"
  credentials             = aws_iam_role.api_gateway_dynamodb.arn

  # Request mapping template for UpdateItem operation
  request_templates = {
    "application/json" = templatefile("${path.module}/templates/update_item_request.vtl", {
      table_name = aws_dynamodb_table.this.name
      hash_key = var.dynamodb_hash_key
      range_key = var.dynamodb_range_key
      range_key_value = lookup(each.value, "range_key_value", "")
      update_expression = lookup(each.value, "update_expression", "")
      condition_expression = lookup(each.value, "condition_expression", "")
    })
  }
}

# Integration for item DELETE operation (DeleteItem)
resource "aws_api_gateway_integration" "item_delete" {
  for_each = { for k, v in var.api_endpoints : k => v if v.item_operation == "DELETE" }

  rest_api_id             = module.api_gateway.rest_api_id
  resource_id             = aws_api_gateway_resource.item[each.key].id
  http_method             = "DELETE"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:dynamodb:action/DeleteItem"
  credentials             = aws_iam_role.api_gateway_dynamodb.arn

  # Request mapping template for DeleteItem operation
  request_templates = {
    "application/json" = templatefile("${path.module}/templates/delete_item_request.vtl", {
      table_name = aws_dynamodb_table.this.name
      hash_key = var.dynamodb_hash_key
      range_key = var.dynamodb_range_key
      range_key_value = lookup(each.value, "range_key_value", "")
      condition_expression = lookup(each.value, "condition_expression", "")
    })
  }
}

# Integration responses for collection GET
resource "aws_api_gateway_integration_response" "collection_get" {
  for_each = { for k, v in var.api_endpoints : k => v if v.collection_operation == "GET" }

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.endpoint[each.key].id
  http_method = aws_api_gateway_method.collection[each.key].http_method
  status_code = "200"

  # Response mapping template
  response_templates = {
    "application/json" = templatefile("${path.module}/templates/${lower(each.value.query_type)}_response.vtl", {})
  }

  depends_on = [aws_api_gateway_integration.collection_get, aws_api_gateway_method_response.collection_200]
}

# Integration responses for collection POST
resource "aws_api_gateway_integration_response" "collection_post" {
  for_each = { for k, v in var.api_endpoints : k => v if v.collection_operation == "POST" }

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.endpoint[each.key].id
  http_method = aws_api_gateway_method.collection[each.key].http_method
  status_code = "201"

  # Response mapping template
  response_templates = {
    "application/json" = templatefile("${path.module}/templates/put_item_response.vtl", {})
  }

  depends_on = [aws_api_gateway_integration.collection_post, aws_api_gateway_method_response.collection_201]
}

# Integration responses for item GET
resource "aws_api_gateway_integration_response" "item_get" {
  for_each = { for k, v in var.api_endpoints : k => v if v.item_operation == "GET" }

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.item[each.key].id
  http_method = aws_api_gateway_method.item[each.key].http_method
  status_code = "200"

  # Response mapping template
  response_templates = {
    "application/json" = templatefile("${path.module}/templates/get_item_response.vtl", {})
  }

  depends_on = [aws_api_gateway_integration.item_get, aws_api_gateway_method_response.item_200]
}

# Integration responses for item PUT
resource "aws_api_gateway_integration_response" "item_put" {
  for_each = { for k, v in var.api_endpoints : k => v if v.item_operation == "PUT" }

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.item[each.key].id
  http_method = aws_api_gateway_method.item[each.key].http_method
  status_code = "200"

  # Response mapping template
  response_templates = {
    "application/json" = templatefile("${path.module}/templates/update_item_response.vtl", {})
  }

  depends_on = [aws_api_gateway_integration.item_put, aws_api_gateway_method_response.item_200]
}

# Integration responses for item DELETE
resource "aws_api_gateway_integration_response" "item_delete" {
  for_each = { for k, v in var.api_endpoints : k => v if v.item_operation == "DELETE" }

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.item[each.key].id
  http_method = aws_api_gateway_method.item[each.key].http_method
  status_code = "200"

  # Response mapping template
  response_templates = {
    "application/json" = templatefile("${path.module}/templates/delete_item_response.vtl", {})
  }

  depends_on = [aws_api_gateway_integration.item_delete, aws_api_gateway_method_response.item_200]
}

# Method responses for collection endpoints
resource "aws_api_gateway_method_response" "collection_200" {
  for_each = { for k, v in var.api_endpoints : k => v if v.collection_operation == "GET" }

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.endpoint[each.key].id
  http_method = aws_api_gateway_method.collection[each.key].http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = var.enable_cors
    "method.response.header.Access-Control-Allow-Methods" = var.enable_cors
    "method.response.header.Access-Control-Allow-Headers" = var.enable_cors
  }
}

resource "aws_api_gateway_method_response" "collection_201" {
  for_each = { for k, v in var.api_endpoints : k => v if v.collection_operation == "POST" }

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.endpoint[each.key].id
  http_method = aws_api_gateway_method.collection[each.key].http_method
  status_code = "201"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = var.enable_cors
    "method.response.header.Access-Control-Allow-Methods" = var.enable_cors
    "method.response.header.Access-Control-Allow-Headers" = var.enable_cors
  }
}

# Method responses for item endpoints
resource "aws_api_gateway_method_response" "item_200" {
  for_each = { for k, v in var.api_endpoints : k => v if contains(["GET", "PUT", "DELETE"], v.item_operation) }

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.item[each.key].id
  http_method = aws_api_gateway_method.item[each.key].http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Content-Type" = true
    "method.response.header.Access-Control-Allow-Origin" = var.enable_cors
    "method.response.header.Access-Control-Allow-Methods" = var.enable_cors
    "method.response.header.Access-Control-Allow-Headers" = var.enable_cors
  }
}

# CORS support for all endpoints
resource "aws_api_gateway_method" "options_collection" {
  for_each = var.enable_cors ? var.api_endpoints : {}

  rest_api_id   = module.api_gateway.rest_api_id
  resource_id   = aws_api_gateway_resource.endpoint[each.key].id
  http_method   = "OPTIONS"
  authorization_type = "NONE"
}

resource "aws_api_gateway_method" "options_item" {
  for_each = var.enable_cors ? { for k, v in var.api_endpoints : k => v if contains(["GET", "PUT", "DELETE"], v.item_operation) } : {}

  rest_api_id   = module.api_gateway.rest_api_id
  resource_id   = aws_api_gateway_resource.item[each.key].id
  http_method   = "OPTIONS"
  authorization_type = "NONE"
}

resource "aws_api_gateway_integration" "options_collection" {
  for_each = var.enable_cors ? var.api_endpoints : {}

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.endpoint[each.key].id
  http_method = aws_api_gateway_method.options_collection[each.key].http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "options_item" {
  for_each = var.enable_cors ? { for k, v in var.api_endpoints : k => v if contains(["GET", "PUT", "DELETE"], v.item_operation) } : {}

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.item[each.key].id
  http_method = aws_api_gateway_method.options_item[each.key].http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# CORS response methods for OPTIONS
resource "aws_api_gateway_method_response" "options_collection_200" {
  for_each = var.enable_cors ? var.api_endpoints : {}

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.endpoint[each.key].id
  http_method = aws_api_gateway_method.options_collection[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "options_item_200" {
  for_each = var.enable_cors ? { for k, v in var.api_endpoints : k => v if contains(["GET", "PUT", "DELETE"], v.item_operation) } : {}

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.item[each.key].id
  http_method = aws_api_gateway_method.options_item[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "options_collection" {
  for_each = var.enable_cors ? var.api_endpoints : {}

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.endpoint[each.key].id
  http_method = aws_api_gateway_method.options_collection[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allow_origin}'"
  }
}

resource "aws_api_gateway_integration_response" "options_item" {
  for_each = var.enable_cors ? { for k, v in var.api_endpoints : k => v if contains(["GET", "PUT", "DELETE"], v.item_operation) } : {}

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.item[each.key].id
  http_method = aws_api_gateway_method.options_item[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allow_origin}'"
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "main" {
  depends_on = [
    aws_api_gateway_integration.get_collection,
    aws_api_gateway_integration.post_collection,
    aws_api_gateway_integration.get_item,
    aws_api_gateway_integration.delete_item
  ]

  rest_api_id = module.api_gateway.rest_api_id
  stage_name  = var.stage_name

  lifecycle {
    create_before_destroy = true
  }
}

# API Key (if required)
resource "aws_api_gateway_api_key" "main" {
  count = var.require_api_key ? 1 : 0
  
  name        = "${var.api_name}-key"
  description = "API Key for ${var.api_name}"
  
  enabled = true
}

resource "aws_api_gateway_usage_plan" "main" {
  count = var.require_api_key ? 1 : 0
  
  name         = "${var.api_name}-usage-plan"
  description  = "Usage plan for ${var.api_name}"
  
  api_stages {
    api_id = module.api_gateway.rest_api_id
    stage  = aws_api_gateway_deployment.main.stage_name
  }
  
  quota_settings {
    limit  = var.usage_plan_quota_limit
    period = var.usage_plan_quota_period
  }
  
  throttle_settings {
    burst_limit = var.usage_plan_throttle_burst
    rate_limit  = var.usage_plan_throttle_rate
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  count = var.require_api_key ? 1 : 0
  
  key_id        = aws_api_gateway_api_key.main[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main[0].id
} 