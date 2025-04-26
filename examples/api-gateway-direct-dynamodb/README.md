# Example: API Gateway with Direct DynamoDB Integration

This directory contains an example Terraform configuration that deploys the API Gateway-Direct-DynamoDB pattern.

This pattern creates a serverless REST API using API Gateway that interacts directly with a DynamoDB table without requiring an intermediary Lambda function for basic CRUD (Create, Read, Update, Delete) operations.

## Prerequisites

1.  **Custom Domain (Optional):** If using a custom domain (`create_custom_domain = true`), you need:
    *   A registered domain name.
    *   An ACM certificate in the **same region** as your API Gateway deployment that validates the `domain_name`.

## Usage

1.  **Customize Variables:**
    *   Copy the `terraform.tfvars` file provided in this directory.
    *   Update the variables with your specific values, especially:
        *   `api_name`: A name for your API Gateway.
        *   `dynamodb_table_name`: A name for your DynamoDB table.
        *   `dynamodb_hash_key`: The name of the attribute to use as the primary partition key (e.g., "userID", "productID").
        *   `dynamodb_attributes`: Define *at least* the hash key attribute here. Add definitions for any range keys or attributes used as keys in secondary indexes.
        *   `collection_name`: The base path for your API resources (e.g., "users", "products").
        *   `api_endpoints`: This complex variable defines which HTTP methods (GET, POST, PUT, DELETE) are enabled on the collection (`/collection_name`) and item (`/collection_name/{hash_key}`) resources and how they map to DynamoDB operations (Scan, Query, GetItem, PutItem, UpdateItem, DeleteItem). Review the example configuration and comments carefully to enable the operations you need.
        *   If using secondary indexes (`dynamodb_global_secondary_indexes`, `dynamodb_local_secondary_indexes`), ensure they are defined correctly and referenced in `api_endpoints` if you want to query them via the API.
        *   If `create_custom_domain = true`, set `domain_name` and `certificate_arn`.
        *   Review other configurations like `enable_cors`, `api_authorization`, etc.

2.  **Deploy the Stack:**
    *   Navigate to this directory (`examples/api-gateway-direct-dynamodb`) in your terminal.
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

3.  **Test the API:**
    *   Terraform will output the `api_gateway_invoke_url` (or `api_gateway_custom_domain_url` if configured) and the `dynamodb_table_name`.
    *   Use a tool like `curl`, Postman, or the AWS CLI to interact with your API endpoints based on the configurations in `api_endpoints`.
        *   **Example GET Collection (Scan):** `curl {invoke_url}/{stage_name}/{collection_name}`
        *   **Example GET Item:** `curl {invoke_url}/{stage_name}/{collection_name}/{your_item_id}` (Replace `{your_item_id}` with an actual ID)
        *   **Example POST (if enabled):** `curl -X POST -H "Content-Type: application/json" -d '{"attribute1": "value1", "attribute2": 123}' {invoke_url}/{stage_name}/{collection_name}`
        *   **Example PUT (if enabled):** `curl -X PUT -H "Content-Type: application/json" -d '{"attribute1": "new_value"}' {invoke_url}/{stage_name}/{collection_name}/{your_item_id}`
        *   **Example DELETE (if enabled):** `curl -X DELETE {invoke_url}/{stage_name}/{collection_name}/{your_item_id}`
    *   Check the DynamoDB table in the AWS Management Console to verify data changes.

## Cleanup

To remove the resources created by this example, run:

```bash
terraform destroy -var-file=terraform.tfvars
``` 