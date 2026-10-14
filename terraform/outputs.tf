output "vpc_id" {
  description = "VPC ID."
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.network.private_subnet_ids
}

output "security_group_ids" {
  description = "Security group IDs by name."
  value = {
    for name, sg in module.security_groups :
    name => sg.security_group_id
  }
}

output "application_pod_identity_role_arn" {
  description = "IAM role ARN for the application, when enabled."
  value       = var.enable_pod_identity ? module.application_iam[0].role_arn : null
}
