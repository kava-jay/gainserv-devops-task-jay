variable "name" {
  description = "Security group name."
  type        = string
}

variable "description" {
  description = "Security group description."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "ingress_rules" {
  description = "Map of allowed inbound TCP rules."
  type = map(object({
    port        = number
    cidr_blocks = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}
