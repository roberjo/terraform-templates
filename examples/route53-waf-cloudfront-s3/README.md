# Example: Route53 hosted zone with WAF ACL security, CloudFront distribution, and S3 static content

This directory contains an example Terraform configuration that deploys the Route53-WAF-CloudFront-S3 pattern.

## Usage

1.  **Customize Variables:**
    *   Copy the `terraform.tfvars` file provided in this directory.
    *   Review the variables and update them with your specific values, especially:
        *   `domain_name`: Your desired domain name.
        *   `bucket_name`: A globally unique S3 bucket name.
        *   `acm_certificate_arn`: The ARN of your ACM certificate in `us-east-1` that covers the domain names listed in `cloudfront_aliases`.
        *   (Optional) `route53_zone_id` if using an existing Route53 zone.
        *   (Optional) `kms_key_arn` if using an existing KMS key.
        *   (Optional) `waf_acl_arn` if using an existing WAF ACL.

2.  **Deploy the Stack:**
    *   Navigate to this directory (`examples/route53-waf-cloudfront-s3`) in your terminal.
    *   Initialize Terraform:
        ```bash
        terraform init
        ```
    *   Plan the deployment:
        ```bash
        terraform plan -var-file=terraform.tfvars
        ```
    *   Apply the configuration:
        ```bash
        terraform apply -var-file=terraform.tfvars
        ```

3.  **Update DNS (if creating a new zone):**
    *   If `create_route53_zone` was set to `true`, Terraform will output the `route53_zone_name_servers`.
    *   Go to your domain registrar and update the name servers for your domain to the ones provided in the Terraform output.

4.  **Upload Content:**
    *   Upload your static website files (e.g., `index.html`, `404.html`, CSS, JS, images) to the S3 bucket created by Terraform (output `s3_bucket_name`). You can use the AWS Management Console, AWS CLI, or other S3 tools.

5.  **Access Your Website:**
    *   Wait for the CloudFront distribution to deploy (can take 15-30 minutes) and DNS changes to propagate.
    *   You should then be able to access your website via the domain name(s) configured in `cloudfront_aliases` (e.g., `https://my-example-domain.com`).

## Cleanup

To remove the resources created by this example, run:

```bash
terraform destroy -var-file=terraform.tfvars
``` 