/**
 * # API Gateway Module
 *
 * This module creates an Amazon API Gateway REST API with custom domain configuration,
 * certificate validation, and base path mappings.
 */

resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.description
  
  endpoint_configuration {
    types = var.endpoint_types
  }

  # Optionally enable binary media types for the API
  dynamic "binary_media_types" {
    for_each = length(var.binary_media_types) > 0 ? [1] : []
    content {
      binary_media_types = var.binary_media_types
    }
  }

  tags = var.tags
}

# Custom domain name for API Gateway
resource "aws_api_gateway_domain_name" "this" {
  count = var.create_custom_domain ? 1 : 0

  domain_name              = var.domain_name
  regional_certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = var.endpoint_types
  }

  tags = var.tags
}

# Base path mapping to connect the custom domain to the API
resource "aws_api_gateway_base_path_mapping" "this" {
  count = var.create_custom_domain ? 1 : 0

  api_id      = aws_api_gateway_rest_api.this.id
  domain_name = aws_api_gateway_domain_name.this[0].domain_name
  stage_name  = aws_api_gateway_stage.this.stage_name
  base_path   = var.base_path
}

# Deployment to create a snapshot of the API configuration
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  
  # This forces a new deployment when any resources or methods are modified
  # It's a standard Terraform trick to ensure the deployment is updated
  triggers = {
    redeployment = sha1(jsonencode(var.deployment_trigger))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Stage for the API Gateway deployment
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name

  # CORS configuration
  dynamic "access_log_settings" {
    for_each = var.access_log_settings != null ? [var.access_log_settings] : []
    content {
      destination_arn = access_log_settings.value.destination_arn
      format          = access_log_settings.value.format
    }
  }

  # Optionally enable caching
  dynamic "cache_cluster_settings" {
    for_each = var.enable_caching ? [1] : []
    content {
      cache_cluster_enabled = true
      cache_cluster_size    = var.cache_cluster_size
    }
  }

  # Method settings
  dynamic "method_settings" {
    for_each = var.method_settings != null ? [var.method_settings] : []
    content {
      method_path = method_settings.value.method_path
      settings    = method_settings.value.settings
    }
  }

  tags = var.tags
}

# API Gateway account settings (for CloudWatch logs)
resource "aws_api_gateway_account" "this" {
  count = var.cloudwatch_role_arn != null ? 1 : 0
  
  cloudwatch_role_arn = var.cloudwatch_role_arn
}

# Optional WAF WebACL association
resource "aws_wafv2_web_acl_association" "this" {
  count = var.waf_acl_arn != null ? 1 : 0
  
  resource_arn = aws_api_gateway_stage.this.arn
  web_acl_arn  = var.waf_acl_arn
} 