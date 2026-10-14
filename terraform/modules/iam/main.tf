data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    sid     = "AllowEKSPodIdentity"
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"
      values   = ["gainserv"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"
      values   = ["gainserv-app"]
    }
  }
}

resource "aws_iam_role" "pod_identity" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = merge(var.tags, {
    Name = var.name
  })
}

data "aws_iam_policy_document" "application" {
  statement {
    sid       = "ReadApplicationObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_bucket_arn}/app/*"]
  }
}

resource "aws_iam_role_policy" "application" {
  name   = "${var.name}-s3-read"
  role   = aws_iam_role.pod_identity.id
  policy = data.aws_iam_policy_document.application.json
}
