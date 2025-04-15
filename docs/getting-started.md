# Getting Started with AWS Terraform Templates

This guide will help you get started with using the AWS Solutions Architect Terraform templates in this repository.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1. **Terraform** (v1.0 or later)
   ```bash
   # Check Terraform version
   terraform -v
   ```

2. **AWS CLI** configured with appropriate credentials
   ```bash
   # Configure AWS CLI
   aws configure
   ```

3. **Git** for cloning the repository
   ```bash
   # Clone this repository
   git clone <repository-url>
   cd terraform-templates
   ```

## Setting Up a New Project

1. **Choose an architecture pattern** that suits your needs from the `patterns/` directory.

2. **Copy the pattern files** to your project directory:
   ```bash
   cp -r patterns/[selected-pattern]/* your-project-directory/
   ```

3. **Initialize Terraform**:
   ```bash
   cd your-project-directory
   terraform init
   ```

4. **Customize the configuration**:
   - Edit `terraform.tfvars` to set your specific variables
   - Modify any resources as needed for your use case

5. **Generate and review an execution plan**:
   ```bash
   terraform plan -out=tfplan
   ```

6. **Apply the configuration**:
   ```bash
   terraform apply tfplan
   ```

## Using Modules Individually

If you want to use individual modules instead of complete patterns:

1. **Reference modules** in your Terraform configuration:
   ```hcl
   module "api_gateway" {
     source = "github.com/your-username/terraform-templates//modules/api-gateway?ref=v1.0.0"
     
     # Module specific variables
     domain_name = "api.example.com"
     # Other variables...
   }
   ```

2. **Initialize and apply** as usual:
   ```bash
   terraform init
   terraform apply
   ```

## Best Practices

1. **Use a remote backend** for state storage (e.g., S3 with DynamoDB locking)
2. **Version control** your Terraform configurations
3. **Use workspaces** for managing different environments
4. **Lock module versions** to ensure reproducible deployments
5. **Document your variables** in a `variables.tf` file

## Troubleshooting

### Common Issues

1. **Authentication Errors**:
   - Ensure AWS credentials are correctly configured
   - Check IAM permissions for the AWS services being used

2. **Resource Already Exists**:
   - Use `terraform import` to bring existing resources under Terraform management

3. **Dependency Issues**:
   - Check the module requirements in `versions.tf`
   - Ensure you're using a compatible Terraform version

For more help, refer to the README.md files in each pattern directory or raise an issue on the repository. 