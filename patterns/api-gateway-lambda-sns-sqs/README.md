# API Gateway with Lambda processor that writes to SNS topic and SQS queue

This Terraform pattern creates an API Gateway that integrates with a lambda that processes the incoming message and writes it to a SNS topic for fanout and then to a SQS queue for message processing.

## Architecture

![Architecture Diagram](./architecture.png)

This pattern sets up the following components:

- An Amazon API Gateway REST API with a `/messages` endpoint
- A Lambda function to process API requests and publish to SNS
- An SNS topic for message fanout capability
- An SQS queue that subscribes to the SNS topic
- A separate Lambda function for processing messages from the SQS queue
- Dead Letter Queue for handling failed message processing
- Appropriate IAM permissions connecting all services

## Features

- **Serverless**: Fully serverless architecture with no infrastructure to manage
- **Scalable**: Automatically scales with incoming traffic
- **Decoupled**: Message producers and consumers are decoupled via SNS and SQS
- **Resilient**: Includes dead-letter queues and error handling
- **Secure**: Proper IAM permissions and encryption at rest
- **Flexible**: CORS support and customizable API configuration

## Components in Detail

### API Gateway

The pattern creates a REST API with a configurable endpoint path (default: `/messages`) that accepts HTTP POST requests. The API can be configured with:

- Custom domain with ACM certificate support
- CORS configuration for cross-origin requests
- API key authorization (optional)
- WAF integration for security (optional)

### API Handler Lambda

This Lambda function processes incoming API requests and publishes them to an SNS topic. It includes:

- Error handling for malformed requests
- Message formatting before publishing to SNS
- Addition of metadata to messages

### SNS Topic

The SNS topic enables message fanout, allowing you to:

- Distribute messages to multiple subscribers
- Filter messages with message attributes
- Retain a copy of all messages in the main processing queue

### SQS Queue

The SQS queue receives messages from SNS and provides:

- Message buffering for processing at your own pace
- At-least-once delivery guarantee
- Configurable visibility timeout and retention
- Server-side encryption

### SQS Processor Lambda

This Lambda function processes messages from the SQS queue with:

- Batch processing capabilities
- Error handling per message
- Partial batch failure support
- Custom processing logic capabilities

### Dead Letter Queue

The pattern includes a Dead Letter Queue (DLQ) for handling failed message processing:

- Captures messages that couldn't be processed
- Configurable retry attempts
- Extended message retention for later analysis

## Use Cases

This pattern is ideal for:

1. Asynchronous API processing where responses don't depend on immediate processing
2. Workloads with varying or unpredictable processing requirements
3. Systems that need decoupling between producers and consumers
4. Applications requiring reliable message delivery with retry capability
5. Multi-step processing workflows

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`
2. Modify the variables in `terraform.tfvars` to match your requirements
3. Prepare the Lambda deployment packages:
   - Place your API handler code in a zip file
   - Place your SQS processor code in a zip file
   - Update the `lambda_filename` and `sqs_processor_filename` variables
4. Initialize and apply the Terraform configuration:

```bash
terraform init
terraform apply
```

## API Integration

### Making Requests

Send POST requests to the API endpoint with a JSON payload:

```
POST /messages HTTP/1.1
Host: <api-id>.execute-api.<region>.amazonaws.com
Content-Type: application/json

{
  "type": "order",
  "orderId": "12345",
  "data": {
    "items": ["item1", "item2"],
    "total": 29.99
  }
}
```

### Response Format

Successful responses will include:

```json
{
  "message": "Message processed successfully",
  "messageId": "a1b2c3d4-5678-90ab-cdef-11223344556677"
}
```

## Lambda Code Templates

The pattern includes template Lambda handlers in the `templates` directory:

- `api-handler.js`: Example API Lambda handler
- `sqs-processor.js`: Example SQS message processor

These can be used as starting points for your custom implementation.

## Customization Options

### Message Filtering

Configure SNS subscription filter policies to route different message types:

```hcl
sns_subscription_filter_policy = {
  "MessageType": ["order", "notification"]
}
```

### Scaling Considerations

- Adjust `lambda_memory_size` and `sqs_processor_memory_size` based on processing needs
- Set appropriate `sqs_visibility_timeout` based on processing time
- Configure `sqs_processor_batch_size` based on message processing complexity

## Security Considerations

- The pattern supports encryption at rest for SNS and SQS
- Configure the `api_authorization_type` for API security
- Set appropriate IAM permissions by reviewing the Lambda policies

## Outputs

The pattern provides the following outputs:

- API Gateway invoke URL and endpoint URL
- Lambda function ARNs and names
- SNS topic ARN and name
- SQS queue URL and ARN
- DLQ information

## License

This module is licensed under the MIT License.