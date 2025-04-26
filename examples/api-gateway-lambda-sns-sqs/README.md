# Example: API Gateway with Lambda, SNS, and SQS

This directory contains an example Terraform configuration that deploys the API Gateway-Lambda-SNS-SQS pattern.

This pattern creates an API Gateway endpoint that triggers a Lambda function. The Lambda function processes the incoming request and publishes a message to an SNS topic. An SQS queue is subscribed to this topic, allowing for asynchronous processing of the message, potentially by another dedicated Lambda function.

## Prerequisites

1.  **Lambda Code:** You need to provide the deployment packages (.zip files or S3 locations) for:
    *   The primary Lambda function (`lambda_filename` or `lambda_s3_bucket`/`lambda_s3_key`) that handles the API request and publishes to SNS.
    *   The SQS processor Lambda function (`sqs_processor_filename` or `sqs_processor_s3_bucket`/`sqs_processor_s3_key`), if `create_separate_sqs_processor` is set to `true`.
2.  **Custom Domain (Optional):** If using a custom domain (`create_custom_domain = true`), you need:
    *   A registered domain name.
    *   An ACM certificate in the **same region** as your API Gateway deployment that validates the `domain_name`.

## Usage

1.  **Customize Variables:**
    *   Copy the `terraform.tfvars` file provided in this directory.
    *   Update the variables with your specific values, especially:
        *   `api_name`: A name for your API Gateway.
        *   `sns_topic_name`: A name for your SNS topic.
        *   `sqs_queue_name`: A name for your SQS queue.
        *   `lambda_function_name`: Name for the primary Lambda function.
        *   Update one of the source code options for the primary Lambda (`lambda_filename` or `lambda_s3_bucket`/`lambda_s3_key`).
        *   If `create_separate_sqs_processor = true`:
            *   `sqs_processor_function_name`: Name for the SQS processor Lambda.
            *   Update one of the source code options for the SQS processor Lambda (`sqs_processor_filename` or `sqs_processor_s3_bucket`/`sqs_processor_s3_key`).
        *   If `create_custom_domain = true`:
            *   Set `domain_name` and `certificate_arn`.
        *   Review other configurations like Lambda runtime/handler, CORS settings, etc.

2.  **Prepare Lambda Packages:**
    *   Ensure your Lambda deployment packages exist either locally (if using `_filename`) or in the specified S3 bucket (if using `_s3_bucket`/`_s3_key`).

3.  **Deploy the Stack:**
    *   Navigate to this directory (`examples/api-gateway-lambda-sns-sqs`) in your terminal.
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

4.  **Test the API:**
    *   Terraform will output the `api_gateway_invoke_url` (or `api_gateway_custom_domain_url` if configured).
    *   Send a POST request to the resource path defined by `api_resource_path` (e.g., `{invoke_url}/{stage_name}/{api_resource_path}`).
    *   Verify that the primary Lambda function executes (check CloudWatch Logs).
    *   Verify that a message appears in the SQS queue.
    *   If `create_separate_sqs_processor = true`, verify that the SQS processor Lambda executes and processes the message (check CloudWatch Logs).

## Cleanup

To remove the resources created by this example, run:

```bash
terraform destroy -var-file=terraform.tfvars
``` 