# -----------------------------------------------------------------------------
# DEFAULT VARIABLES FOR THE ENTIRE INFRASTRUCTURE STACK
# -----------------------------------------------------------------------------

variable "service_name" {
  type        = string
  description = "The name of the service this infrastructure is provided for"
}

variable "environment" {
  type        = string
  description = "The name of the environment to deploy to"
}

variable "region" {
  type        = string
  description = "The AWS region this service is deployed to"
  default     = "eu-west-2"
}

variable "allowed_account_id" {
  type        = string
  description = "The AWS account where resources will be created in"
}

variable "repo_name" {
  type        = string
  description = "git repository that manages the resources (used in tagging)"
  default     = "https://github.com/jonas-meyer/property-scraping-infra"
}

variable "common_tags" {
  type        = map(string)
  description = "Common Aws resource tags"
  default     = {}
}

variable "bucket" {
  type = string
  description = "The bucket in which the remote state of the -infra project resides"
}

variable "key" {
  type = string
  description = "The key of the S3-object representing the remote state of the -infra project inside shared_remote_backend_bucket"
}

variable "dynamodb_table" {
  type = string
  description = "The dynamodb table in which the remote lock of the -infra project resides"
}

variable "schedule_expression" {
  type        = string
  description = "The schedule at which the listing getter lambda should be invoked"
}


# -----------------------------------------------------------------------------
# CONSTANTS
# -----------------------------------------------------------------------------

locals {
  deployment_name = "property-scraping"
  resource_prefix = "${var.service_name}-${var.environment}"
  common_tags = merge(var.common_tags, {
    deployment  = var.service_name
    environment = var.environment
    managed_by  = var.repo_name
  })
}
