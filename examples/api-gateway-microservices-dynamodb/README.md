# Example: API Gateway with Microservices and DynamoDB

This directory contains an example Terraform configuration that deploys the API Gateway-Microservices-DynamoDB pattern.

This pattern creates a REST API using API Gateway where different paths are routed to different Lambda functions (microservices). These microservices typically interact with a shared DynamoDB table for data persistence.

## Prerequisites

1.  **Lambda Code:** You need to provide the deployment packages (.zip files) for each microservice defined in the `lambda_functions` variable in `terraform.tfvars`. Ensure the paths specified in the `filename` attribute for each function are correct relative to this example directory.
2.  **Custom Domain (Optional):** If using a custom domain (`create_custom_domain = true`), you need:
    *   A registered domain name.
    *   An ACM certificate in the **same region** as your API Gateway deployment that validates the `domain_name`.

## Usage

1.  **Customize Variables:**
    *   Copy the `terraform.tfvars` file provided in this directory.
    *   Update the variables with your specific values, especially:
        *   `api_name`: A name for your API Gateway.
        *   `dynamodb_table_name`: A name for your DynamoDB table.
        *   `dynamodb_hash_key`, `dynamodb_range_key` (if used), and `dynamodb_attributes`: Define your table's primary key structure and any attributes needed for secondary indexes.
        *   `lambda_functions`: This is the core configuration. For each microservice (e.g., "users", "orders"):
            *   Define a unique `name` for the Lambda function.
            *   Specify the correct `handler` and `runtime` for your code.
            *   **Crucially, update `filename` to point to the actual path of your Lambda deployment package (.zip file) for that microservice.**
            *   Optionally set `source_code_hash = filebase64sha256("path/to/your/lambda.zip")` to trigger updates when the code changes.
            *   Configure `memory_size`, `timeout`, `environment_variables`, `layers`, etc., as needed for each function.
        *   If `create_custom_domain = true`, set `domain_name` and `certificate_arn`.
        *   Review other configurations like CORS, DynamoDB indexes, API authorization, etc.

2.  **Prepare Lambda Packages:**
    *   Ensure your Lambda deployment packages (.zip files) exist at the locations specified in the `filename` attributes within the `lambda_functions` map in your `terraform.tfvars` file.

3.  **Deploy the Stack:**
    *   Navigate to this directory (`examples/api-gateway-microservices-dynamodb`) in your terminal.
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
    *   Terraform will output the `api_gateway_invoke_url` (or `api_gateway_custom_domain_url` if configured) and a map of `microservice_urls`.
    *   Use a tool like `curl` or Postman to send requests to the specific microservice endpoints:
        *   **Example (Users Service):** `curl {invoke_url}/{stage_name}/users` (assuming "users" is a key in `lambda_functions`)
        *   **Example (Orders Service with ID):** `curl {invoke_url}/{stage_name}/orders/123`
        *   **Example POST:** `curl -X POST -d '{...}' {invoke_url}/{stage_name}/users`
    *   Check CloudWatch Logs for each Lambda function to verify execution and troubleshoot issues.
    *   Check the DynamoDB table to verify data persistence.

## Cleanup

To remove the resources created by this example, run:

```bash
terraform destroy -var-file=terraform.tfvars
```

## Variables

For a full list of available variables, see [variables.tf](./variables.tf).

## Outputs

After deployment, Terraform will output several useful values:

- API Gateway URLs
- DynamoDB table information
- Lambda function details
- WAF and KMS ARNs (if enabled)

## Notes

1. The Lambda function code in this example is for demonstration only. In a real application, you would implement proper business logic and error handling.

2. For production use, consider:
   - Adding authentication and authorization
   - Implementing proper input validation
   - Setting up monitoring and alarms
   - Configuring appropriate DynamoDB capacity and scaling
   - Adding more WAF rules for additional protection 