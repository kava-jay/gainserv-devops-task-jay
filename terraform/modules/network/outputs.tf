output "vpc_id" {
  description = "Created VPC ID."
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "Map of private subnet IDs."
  value = {
    for key, subnet in aws_subnet.private :
    key => subnet.id
  }
}

output "vpc_cidr" {
  description = "Created VPC CIDR."
  value       = aws_vpc.this.cidr_block
}
