module "ecr" {
  source = "cloudposse/ecr/aws"
  name                   = "${local.container_repo_name}"
  principals_full_access = ["arn:aws:iam::${local.account_id}:root"]
}
