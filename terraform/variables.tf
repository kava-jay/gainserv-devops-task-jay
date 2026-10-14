variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "gainserv"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "Primary AWS region."
  type        = string
  default     = "ap-south-1"
}

variable "secondary_aws_region" {
  description = "Secondary AWS region."
  type        = string
  default     = "ap-south-2"
}

variable "vpc_cidr" {
  description = "CIDR range for the application VPC."
  type        = string
  default     = "10.20.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && tonumber(split("/", var.vpc_cidr)[1]) >= 16 && tonumber(split("/", var.vpc_cidr)[1]) <= 24
    error_message = "VPC CIDR must be valid and use a prefix between /16 and /24."
  }
}

variable "private_subnets" {
  description = "Private subnet configuration."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    private_a = {
      cidr_block        = "10.20.1.0/24"
      availability_zone = "ap-south-1a"
    }
    private_b = {
      cidr_block        = "10.20.2.0/24"
      availability_zone = "ap-south-1b"
    }
  }
}

variable "enable_pod_identity" {
  description = "Whether to create the example Pod Identity IAM role."
  type        = bool
  default     = false
}

variable "application_s3_bucket_arn" {
  description = "Optional S3 bucket ARN for application read access."
  type        = string
  default     = null
}

variable "eks_cluster_name" {
  description = "Existing EKS cluster name for Pod Identity association."
  type        = string
  default     = null
}

variable "create_pod_identity_association" {
  description = "Create Pod Identity association for an existing EKS cluster."
  type        = bool
  default     = false
}
