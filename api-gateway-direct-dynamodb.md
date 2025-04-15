# API Gateway with Direct DynamoDB Integration

This Terraform project demonstrates how to create an API Gateway with direct DynamoDB integration using the pattern from the terraform-templates library.

## Architecture

This implementation creates:
- A REST API Gateway with direct integration to DynamoDB (no Lambda required)
- A DynamoDB table with appropriate schema for the API operations
- Integration mappings using Velocity Template Language (VTL)
- CORS support for cross-origin requests
- Global Secondary Index for efficient queries

## Features

- **Serverless**: No Lambda functions required, reducing latency and costs
- **Scalable**: Uses DynamoDB's pay-per-request billing mode for automatic scaling
- **Low Latency**: Direct integration without intermediary compute resources
- **Cost-Effective**: Only pay for what you use with no idle resources

## Resources Created

### API Gateway
- REST API with regional endpoint
- API resources for product operations
- VTL mapping templates for transforming requests/responses
- CORS configuration

### DynamoDB
- Table with partition key (id) and sort key (category)
- Global Secondary Index on category and price
- Automatic encryption at rest

## API Endpoints

### Products Collection
- `GET /products` - List all products
- `POST /product` - Create a new product

### Product Item
- `GET /products/{id}` - Get a product by ID
- `PUT /product/{id}` - Update a product

### Products by Category
- `GET /products-by-category?category={category}` - Query products by category

## Usage

1. Initialize the Terraform configuration:
```
terraform init
```

2. Deploy the resources:
```
terraform apply
```

3. After deployment, the API endpoint URL will be available in the outputs:
```
terraform output api_gateway_invoke_url
```

## Request Examples

### Get all products
```
GET https://{api_id}.execute-api.{region}.amazonaws.com/dev/products
```

### Get a specific product
```
GET https://{api_id}.execute-api.{region}.amazonaws.com/dev/products/123
```

### Create a product
```
POST https://{api_id}.execute-api.{region}.amazonaws.com/dev/product

{
  "id": "123",
  "name": "Example Product",
  "price": 29.99,
  "category": "electronics"
}
```

### Query products by category
```
GET https://{api_id}.execute-api.{region}.amazonaws.com/dev/products-by-category?category=electronics
```

## Cleanup

To destroy all resources:
```
terraform destroy
``` 