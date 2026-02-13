terraform {
  backend "s3" {
    bucket         = "toptal-3tier-tfstate-453410498558"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "toptal-3tier-tflock"
    encrypt        = true
  }
}