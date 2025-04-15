# AWS Solutions Architect Terraform Templates

A comprehensive collection of production-ready Terraform templates for common AWS cloud architecture patterns. This repository serves as both a reference implementation and a starting point for your AWS infrastructure projects.

## Repository Structure

```
terraform-templates/
├── modules/            # Reusable Terraform modules
├── patterns/           # Complete architecture patterns
├── examples/           # Example implementations
└── docs/               # Additional documentation
```

## Available Architecture Patterns

1. **API Gateway with Microservices and DynamoDB**
   - API Gateway with custom domain
   - Lambda-based microservices
   - DynamoDB for data persistence
   - Complete IAM configuration

2. **API Gateway with Direct DynamoDB Integration**
   - API Gateway with custom domain
   - Direct DynamoDB integration using VTL templates
   - DynamoDB table with optimized filtering capabilities

3. **Event-Driven Processing Pipeline**
   - API Gateway ingestion endpoint
   - Lambda processor
   - SNS topic for fanout
   - SQS queue for reliable processing
   - Lambda consumer

4. **Scheduled External Data Processing**
   - EventBridge scheduler
   - Lambda data processor
   - 3rd party API integration
   - SNS notification system
   - SQS queue for asynchronous processing

5. **Secure Static Website Hosting**
   - Route53 hosted zone configuration
   - AWS WAF integration
   - CloudFront distribution
   - S3 bucket with KMS encryption
   - Secure content delivery

## Core Modules

This repository includes several reusable modules that can be combined to create custom infrastructure:

- **API Gateway**: Create REST APIs with custom domains and proper configuration
- **Lambda**: Deploy serverless functions with appropriate IAM roles and logging
- **DynamoDB**: Set up tables with optimized indexes and encryption
- **S3**: Configure buckets with various access patterns and encryption options
- **CloudFront**: Set up distributions with proper cache and security settings
- **Route53**: Configure DNS settings for your domains
- **WAF**: Implement web application firewall protection
- **SNS/SQS**: Create messaging infrastructure for event-driven architectures
- **EventBridge**: Set up event buses and schedulers

## Getting Started

See the [Getting Started Guide](./docs/getting-started.md) for detailed instructions on how to use these templates.

### Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/terraform-templates.git
   cd terraform-templates
   ```

2. Choose a pattern or example to deploy:
   ```bash
   cd examples/api-gateway-microservices-dynamodb
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Customize the variables:
   ```bash
   # Edit terraform.tfvars with your specific values
   ```

5. Deploy the infrastructure:
   ```bash
   terraform apply
   ```

## Prerequisites

- Terraform v1.0+
- AWS CLI configured with appropriate permissions
- Basic understanding of AWS services and Terraform

## Usage Examples

Each architecture pattern includes detailed documentation and examples. See the `examples/` directory for complete implementations.

## Best Practices Implemented

These templates implement several AWS best practices:

1. **Security**:
   - Principle of least privilege for IAM roles
   - Encryption at rest for all data stores
   - TLS for all communications
   - WAF protection for web-facing resources

2. **Reliability**:
   - Automatic retries and dead-letter queues
   - CloudWatch alarms for monitoring
   - Proper error handling

3. **Performance Efficiency**:
   - Appropriate caching strategies
   - Optimized database indexes
   - Auto-scaling configurations

4. **Cost Optimization**:
   - Pay-per-request pricing models where appropriate
   - Resource tagging for cost allocation
   - Right-sized resources

5. **Operational Excellence**:
   - Comprehensive logging
   - Infrastructure as Code
   - Consistent tagging strategy

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

These templates are inspired by AWS Well-Architected Framework and real-world AWS Solutions Architecture patterns. 

