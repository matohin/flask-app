data "aws_caller_identity" "current" {}

locals {
  container_repo_name = "flask-app-ecr-repo"
  account_id = "${data.aws_caller_identity.current.account_id}"
  service_name = "flask-app"
}

module "flask-app-project" {

  source = "lgallard/codebuild/aws"

  name        = "flask-app"
  description = "Minimal flask app"

  # CodeBuild Source
  codebuild_source_version = "main"
  codebuild_source = {
    type            = "GITHUB"
    location        = "https://github.com/matohin/flask-app.git"
    git_clone_depth = 1

    git_submodules_config = {
      fetch_submodules = true
    }
  }

  # Environment
  environment = {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:2.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # Environment variables
    variables = [

      {
        name  = "AWS_DEFAULT_REGION"
        value = var.aws_region
      },
      {
        name  = "AWS_ACCOUNT_ID"
        value = local.account_id
      },
      {
        name  = "IMAGE_REPO_NAME"
        value = local.container_repo_name
      },
      {
        name  = "IMAGE_TAG"
        value = "latest"
      }
    ]
  }

  // Artifacts
  artifacts = {
    location  = aws_s3_bucket.flask-app-project.bucket
    type      = "S3"
    path      = "/"
    packaging = "ZIP"
  }

  // Cache
  cache = {
    type     = "S3"
    location = "${aws_s3_bucket.flask-app-project.bucket}/cache"
  }

  // Logs
  s3_logs = {
    status   = "ENABLED"
    location = "${aws_s3_bucket.flask-app-project.bucket}/build-log"
  }

  // Tags
  tags = {
    Environment = "project"
    owner       = "flask-app"
  }

}


resource "aws_s3_bucket" "flask-app-project" {
  bucket = "flask-app-bucket-2afcb572"
  acl    = "private"
}

