/**
 * # API Gateway with Microservices and DynamoDB Pattern
 *
 * This pattern creates an API Gateway with Lambda microservices and a DynamoDB table
 * for data persistence. It also includes a custom domain name and appropriate IAM permissions.
 */

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

# Create DynamoDB table
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

  # Global Secondary Indexes
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

  # Stream
  dynamic "stream_enabled" {
    for_each = var.dynamodb_stream_enabled ? [1] : []
    content {
      stream_enabled   = true
      stream_view_type = var.dynamodb_stream_view_type
    }
  }

  tags = var.tags
}

# Create Lambda functions for microservices
module "lambda_functions" {
  source   = "../../modules/lambda"
  for_each = var.lambda_functions

  function_name = each.value.name
  description   = each.value.description
  handler       = each.value.handler
  runtime       = each.value.runtime
  timeout       = lookup(each.value, "timeout", 30)
  memory_size   = lookup(each.value, "memory_size", 128)
  
  # Source code
  filename         = each.value.filename
  source_code_hash = each.value.source_code_hash
  
  # Environment variables
  environment_variables = merge(
    {
      DYNAMODB_TABLE = aws_dynamodb_table.this.name
    },
    lookup(each.value, "environment_variables", {})
  )
  
  # Lambda function permissions for DynamoDB
  create_lambda_function_policy = true
  lambda_function_policy = jsonencode({
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
  
  # CloudWatch logs
  log_retention_in_days = lookup(each.value, "log_retention_in_days", 14)
  
  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# Create API Gateway resources and methods for each Lambda function
resource "aws_api_gateway_resource" "microservices" {
  for_each = var.lambda_functions

  rest_api_id = module.api_gateway.rest_api_id
  parent_id   = module.api_gateway.root_resource_id
  path_part   = each.key
}

# Create API Gateway methods and integrations
resource "aws_api_gateway_method" "microservices" {
  for_each = var.lambda_functions

  rest_api_id   = module.api_gateway.rest_api_id
  resource_id   = aws_api_gateway_resource.microservices[each.key].id
  http_method   = "ANY"
  authorization_type = var.api_authorization_type
  authorizer_id = var.api_authorizer_id

  # Request parameters (if needed)
  request_parameters = var.request_parameters
}

resource "aws_api_gateway_integration" "microservices" {
  for_each = var.lambda_functions

  rest_api_id             = module.api_gateway.rest_api_id
  resource_id             = aws_api_gateway_resource.microservices[each.key].id
  http_method             = aws_api_gateway_method.microservices[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_functions[each.key].function_invoke_arn
}

# Create Lambda permissions for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  for_each = var.lambda_functions

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_functions[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.rest_api_execution_arn}/*/${aws_api_gateway_method.microservices[each.key].http_method}/${each.key}"
}

# Enable CORS for the API resources
resource "aws_api_gateway_method" "options" {
  for_each = var.enable_cors ? var.lambda_functions : {}

  rest_api_id   = module.api_gateway.rest_api_id
  resource_id   = aws_api_gateway_resource.microservices[each.key].id
  http_method   = "OPTIONS"
  authorization_type = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  for_each = var.enable_cors ? var.lambda_functions : {}

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.microservices[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  for_each = var.enable_cors ? var.lambda_functions : {}

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.microservices[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  for_each = var.enable_cors ? var.lambda_functions : {}

  rest_api_id = module.api_gateway.rest_api_id
  resource_id = aws_api_gateway_resource.microservices[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = aws_api_gateway_method_response.options[each.key].status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET,PUT,POST,DELETE,PATCH'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allow_origin}'"
  }
} 