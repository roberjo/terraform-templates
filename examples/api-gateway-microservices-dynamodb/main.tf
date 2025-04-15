/**
 * # API Gateway with Microservices and DynamoDB Example
 *
 * This example demonstrates how to use the API Gateway with Microservices and DynamoDB pattern
 * to create a complete serverless API with multiple microservices.
 */

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment = "Example"
      Project     = "API-Microservices"
      Terraform   = "true"
    }
  }
}

# ACM Certificate for custom domain (if needed)
resource "aws_acm_certificate" "api" {
  count = var.create_custom_domain ? 1 : 0
  
  domain_name       = var.domain_name
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "api-certificate"
  }
}

# IAM Role for CloudWatch logging
resource "aws_iam_role" "cloudwatch" {
  name = "api-gateway-cloudwatch-role"
  
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
  
  tags = {
    Name = "api-gateway-cloudwatch-role"
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "api-gateway-cloudwatch-policy"
  role = aws_iam_role.cloudwatch.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# KMS Key for DynamoDB encryption (optional)
resource "aws_kms_key" "dynamodb" {
  count = var.use_customer_managed_key ? 1 : 0
  
  description             = "KMS key for DynamoDB encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  
  tags = {
    Name = "dynamodb-encryption-key"
  }
}

# WAF Web ACL (optional)
resource "aws_wafv2_web_acl" "api" {
  count = var.create_waf_acl ? 1 : 0
  
  name        = "api-protection"
  description = "WAF protection for API Gateway"
  scope       = "REGIONAL"
  
  default_action {
    allow {}
  }
  
  # AWS Core rule set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    
    override_action {
      none {}
    }
    
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  
  # Rate limiting rule
  rule {
    name     = "RateLimitRule"
    priority = 2
    
    action {
      block {}
    }
    
    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }
  
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "api-protection"
    sampled_requests_enabled   = true
  }
  
  tags = {
    Name = "api-protection"
  }
}

# Create the API with microservices
module "api_microservices" {
  source = "../../patterns/api-gateway-microservices-dynamodb"
  
  # General settings
  aws_region = "us-east-1"
  
  # API Gateway configuration
  api_name        = var.api_name
  api_description = var.api_description
  endpoint_types  = var.endpoint_types
  
  # Custom domain (optional)
  create_custom_domain = var.create_custom_domain
  domain_name          = var.domain_name
  certificate_arn      = var.create_custom_domain ? aws_acm_certificate.api[0].arn : null
  base_path            = var.base_path
  stage_name           = var.stage_name
  
  # CloudWatch and WAF
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
  waf_acl_arn         = var.create_waf_acl ? aws_wafv2_web_acl.api[0].arn : null
  
  # DynamoDB configuration
  dynamodb_table_name  = var.dynamodb_table_name
  dynamodb_hash_key    = var.dynamodb_hash_key
  dynamodb_range_key   = var.dynamodb_range_key
  dynamodb_kms_key_arn = var.use_customer_managed_key ? aws_kms_key.dynamodb[0].arn : null
  
  # Global secondary indexes
  dynamodb_attributes = var.dynamodb_attributes
  dynamodb_global_secondary_indexes = var.dynamodb_global_secondary_indexes
  
  # CORS settings
  enable_cors       = var.enable_cors
  cors_allow_origin = var.cors_allow_origin
  
  # Lambda functions
  lambda_functions = var.lambda_functions
  
  tags = var.tags
} 