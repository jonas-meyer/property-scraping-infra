terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57.1"
    }
    archive = {
      source = "hashicorp/archive"
      version = "2.3.0"
    }
  }

  backend "s3" {
    #properties can be found in /envs/{ENVIRONMENT}/terraform_backend_config.tfvars
  }

  required_version = "~> 1.3.9"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
  allowed_account_ids = [var.allowed_account_id]
}