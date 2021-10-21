module "ecr" {
  source = "cloudposse/ecr/aws"
  name                   = "${local.container_repo_name}"
  principals_full_access = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}
