# AWS API Gateway Terraform Module

This Terraform module creates an Amazon API Gateway REST API with support for custom domains, stages, and WAF integration.

## Features

- Creates an Amazon API Gateway REST API
- Supports custom domain name with SSL certificate
- Configurable stage settings
- Optional WAF integration for security
- CloudWatch logging support
- Caching capabilities

## Usage

```hcl
module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name        = "my-api"
  description     = "My API Gateway REST API"
  endpoint_types  = ["REGIONAL"]
  
  # Custom domain configuration
  create_custom_domain = true
  domain_name          = "api.example.com"
  certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-ef56-gh78-ij90-klmnopqrstuv"
  base_path            = "v1"
  
  # Stage configuration
  stage_name = "prod"
  
  # CloudWatch logging
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
  
  # WAF integration
  waf_acl_arn = aws_wafv2_web_acl.api_waf.arn
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Required Prerequisites

1. A Route53 hosted zone for your domain (if using custom domain)
2. An ACM certificate for your custom domain name
3. IAM role with permissions for CloudWatch logs (if enabling logging)
4. WAF WebACL (if using WAF integration)

## Known Limitations and Requirements

- The ACM certificate must be in the same region as the API Gateway (for regional endpoints)
- For edge-optimized endpoints, the certificate must be in the us-east-1 region
- Custom domain names require DNS validation to be completed before use

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api_name | Name of the API Gateway REST API | `string` | n/a | yes |
| description | Description of the API Gateway REST API | `string` | `"API Gateway created with Terraform"` | no |
| endpoint_types | List of endpoint types (EDGE, REGIONAL, PRIVATE) | `list(string)` | `["REGIONAL"]` | no |
| binary_media_types | List of binary media types supported by the API Gateway | `list(string)` | `[]` | no |
| create_custom_domain | Whether to create a custom domain name for the API Gateway | `bool` | `false` | no |
| domain_name | Custom domain name for the API Gateway | `string` | `null` | no |
| certificate_arn | ARN of the ACM certificate for the custom domain | `string` | `null` | no |
| base_path | Base path mapping for the custom domain | `string` | `""` | no |
| stage_name | Name of the stage for the API Gateway deployment | `string` | `"api"` | no |
| deployment_trigger | Map used as a deployment trigger | `map(any)` | `{ redeployment = "1" }` | no |
| enable_caching | Whether to enable caching for the API Gateway stage | `bool` | `false` | no |
| cache_cluster_size | Size of the cache cluster for the API Gateway stage | `string` | `"0.5"` | no |
| access_log_settings | Settings for access logging of the API Gateway stage | `object` | `null` | no |
| method_settings | Method settings for the API Gateway stage | `object` | `null` | no |
| cloudwatch_role_arn | ARN of the IAM role for CloudWatch logs | `string` | `null` | no |
| waf_acl_arn | ARN of the WAF WebACL to associate with the API Gateway stage | `string` | `null` | no |
| tags | Map of tags to assign to the API Gateway resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| rest_api_id | ID of the API Gateway REST API |
| rest_api_name | Name of the API Gateway REST API |
| rest_api_arn | ARN of the API Gateway REST API |
| rest_api_execution_arn | Execution ARN of the API Gateway REST API |
| root_resource_id | Resource ID of the API Gateway REST API root resource |
| deployment_id | ID of the API Gateway deployment |
| stage_id | ID of the API Gateway stage |
| stage_name | Name of the API Gateway stage |
| stage_arn | ARN of the API Gateway stage |
| invoke_url | Invoke URL of the API Gateway stage |
| domain_name | Custom domain name of the API Gateway |
| domain_regional_domain_name | Regional domain name of the API Gateway custom domain |

## Additional Configuration Notes

### Setting Up CloudWatch Logs

To enable CloudWatch logging, create an IAM role with the appropriate permissions:

```hcl
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
```

### DNS Configuration for Custom Domain

After deploying the API Gateway with a custom domain, you'll need to configure DNS to point to the API Gateway domain:

```hcl
resource "aws_route53_record" "api" {
  zone_id = "Z1234567890EXAMPLE"  # Your Route53 hosted zone ID
  name    = "api.example.com"
  type    = "A"

  alias {
    name                   = module.api_gateway.domain_regional_domain_name
    zone_id                = "Z2FDTNDATAQYW2"  # API Gateway hosted zone ID (fixed value for regional endpoints)
    evaluate_target_health = true
  }
}
``` 