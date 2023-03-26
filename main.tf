terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    #properties can be found in /envs/{ENVIRONMENT}/terraform_backend_config.tfvars
  }

  required_version = "~> 1.4.2"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
  allowed_account_ids = [var.allowed_account_id]
}

module "aws_oidc_github" {
  source  = "unfunco/oidc-github/aws"
  version = "1.2.1"

  github_repositories = [
    "jonas-meyer/property-scraping-service:ref:refs/heads/main",
  ]
  attach_read_only_policy = false

  iam_role_inline_policies = {
    "example_inline_policy" : data.aws_iam_policy_document.github.json
  }
}

data "aws_iam_policy_document" "github" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:ListBucket",
      "iam:ListRoles",
      "lambda:UpdateFunctionCode",
    ]
    resources = [
      aws_s3_bucket.lambda_code.arn,
      aws_lambda_function.listing-getter-lambda.arn
    ]
  }
  statement {
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.lambda_code.arn}/*"
    ]
  }
}