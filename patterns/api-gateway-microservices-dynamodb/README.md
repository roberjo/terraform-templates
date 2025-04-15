# API Gateway with Microservices and DynamoDB Pattern

This Terraform pattern creates a complete serverless architecture with API Gateway, Lambda microservices, and DynamoDB for data persistence. It includes custom domain support, proper IAM permissions, and configurable settings.

## Architecture Overview

![Architecture Diagram](https://lucid.app/publicSegments/view/25c57fc1-a98d-4ccd-8d3a-af4bc980eeec/image.png)

This pattern implements:

- Amazon API Gateway with custom domain and CORS support
- Multiple Lambda-based microservices
- DynamoDB table for data persistence
- Proper IAM permissions
- CloudWatch logging

## Usage

```hcl
module "api_microservices" {
  source = "../../patterns/api-gateway-microservices-dynamodb"

  # General settings
  aws_region = "us-east-1"
  
  # API Gateway configuration
  api_name        = "my-api"
  api_description = "My API with Microservices"
  
  # Custom domain (optional)
  create_custom_domain = true
  domain_name          = "api.example.com"
  certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-ef56-gh78-ij90-klmnopqrstuv"
  
  # Stage settings
  stage_name = "prod"
  
  # DynamoDB configuration
  dynamodb_table_name = "my-data-table"
  dynamodb_hash_key   = "id"
  
  # Global secondary indexes (optional)
  dynamodb_global_secondary_indexes = [
    {
      name               = "UserTypeIndex"
      hash_key           = "userType"
      range_key          = "createdAt"
      projection_type    = "INCLUDE"
      non_key_attributes = ["name", "email"]
    }
  ]
  
  # Lambda functions
  lambda_functions = {
    users = {
      name            = "users-service"
      description     = "Users microservice"
      handler         = "index.handler"
      runtime         = "nodejs18.x"
      filename        = "${path.module}/lambda/users.zip"
      source_code_hash = filebase64sha256("${path.module}/lambda/users.zip")
      environment_variables = {
        STAGE = "production"
      }
    },
    products = {
      name            = "products-service"
      description     = "Products microservice"
      handler         = "index.handler"
      runtime         = "nodejs18.x"
      filename        = "${path.module}/lambda/products.zip"
      source_code_hash = filebase64sha256("${path.module}/lambda/products.zip")
    },
    orders = {
      name            = "orders-service"
      description     = "Orders microservice"
      handler         = "index.handler"
      runtime         = "nodejs18.x"
      filename        = "${path.module}/lambda/orders.zip"
      source_code_hash = filebase64sha256("${path.module}/lambda/orders.zip")
    }
  }
  
  tags = {
    Project     = "MyProject"
    Environment = "Production"
  }
}
```

## Prerequisites

1. **SSL Certificate**: If using a custom domain, you must have a valid ACM certificate in the same region as your API Gateway (or in us-east-1 for edge-optimized endpoints).

2. **Lambda Code**: Your Lambda function code should be prepared in ZIP format. Each Lambda function needs its own deployment package.

3. **IAM Permissions**: The AWS account must have permissions to create all required resources.

## Lambda Function Structure

Each Lambda function should be structured to work with API Gateway using the proxy integration. Here's a simple example for Node.js:

```javascript
// Example Lambda function for users microservice
exports.handler = async (event) => {
  try {
    // Get the HTTP method and path
    const httpMethod = event.httpMethod;
    const path = event.path;
    
    // Get the path parameters and query string parameters
    const pathParams = event.pathParameters || {};
    const queryParams = event.queryStringParameters || {};
    
    // Get the request body (if applicable)
    const body = event.body ? JSON.parse(event.body) : {};
    
    let response;
    
    // Process the request based on HTTP method
    if (httpMethod === 'GET') {
      if (pathParams.id) {
        // Get a specific user by ID
        response = await getUser(pathParams.id);
      } else {
        // Get all users (with optional filtering)
        response = await getAllUsers(queryParams);
      }
    } else if (httpMethod === 'POST') {
      // Create a new user
      response = await createUser(body);
    } else if (httpMethod === 'PUT') {
      // Update an existing user
      response = await updateUser(pathParams.id, body);
    } else if (httpMethod === 'DELETE') {
      // Delete a user
      response = await deleteUser(pathParams.id);
    } else {
      // Method not supported
      return {
        statusCode: 405,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ error: 'Method not allowed' })
      };
    }
    
    // Return the response
    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(response)
    };
  } catch (error) {
    console.error('Error:', error);
    
    // Return an error response
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ error: error.message || 'Internal server error' })
    };
  }
};

// Function implementations (would interact with DynamoDB)
async function getUser(id) {
  // Code to get a user from DynamoDB
}

async function getAllUsers(queryParams) {
  // Code to query users from DynamoDB
}

async function createUser(userData) {
  // Code to create a user in DynamoDB
}

async function updateUser(id, userData) {
  // Code to update a user in DynamoDB
}

async function deleteUser(id) {
  // Code to delete a user from DynamoDB
}
```

## API Endpoints

This pattern creates the following API endpoints for each microservice:

- **GET /{service}** - Get all items for a service
- **GET /{service}/{id}** - Get a specific item by ID
- **POST /{service}** - Create a new item
- **PUT /{service}/{id}** - Update an existing item
- **DELETE /{service}/{id}** - Delete an item

For the example above, the endpoints would be:

- `/users`
- `/products`
- `/orders`

## Customization

### Adding Authentication

To add authentication to your API:

1. Create a Cognito User Pool or custom authorizer Lambda function
2. Configure the `api_authorization_type` variable:
   ```hcl
   api_authorization_type = "COGNITO_USER_POOLS"
   api_authorizer_id      = aws_api_gateway_authorizer.cognito.id
   ```

### Enabling WAF Protection

To add WAF protection:

1. Create a WAF WebACL in the same region
2. Set the `waf_acl_arn` variable to your WebACL ARN

### Enabling CloudWatch Logs

To enable CloudWatch logs for the API Gateway:

1. Create an IAM role with the appropriate permissions
2. Set the `cloudwatch_role_arn` variable to your IAM role ARN

## Input Variables

See [variables.tf](./variables.tf) for a complete list of input variables with descriptions.

## Outputs

See [outputs.tf](./outputs.tf) for a complete list of outputs with descriptions.

## Security Considerations

This pattern implements several security best practices:

1. DynamoDB encryption at rest (enabled by default)
2. Point-in-time recovery for DynamoDB (enabled by default)
3. Proper IAM permissions with least privilege
4. Optional WAF integration
5. Support for HTTPS endpoints with custom domains

## Cost Considerations

The main cost drivers for this architecture are:

1. API Gateway requests
2. Lambda function invocations and execution duration
3. DynamoDB storage and read/write capacity
4. CloudWatch logs storage

For optimal cost management:

- Use the PAY_PER_REQUEST billing mode for DynamoDB (default)
- Configure appropriate Lambda memory and timeout values
- Set appropriate CloudWatch log retention periods 