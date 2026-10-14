locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Assignment  = "Gainserv-DevOps-Practical"
  }

  resource_names = {
    vpc = "${local.name_prefix}-vpc"
  }
}
