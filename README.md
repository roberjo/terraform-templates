# AWS Solutions Architect Terraform Templates 🚀

![GitHub](https://img.shields.io/github/license/yourusername/terraform-templates)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat&logo=amazon-aws&logoColor=white)
![GitHub stars](https://img.shields.io/github/stars/yourusername/terraform-templates?style=social)

A comprehensive collection of production-ready Terraform templates for common AWS cloud architecture patterns. This repository serves as both a reference implementation and a starting point for your AWS infrastructure projects.

<div align="center">
  <img src="https://d1.awsstatic.com/icons/jp/AWS-Cloud-Architecture_Icon_64_Squid.5456af62a4fa66854536641477d94674fbe86144.png" alt="AWS Cloud Architecture" width="100px">
</div>

## 📋 Repository Structure

```
terraform-templates/
├── modules/            # Reusable Terraform modules
├── patterns/           # Complete architecture patterns
├── examples/           # Example implementations
└── docs/               # Additional documentation
```

## 🏗️ Available Architecture Patterns

| Pattern | Description | Key Components |
|---------|-------------|----------------|
| **API Gateway with Microservices** | REST API with Lambda microservices | <ul><li>API Gateway with custom domain</li><li>Lambda-based microservices</li><li>DynamoDB for data persistence</li><li>Complete IAM configuration</li></ul> |
| **API Gateway with Direct DynamoDB** | Direct DynamoDB integration using VTL | <ul><li>API Gateway with custom domain</li><li>Direct DynamoDB integration</li><li>Optimized filtering capabilities</li></ul> |
| **Event-Driven Processing Pipeline** | Serverless event-driven architecture | <ul><li>API Gateway ingestion endpoint</li><li>Lambda processor</li><li>SNS topic for fanout</li><li>SQS queue for processing</li></ul> |
| **Scheduled External Data Processing** | Scheduled data collection & processing | <ul><li>EventBridge scheduler</li><li>3rd party API integration</li><li>SNS notification system</li><li>SQS queue for processing</li></ul> |
| **Secure Static Website Hosting** | Security-focused website hosting | <ul><li>Route53 configuration</li><li>WAF protection</li><li>CloudFront distribution</li><li>S3 with KMS encryption</li></ul> |

## 🧩 Core Modules

<table>
  <tr>
    <th>Module</th>
    <th>Description</th>
    <th>Features</th>
  </tr>
  <tr>
    <td><strong>🌐 API Gateway</strong></td>
    <td>Create REST APIs with custom domains</td>
    <td>Custom domains, WAF integration, logging</td>
  </tr>
  <tr>
    <td><strong>⚡ Lambda</strong></td>
    <td>Deploy serverless functions</td>
    <td>IAM roles, logging, event source mappings</td>
  </tr>
  <tr>
    <td><strong>🗄️ DynamoDB</strong></td>
    <td>Set up NoSQL database tables</td>
    <td>Optimized indexes, encryption, backups</td>
  </tr>
  <tr>
    <td><strong>📦 S3</strong></td>
    <td>Configure storage buckets</td>
    <td>Access patterns, encryption, lifecycles</td>
  </tr>
  <tr>
    <td><strong>🌩️ CloudFront</strong></td>
    <td>Set up content delivery networks</td>
    <td>Caching, security settings, origins</td>
  </tr>
  <tr>
    <td><strong>🔄 Route53</strong></td>
    <td>Configure DNS settings</td>
    <td>Hosted zones, record sets, health checks</td>
  </tr>
  <tr>
    <td><strong>🛡️ WAF</strong></td>
    <td>Implement web application firewall</td>
    <td>Rule sets, rate limiting, IP blocking</td>
  </tr>
  <tr>
    <td><strong>📨 SNS/SQS</strong></td>
    <td>Create messaging infrastructure</td>
    <td>Topics, queues, subscriptions, DLQs</td>
  </tr>
  <tr>
    <td><strong>⏱️ EventBridge</strong></td>
    <td>Set up event buses and schedulers</td>
    <td>Rules, targets, schedules, patterns</td>
  </tr>
</table>

## 🚀 Getting Started

See the [Getting Started Guide](./docs/getting-started.md) for detailed instructions on how to use these templates.

### Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/terraform-templates.git
   cd terraform-templates
   ```

2. **Choose a pattern or example to deploy:**
   ```bash
   cd examples/api-gateway-microservices-dynamodb
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Customize the variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

5. **Deploy the infrastructure:**
   ```bash
   terraform apply
   ```

## 📋 Prerequisites

- Terraform v1.0+
- AWS CLI configured with appropriate permissions
- Basic understanding of AWS services and Terraform

## 📚 Example Usage

### API Gateway with Lambda and DynamoDB

```hcl
module "api_microservices" {
  source = "../../patterns/api-gateway-microservices-dynamodb"

  api_name        = "customer-api"
  api_description = "Customer API with microservices"
  
  # Custom domain configuration
  create_custom_domain = true
  domain_name          = "api.example.com"
  certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/example"
  
  # DynamoDB configuration
  dynamodb_table_name = "customers"
  dynamodb_hash_key   = "id"
  
  # Lambda functions
  lambda_functions = {
    users = {
      name        = "users-service"
      handler     = "index.handler"
      runtime     = "nodejs18.x"
      filename    = "./lambda/users.zip"
      environment_variables = {
        STAGE = "production"
      }
    }
  }
  
  tags = {
    Environment = "Production"
    Project     = "CustomerAPI"
  }
}
```

### Secure Static Website Hosting

```hcl
module "static_website" {
  source = "../../patterns/route53-waf-cloudfront-s3"

  domain_name     = "example.com"
  sub_domain      = "www"
  
  # S3 configuration
  bucket_name     = "www-example-com"
  enable_encryption = true
  
  # CloudFront configuration
  enable_waf      = true
  price_class     = "PriceClass_100"
  
  # Route53 configuration
  create_route53_records = true
  route53_zone_id        = "Z1234567890ABC"
  
  tags = {
    Environment = "Production"
    Project     = "CorporateWebsite"
  }
}
```

## 🌟 Best Practices Implemented

These templates implement several AWS best practices:

<table>
  <tr>
    <th>Category</th>
    <th>Practices</th>
  </tr>
  <tr>
    <td><strong>🔒 Security</strong></td>
    <td>
      <ul>
        <li>Principle of least privilege for IAM roles</li>
        <li>Encryption at rest for all data stores</li>
        <li>TLS for all communications</li>
        <li>WAF protection for web-facing resources</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><strong>🔄 Reliability</strong></td>
    <td>
      <ul>
        <li>Automatic retries and dead-letter queues</li>
        <li>CloudWatch alarms for monitoring</li>
        <li>Proper error handling</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><strong>⚡ Performance</strong></td>
    <td>
      <ul>
        <li>Appropriate caching strategies</li>
        <li>Optimized database indexes</li>
        <li>Auto-scaling configurations</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><strong>💰 Cost Optimization</strong></td>
    <td>
      <ul>
        <li>Pay-per-request pricing models</li>
        <li>Resource tagging for cost allocation</li>
        <li>Right-sized resources</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td><strong>🔧 Operational Excellence</strong></td>
    <td>
      <ul>
        <li>Comprehensive logging</li>
        <li>Infrastructure as Code</li>
        <li>Consistent tagging strategy</li>
      </ul>
    </td>
  </tr>
</table>

## ✅ AWS Well-Architected Framework Alignment

Our templates are designed with the [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/) in mind:

| Pillar | Implementation |
|--------|----------------|
| **Operational Excellence** | Infrastructure as Code, consistent tagging, thorough documentation |
| **Security** | Least-privilege IAM, encrypted data, WAF protection, TLS enforcement |
| **Reliability** | Multi-AZ deployments, automatic retries, DLQs, monitoring & alarming |
| **Performance Efficiency** | Auto-scaling, caching strategies, optimized data access patterns |
| **Cost Optimization** | Serverless architectures, pay-per-request models, right-sized resources |
| **Sustainability** | Efficient resource utilization, serverless to minimize idle resources |

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

These templates are inspired by AWS Well-Architected Framework and real-world AWS Solutions Architecture patterns.

---

<div align="center">
  <img src="https://d0.awsstatic.com/logos/powered-by-aws.png" alt="Powered by AWS Cloud Computing" width="150px">
  <p>Built with ❤️ by AWS Solutions Architects</p>
</div>

# API Gateway with Direct DynamoDB Integration Example

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

