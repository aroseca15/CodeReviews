terraform {
  required_providers {
    aws = "~> 4.3.0"
  }

  backend "s3" {
    bucket         = "telepsycrx-backend-tfstate"
    key            = "telepsycrx-backend.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "telepsycrx-backend-tf-state-lock"
  }
}

provider "aws" {
  region = "us-west-2"
}
# 2.54.0

locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }

}

data "aws_region" "current" {}

