/**
 * # API Gateway with Direct DynamoDB Integration
 *
 * This configuration creates an API Gateway with direct integration to DynamoDB
 * using Velocity Template Language (VTL) mapping templates.
 */

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "API-Direct-DynamoDB"
      Terraform   = "true"
    }
  }
}

module "api_gateway_dynamodb" {
  source = "./patterns/api-gateway-direct-dynamodb"

  aws_region = "us-east-1"

  # API Gateway configuration
  api_name        = "products-api"
  api_description = "Products API with direct DynamoDB integration"
  endpoint_types  = ["REGIONAL"]
  stage_name      = "dev"
  
  # CORS configuration
  enable_cors       = true
  cors_allow_origin = "*"
  
  # DynamoDB configuration
  dynamodb_table_name = "products-table"
  dynamodb_hash_key   = "id"
  dynamodb_range_key  = "category"
  
  dynamodb_attributes = [
    {
      name = "price"
      type = "N"
    },
    {
      name = "name"
      type = "S"
    },
    {
      name = "category"
      type = "S"
    }
  ]
  
  dynamodb_global_secondary_indexes = [
    {
      name               = "CategoryIndex"
      hash_key           = "category"
      range_key          = "price"
      write_capacity     = null
      read_capacity      = null
      projection_type    = "ALL"
      non_key_attributes = null
    }
  ]
  
  dynamodb_enable_encryption             = true
  dynamodb_enable_point_in_time_recovery = true
  
  # API endpoints configuration
  api_endpoints = {
    "products" = {
      collection_operation = "GET"
      item_operation       = "GET"
      query_type           = "Scan"
    },
    "products-by-category" = {
      collection_operation = "GET"
      query_type           = "Query"
      index_name           = "CategoryIndex"
      key_condition        = "category = :category"
      expression_names     = {}
      expression_values    = {
        ":category" = "$input.params('category')"
      }
    },
    "product" = {
      collection_operation = "POST"
      item_operation       = "PUT"
      auto_generate_id     = false
    }
  }
  
  tags = {
    Service = "ProductsCatalog"
  }
}
 