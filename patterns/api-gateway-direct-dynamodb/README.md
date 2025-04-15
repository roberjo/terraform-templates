# API Gateway with Direct DynamoDB Integration

This Terraform pattern creates an API Gateway that integrates directly with DynamoDB, allowing you to create a serverless REST API for your DynamoDB tables without the need for Lambda functions.

## Architecture

![Architecture Diagram](./architecture.png)

This pattern sets up:
- An Amazon API Gateway REST API with API key authentication (optional)
- A DynamoDB table with configurable keys, indexes, and settings
- API integrations that directly map API Gateway methods to DynamoDB operations
- Optional CORS support
- Optional custom domain name

## Features

- **Serverless**: No Lambda functions required, reducing latency and costs
- **Customizable**: Configure API endpoints, DynamoDB table structure, and authentication
- **Secure**: Control access with API keys or IAM roles
- **Flexible**: Support for various DynamoDB operations including Get, Scan, Query, Put, Update, and Delete
- **Optimized**: Configurable caching and throttling
- **Developer-friendly**: Well-documented variables and examples

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`
2. Modify the variables in `terraform.tfvars` to match your requirements
3. Initialize and apply the Terraform configuration:

```bash
terraform init
terraform apply
```

## Configuration

### API Gateway Configuration

Configure your API Gateway with custom name, description, and endpoints:

```hcl
# API Gateway Configuration
api_name        = "items-api"
api_description = "Items API with direct DynamoDB integration"
endpoint_types  = ["REGIONAL"]
stage_name      = "dev"
```

### DynamoDB Table Configuration

Define your DynamoDB table structure, including keys, indexes, and attributes:

```hcl
# DynamoDB Table Configuration
dynamodb_table_name                 = "items"
dynamodb_billing_mode               = "PAY_PER_REQUEST"
dynamodb_hash_key                   = "id"
dynamodb_hash_key_type              = "S"
dynamodb_range_key                  = "sort"
dynamodb_range_key_type             = "S"
```

### API Endpoints

Define API endpoints that map to specific DynamoDB operations:

```hcl
# API Endpoints Configuration
api_endpoints = {
  "items" = {
    collection_operation = "GET"
    query_type           = "Scan"
    limit                = 100
  },
  "item" = {
    item_operation = "GET"
  },
  # More endpoints...
}
```

## API Endpoint Types

### Collection Operations

Operations that work with collections of items:

- `GET` with `query_type = "Scan"`: Retrieve all items from the table
- `GET` with `query_type = "Query"`: Query items by key condition
- `POST`: Create a new item in the table

### Item Operations

Operations that work with a single item:

- `GET`: Retrieve a single item by key
- `PUT`: Update an item by key
- `PATCH`: Partially update an item by key
- `DELETE`: Delete an item by key

## Examples

### Basic GET Collection

```hcl
"items" = {
  collection_operation = "GET"
  query_type           = "Scan"
  limit                = 100
}
```

### Query by Index

```hcl
"items-by-status" = {
  collection_operation = "GET"
  query_type           = "Query"
  index_name           = "StatusIndex"
  key_condition        = "status = :status"
  expression_values    = { ":status" = "active" }
}
```

### Item Operations

```hcl
"item" = {
  item_operation = "GET"
}

"update-item" = {
  item_operation       = "PUT"
  update_expression    = "SET #status = :status"
  expression_names     = { "#status" = "status" }
  expression_values    = { ":status" = "updated" }
}
```

## Security Considerations

- By default, API Gateway endpoints are public unless you configure authentication
- Consider enabling API key requirements for sensitive operations
- Use IAM roles for fine-grained access control
- Enable encryption at rest for sensitive data

## Outputs

| Name | Description |
|------|-------------|
| api_url | The URL of the deployed API |
| api_key | The API key (if enabled) |
| api_id | The ID of the API Gateway |
| dynamodb_table_arn | The ARN of the DynamoDB table |

## License

This module is licensed under the MIT License. 