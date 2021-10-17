terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  repository_name = var.repository_name
  build_name      = local.repository_name
  image_tag       = var.image_tag
  bucket_name = "flask-app-bb97ca27"
  tagPrefixList   = concat(var.tagPrefixList, ["ts"])
  log_tracker_defaults = {
    initial_timeout = 180
    update_timeout  = 300
    sleep_interval  = 30
    init_wait_time  = 15
    max_retry_count = 4
    print_dots      = false
  }
  log_tracker = merge(local.log_tracker_defaults, var.log_tracker)
}

module "s3_bucket" {

  source = "cloudposse/s3-bucket/aws"

  acl                      = "private"
  enabled                  = true
  user_enabled             = true
  versioning_enabled       = false
  allowed_bucket_actions   = ["s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"]
  name                     = local.bucket_name
  stage                    = "test"
  namespace                = "eg"

  privileged_principal_arns = {
    "arn:aws:iam::406310692709:root" = [""]
  }
  privileged_principal_actions = [
    "s3:*"
  ]
}
