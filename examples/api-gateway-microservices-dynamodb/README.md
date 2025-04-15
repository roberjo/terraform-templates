# API Gateway with Microservices and DynamoDB Example

This example demonstrates how to use the API Gateway with Microservices and DynamoDB pattern to create a complete serverless architecture. It includes API Gateway with custom domain, Lambda microservices, DynamoDB for data persistence, WAF protection, and KMS encryption.

## Architecture Overview

This example creates:

- API Gateway with custom domain support
- Multiple Lambda microservices
- DynamoDB table with GSIs
- AWS WAF Web ACL (optional)
- KMS key for encryption (optional)
- CloudWatch logging
- IAM roles with appropriate permissions

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform v1.0 or later
3. If using custom domain, a domain registered in Route 53 or managed elsewhere
4. Lambda function code zip files (provided in this example)

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review and customize variables**:
   - Edit `terraform.tfvars` as needed
   - By default, custom domain and WAF are disabled to simplify the setup

3. **Plan the deployment**:
   ```bash
   terraform plan -out=tfplan
   ```

4. **Apply the plan**:
   ```bash
   terraform apply tfplan
   ```

## Customization Options

### Enabling Custom Domain

To enable a custom domain for your API:

1. Set `create_custom_domain = true` in terraform.tfvars
2. Specify your domain name: `domain_name = "api.yourdomain.com"`
3. After deployment, validate the ACM certificate:
   - Add the validation CNAME records to your DNS
   - Create an A record pointing to the API Gateway domain name (output by Terraform)

### Enabling WAF Protection

To enable WAF protection:

1. Set `create_waf_acl = true` in terraform.tfvars
2. Modify the WAF rules in `main.tf` as needed

### Using Customer Managed KMS Keys

For additional security with your own KMS keys:

1. Set `use_customer_managed_key = true` in terraform.tfvars

## Lambda Function Code

This example includes a simple Lambda function for demonstration purposes:

```javascript
// Example Lambda handler in lambda/example-function.zip
exports.handler = async (event) => {
  console.log('Received event:', JSON.stringify(event, null, 2));
  
  const httpMethod = event.httpMethod;
  const path = event.path;
  const resource = event.resource;
  
  // Determine the service from the path
  const serviceName = path.split('/')[1];
  
  // Simulate database interaction
  const response = {
    service: serviceName,
    method: httpMethod,
    message: `This is the ${serviceName} microservice responding to a ${httpMethod} request`,
    timestamp: new Date().toISOString()
  };
  
  // Return response
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(response)
  };
};
```

## Testing the API

After deployment, you can test the API using curl or a tool like Postman:

```bash
# Get all users
curl -X GET https://api.example.com/v1/users

# Get a specific item
curl -X GET https://api.example.com/v1/items/123

# Create a new user
curl -X POST https://api.example.com/v1/users \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'
```

## Cleanup

To remove all resources created by this example:

```bash
terraform destroy
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