output "role_arn" {
  description = "IAM role ARN for EKS Pod Identity."
  value       = aws_iam_role.pod_identity.arn
}

output "role_name" {
  description = "IAM role name."
  value       = aws_iam_role.pod_identity.name
}
