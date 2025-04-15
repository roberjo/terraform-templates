# EventBridge Scheduler that triggers a Lambda processor that writes to SNS topic and SQS queue

This Terraform pattern creates a EventBridge Job Scheduler that runs on a cron schedule to trigger a lambda that calls a third party web api to get a large dataset and then processes the incoming data and writes individual data messages to a SNS topic for fanout and then to a SQS queue for message processing of each record from the larger set.

## Architecture

![Architecture Diagram](./architecture.png)

This pattern sets up the following components:

- An Amazon EventBridge Scheduler that runs on a configurable cron schedule
- A Lambda function that retrieves data from a third-party API endpoint
- An SNS topic for message fanout capability
- An SQS queue that subscribes to the SNS topic
- An optional separate Lambda function for processing messages from the SQS queue
- Dead Letter Queues for handling failed message processing
- Appropriate IAM permissions connecting all services

## Features

- **Serverless**: Fully serverless architecture with no infrastructure to manage
- **Scheduled**: Automated data collection on customizable schedules
- **Scalable**: Automatically scales to handle large datasets
- **Decoupled**: Data collection and processing are decoupled via SNS and SQS
- **Resilient**: Includes dead-letter queues and error handling
- **Secure**: Proper IAM permissions and encryption at rest
- **Flexible**: Configurable batch sizes and processing options

## Components in Detail

### EventBridge Scheduler

The pattern creates an EventBridge scheduler that runs based on a configurable cron expression:

- Flexible scheduling options using cron or rate expressions
- Customizable input parameters to the Lambda function
- Optional flexible time window configuration
- State management (ENABLED/DISABLED)

### API Processor Lambda

This Lambda function retrieves data from an external API and publishes it to an SNS topic. It includes:

- External API connection handling
- Error handling for API failures
- Support for authentication with the external API
- Message partitioning for large datasets
- Message formatting before publishing to SNS

### SNS Topic

The SNS topic enables message fanout, allowing you to:

- Distribute messages to multiple subscribers
- Filter messages with message attributes
- Retain a copy of all messages in the main processing queue
- Optional FIFO capability for ordered message delivery

### SQS Queue

The SQS queue receives messages from SNS and provides:

- Message buffering for processing at your own pace
- At-least-once delivery guarantee
- Configurable visibility timeout and retention
- Server-side encryption

### SQS Processor Lambda

The optional SQS processor Lambda function processes messages from the SQS queue with:

- Batch processing capabilities
- Error handling per message
- Partial batch failure support
- Custom processing logic capabilities

### Dead Letter Queues

The pattern includes Dead Letter Queues (DLQs) for handling failed message processing:

- Separate DLQs for SNS and SQS
- Configurable retry attempts
- Extended message retention for later analysis

## Use Cases

This pattern is ideal for:

1. Periodically collecting data from external APIs for analytics or reporting
2. Scheduled data synchronization between systems
3. Batch processing jobs that need to run on a regular schedule
4. Event-driven workflows that begin with a scheduled trigger
5. ETL processes that need to transform and load data from external sources

## Usage

1. Copy the `terraform.tfvars.example` file to `terraform.tfvars`
2. Modify the variables in `terraform.tfvars` to match your requirements
3. Prepare the Lambda deployment packages:
   - Place your API processor code in a zip file or use the template
   - Place your SQS processor code in a zip file or use the template
   - Update the lambda source paths in the variables
4. Initialize and apply the Terraform configuration:

```bash
terraform init
terraform apply
```

## API Integration

### API Configuration

Configure your external API endpoint in the variables:

```hcl
api_endpoint = "https://api.example.com/data"
api_key      = "your-api-key"
```

### Scheduler Input

The scheduler passes the following input to the Lambda function:

```json
{
  "api_endpoint": "https://api.example.com/data",
  "api_key": "your-api-key",
  "batch_size": 100
}
```

## Lambda Code Templates

The pattern includes template Lambda handlers in the `templates` directory:

- `api-processor.js`: Example API Lambda handler for retrieving and processing data
- `sqs-processor.js`: Example SQS message processor

These can be used as starting points for your custom implementation.

## Customization Options

### Scheduler Configuration

Configure the scheduler with different schedules:

```hcl
schedule_expression = "cron(0 12 * * ? *)" # Run daily at noon UTC
```

### Batch Processing

Adjust batch sizes for your processing needs:

```hcl
batch_size = 100
sqs_processor_batch_size = 10
```

### Scaling Considerations

- Adjust `lambda_memory_size` and `sqs_processor_memory_size` based on data volume
- Set appropriate `sqs_visibility_timeout` based on processing time
- Configure `sqs_processor_batch_size` based on message processing complexity

## Security Considerations

- The pattern supports encryption at rest for SNS and SQS
- API keys can be stored in AWS Secrets Manager or SSM Parameter Store
- Lambda function has minimal IAM permissions following principle of least privilege

## Outputs

The pattern provides the following outputs:

- Scheduler ARN and name
- Lambda function ARNs and names
- SNS topic ARN and name
- SQS queue URL and ARN
- DLQ information

## License

This module is licensed under the MIT License.