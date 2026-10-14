module "network" {
  source = "./modules/network"

  providers = {
    aws = aws.primary
  }

  name            = local.name_prefix
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  tags            = local.common_tags
}

locals {
  security_groups = {
    application = {
      description = "Application workload security group"

      ingress_rules = {
        application_http = {
          port        = 3000
          cidr_blocks = [var.vpc_cidr]
        }
      }
    }

    internal = {
      description = "Internal service security group"

      ingress_rules = {
        internal_https = {
          port        = 443
          cidr_blocks = [var.vpc_cidr]
        }
      }
    }
  }
}

module "security_groups" {
  source = "./modules/security-group"

  for_each = local.security_groups

  providers = {
    aws = aws.primary
  }

  name          = "${local.name_prefix}-${each.key}-sg"
  description   = each.value.description
  vpc_id        = module.network.vpc_id
  ingress_rules = each.value.ingress_rules
  tags          = local.common_tags
}

module "application_iam" {
  source = "./modules/iam"

  count = var.enable_pod_identity ? 1 : 0

  providers = {
    aws = aws.primary
  }

  name          = "${local.name_prefix}-app-pod-identity"
  tags          = local.common_tags
  s3_bucket_arn = var.application_s3_bucket_arn
}

resource "aws_eks_pod_identity_association" "application" {
  count = var.create_pod_identity_association ? 1 : 0

  provider = aws.primary

  cluster_name    = var.eks_cluster_name
  namespace       = "gainserv"
  service_account = "gainserv-app"
  role_arn        = module.application_iam[0].role_arn

  tags = local.common_tags

  lifecycle {
    precondition {
      condition = (
        var.enable_pod_identity &&
        var.eks_cluster_name != null &&
        trimspace(coalesce(var.eks_cluster_name, "")) != ""
      )
      error_message = "Enable Pod Identity and provide a valid EKS cluster name before creating an association."
    }
  }
}