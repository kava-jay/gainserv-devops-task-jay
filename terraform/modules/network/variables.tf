variable "name" {
  description = "Name prefix for network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR."
  type        = string
}

variable "private_subnets" {
  description = "Map of private subnets."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
}
