variable "name" {
  description = "Name of the IAM role."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket the application may read."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:s3:::[a-z0-9][a-z0-9.-]+$", var.s3_bucket_arn))
    error_message = "Provide a valid S3 bucket ARN."
  }
}
