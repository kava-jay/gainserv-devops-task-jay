# Gainserv Terraform Infrastructure

Terraform configuration for the Gainserv DevOps practical assignment.

## Architecture

- AWS VPC with private subnets in two Availability Zones
- Reusable security group module instantiated using `for_each`
- Reusable IAM module for EKS Pod Identity
- Explicit primary and secondary AWS provider aliases
- Consistent naming and tagging through Terraform locals
- S3 remote state with DynamoDB locking for assignment compatibility

## Validation

Run from the `terraform/` directory:

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate


