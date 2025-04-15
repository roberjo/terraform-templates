# Contributing to AWS Terraform Templates

Thank you for your interest in contributing to this repository! This document outlines the process and guidelines for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions within this project's community.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check if the issue already exists in the Issues tab
2. If not, create a new issue with:
   - A clear title and description
   - Steps to reproduce the issue
   - Expected vs actual behavior
   - Terraform and AWS provider versions

### Contributing Code

1. **Fork the Repository**
   - Create a fork of this repository to your personal GitHub account

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR-USERNAME/terraform-templates.git
   cd terraform-templates
   ```

3. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make Your Changes**
   - Follow the code style guidelines below
   - Ensure all tests pass
   - Add tests for new features

5. **Commit Your Changes**
   - Use clear commit messages following the conventional commits standard
   ```bash
   git commit -m "feat: add support for X feature"
   ```

6. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request**
   - Open a PR against the main branch
   - Provide a clear description of the changes
   - Reference any related issues

## Code Style Guidelines

### Terraform Style

1. **File Structure**
   - Use standard Terraform file naming (`main.tf`, `variables.tf`, `outputs.tf`)
   - Group related resources in separate files

2. **Formatting**
   - Run `terraform fmt` before committing
   - Use 2-space indentation
   - Align variable and output declarations

3. **Naming Conventions**
   - Use snake_case for resources, variables, and outputs
   - Use descriptive names that convey purpose
   - Prefix module resources with the module name where appropriate

4. **Comments**
   - Comment complex logic
   - Add descriptions to all variables and outputs
   - Document module usage in a README.md file

### Documentation

1. **README Files**
   - Each module and pattern should have its own README.md
   - Include usage examples, requirements, and inputs/outputs

2. **Variable Documentation**
   - All variables should have descriptions
   - Include type constraints and default values where appropriate

## Testing Guidelines

1. **Manual Testing**
   - Test all changes in a real AWS environment before submitting

2. **Automated Testing**
   - Add terratest tests for significant changes
   - Ensure existing tests pass

## Review Process

1. All PRs require at least one review
2. Automated checks must pass
3. Significant changes may require additional testing or documentation

Thank you for contributing to make this project better! 