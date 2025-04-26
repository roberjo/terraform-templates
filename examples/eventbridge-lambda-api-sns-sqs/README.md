# Example: EventBridge Scheduler with Lambda, API Polling, SNS, and SQS

This directory contains an example Terraform configuration that deploys the EventBridge-Lambda-API-SNS-SQS pattern.

This pattern sets up a scheduled Lambda function that polls an external API, publishes the retrieved data to an SNS topic, which then fans out to an SQS queue for potentially further processing by another Lambda function.

## Prerequisites

1.  **Lambda Code:** You need to provide the deployment packages (.zip files) for:
    *   The primary Lambda function (`lambda_source_path`) that polls the API and publishes to SNS.
    *   The SQS processor Lambda function (`sqs_processor_source_path`), if `create_separate_sqs_processor` is set to `true`.
2.  **API Endpoint:** Know the URL of the API you want to poll (`api_endpoint`).
3.  **API Key (Optional):** If the API requires authentication, have the key ready (`api_key`). Consider using AWS Secrets Manager for storing secrets securely in production.

## Usage

1.  **Customize Variables:**
    *   Copy the `terraform.tfvars` file provided in this directory.
    *   Update the variables with your specific values, especially:
        *   `name_prefix`: A unique prefix for your resources.
        *   `api_endpoint`: The URL of the API to poll.
        *   `api_key`: Your API key, if required.
        *   `lambda_source_path`: The path to your primary Lambda function's deployment package.
        *   `sqs_processor_source_path`: The path to your SQS processor Lambda's deployment package (if applicable).
        *   Review other settings like `schedule_expression`, Lambda configurations (`runtime`, `handler`, `memory_size`, `timeout`), SNS/SQS names, etc.

2.  **Prepare Lambda Packages:**
    *   Ensure your Lambda deployment packages specified in `lambda_source_path` and `sqs_processor_source_path` exist at those locations relative to this example directory.

3.  **Deploy the Stack:**
    *   Navigate to this directory (`examples/eventbridge-lambda-api-sns-sqs`) in your terminal.
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

4.  **Verify:**
    *   Check the EventBridge console to ensure the schedule is created and enabled.
    *   Check the Lambda console for the created functions.
    *   Check the SNS and SQS consoles for the created topic and queue.
    *   Monitor CloudWatch Logs for the Lambda functions after the schedule triggers to ensure data is being processed and flowing through SNS and SQS.

## Cleanup

To remove the resources created by this example, run:

```bash
terraform destroy -var-file=terraform.tfvars
``` 