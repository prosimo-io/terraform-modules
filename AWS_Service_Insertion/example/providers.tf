provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
  region                   = var.aws_region
}

terraform {
  required_providers {
    prosimo = {
      version = "1.0.0"
      source  = "prosimo.io/prosimo/prosimo"
    }
  }
}