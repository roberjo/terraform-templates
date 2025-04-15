# Route53 hosted zone with WAF ACL security and cloudfront distribution and s3 static content with kms key encryption at rest Pattern

This Terraform pattern creates a complete serverless architecture with Route53 hosted zone entries pointing to a cloudfront distribution connected to a s3 bucket for static content files with kms encryption at rest. It includes custom domain support, proper IAM permissions, and configurable settings.

## Architecture Overview

This pattern sets up the following AWS resources:

- **Amazon S3 Bucket**: For storing static website content with server-side encryption using AWS KMS
- **Amazon CloudFront**: Content delivery network for global distribution of your content
- **AWS WAF**: Web Application Firewall to protect your CloudFront distribution from common web exploits
- **Amazon Route53**: For DNS management with custom domain support
- **AWS KMS**: For encryption of S3 bucket objects at rest

The architecture flow is as follows:
1. Users access your website via your custom domain (example.com)
2. Route53 routes the request to CloudFront
3. CloudFront serves content globally from edge locations
4. WAF protects against malicious requests
5. CloudFront retrieves content from the S3 bucket
6. S3 bucket provides content with KMS encryption at rest

## Usage

```hcl
module "static_website" {
  source = "path/to/patterns/route53-waf-cloudfront-s3"

  # Domain Configuration
  domain_name         = "example.com"
  create_route53_zone = true
  
  # S3 Bucket Configuration
  bucket_name             = "example-com-static-content"
  enable_bucket_versioning = true
  
  # KMS Configuration
  create_kms_key          = true
  kms_key_alias           = "s3-static-content-encryption"
  
  # CloudFront Configuration
  cloudfront_aliases      = ["example.com", "www.example.com"]
  
  # SSL Certificate (required for custom domains)
  acm_certificate_arn     = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-ab12-cd34-ef56-abcdef123456"
  
  # WAF Configuration (optional)
  waf_acl_arn             = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/example-waf-acl/abcd1234-ab12-cd34-ef56-abcdef123456"
  
  # Tags
  tags = {
    Environment = "Production"
    Project     = "Corporate Website"
  }
}
```

## Prerequisites

1. You must have an ACM certificate for your domain if using custom domain names with CloudFront. The certificate **must** be in the `us-east-1` region, regardless of your application's region.
2. If using an existing Route53 hosted zone, you'll need its ID.
3. If using an existing WAF web ACL, you'll need its ARN.

## Features

- **Custom Domain Support**: Connect your CloudFront distribution to your own domain names
- **Encryption at Rest**: All content in S3 is encrypted using KMS keys
- **CloudFront Configuration**: Full control over cache behaviors, error responses, and other CloudFront settings
- **WAF Integration**: Protect your content with AWS WAF web ACLs
- **IPv6 Support**: Enable IPv6 access to your content
- **Global CDN**: Distribute your content to edge locations worldwide for fast access
- **Secure by Default**: HTTPS-only access with configurable TLS settings

## Important Notes

1. **CloudFront Distribution Time**: It can take up to 15-30 minutes for a CloudFront distribution to deploy globally.
2. **ACM Certificate Region**: Your ACM certificate must be in us-east-1 for use with CloudFront.
3. **Route53 Name Servers**: If creating a new hosted zone, you'll need to update your domain's name servers at your registrar.
4. **S3 Access**: The S3 bucket is private and only accessible via CloudFront using Origin Access Control.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | Domain name for the Route53 hosted zone | string | n/a | yes |
| bucket_name | Name of the S3 bucket for static content | string | n/a | yes |
| create_route53_zone | Whether to create a new Route53 hosted zone | bool | true | no |
| route53_zone_id | ID of an existing Route53 hosted zone (if not creating a new one) | string | null | no |
| create_kms_key | Whether to create a new KMS key for S3 bucket encryption | bool | true | no |
| kms_key_arn | ARN of an existing KMS key for S3 bucket encryption | string | null | no |
| acm_certificate_arn | ARN of the ACM certificate for the CloudFront distribution | string | null | no |
| waf_acl_arn | ARN of the WAF ACL to associate with the CloudFront distribution | string | null | no |
| cloudfront_aliases | Alternate domain names for the CloudFront distribution | list(string) | [] | no |

For a complete list of inputs, see the `variables.tf` file.

## Outputs

| Name | Description |
|------|-------------|
| s3_bucket_id | ID of the S3 bucket |
| cloudfront_distribution_id | ID of the CloudFront distribution |
| cloudfront_distribution_domain_name | Domain name of the CloudFront distribution |
| route53_zone_id | ID of the Route53 zone |
| route53_zone_name_servers | Name servers of the Route53 zone |

For a complete list of outputs, see the `outputs.tf` file.

## Security Considerations

- All S3 content is encrypted at rest
- CloudFront enforces HTTPS by default
- S3 bucket has private ACL and is only accessible via CloudFront
- WAF can be configured to protect against common attacks

## License

This Terraform pattern is released under the [MIT License](https://opensource.org/licenses/MIT).