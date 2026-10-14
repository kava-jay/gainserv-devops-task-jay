terraform {
  backend "s3" {
    bucket         = "gainserv-devops-terraform-state-REPLACE"
    key            = "gainserv/dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "gainserv-terraform-locks"
    encrypt        = true
  }
}
