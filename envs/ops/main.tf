locals {
  account_id          = data.aws_caller_identity.current.account_id
  tfstate_bucket_name = "tfstate-seithus1"
  tfplan_bucket_name  = "tfplan-thi2fizo"
  oidc_subjects       = ["repo:ciloholic/multi_digger:environment:sandbox"]
}

data "aws_caller_identity" "current" {}

##################################################
# GitHub OIDC Provider
##################################################
resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

##################################################
# tfstate格納用S3バケット
##################################################
module "tfstate_s3_bucket" {
  source = "../../modules/opentaco/s3/tfstate/v1"

  s3_bucket_name = local.tfstate_bucket_name
}

##################################################
# tfplan格納用S3バケット
##################################################
module "tfplan_s3_bucket" {
  source = "../../modules/opentaco/s3/tfplan/v1"

  s3_bucket_name  = local.tfplan_bucket_name
  expiration_days = 7
}

##################################################
# GitHub Actions OIDC用IAMロール
##################################################
module "gha_role" {
  source = "../../modules/opentaco/gha_role/v1"

  name               = "opentaco-gha-role-sandbox"
  account_id         = local.account_id
  subjects           = local.oidc_subjects
  roles_to_assume    = ["arn:aws:iam::${local.account_id}:role/opentaco-tfstate-role"]
  tfplan_bucket_name = module.tfplan_s3_bucket.name
}

##################################################
# tfstate操作用IAMロール
##################################################
module "tfstate_role" {
  source = "../../modules/opentaco/tfstate_role/v1"

  name                = "opentaco-tfstate-role-sandbox"
  account_id          = local.account_id
  gha_role            = module.gha_role.name
  tfstate_bucket_name = local.tfstate_bucket_name
}
