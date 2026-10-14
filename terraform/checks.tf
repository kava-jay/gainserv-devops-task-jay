check "pod_identity_configuration" {
  assert {
    condition = (
      !var.enable_pod_identity ||
      var.application_s3_bucket_arn != null
    )
    error_message = "application_s3_bucket_arn is required when enable_pod_identity is true."
  }

  assert {
    condition = (
      !var.create_pod_identity_association ||
      (var.enable_pod_identity && var.eks_cluster_name != null)
    )
    error_message = "Pod Identity association requires enable_pod_identity=true and eks_cluster_name."
  }
}
