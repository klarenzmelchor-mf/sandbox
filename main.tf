# module "inspector" {
#   source = "./modules/inspector"
# }

# module "macie" {
#   source = "./modules/macie"

#   s3_bucket_name = "microfocus-multi-security-macie"
#   kms_key_name   = "microfocus-multi-security-macie"
#   aws_account_id = "621270530972"
#   aws_region     = "eu-north-1"
  
# }

# module "lambda" {
#   source = "./modules/resource-tagging"

#   name = "microfocus-multi-security-resource-tagging"
#   aws_account_id = "621270530972"
#   aws_region     = "eu-north-1"
  
# }

module "kms_master_key" {
  source = "git::git@github.com:gruntwork-io/module-security.git//modules/kms-master-key?ref=v0.51.0"

  # name                                  = "cmk-scratch"
  # aws_account_id                        = "621270530972"
  # cmk_administrator_iam_arns            = ["arn:aws:iam::621270530972:user/klarenz.melchor@microfocus.com"]
  # cmk_user_iam_arns                     = ["arn:aws:iam::621270530972:user/klarenz.melchor@microfocus.com"]
  # allow_manage_key_permissions_with_iam = true

  customer_master_keys = {
    "cmk-scratch" = {
      cmk_administrator_iam_arns            = ["arn:aws:iam::621270530972:user/klarenz.melchor@microfocus.com"]
      cmk_user_iam_arns                     = [{
      name         = ["arn:aws:iam::621270530972:user/klarenz.melchor@microfocus.com"]
      conditions = [{
        test     = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values = ["true"]
        }]
      }]
      cmk_external_user_iam_arns            = []
      allow_manage_key_permissions_with_iam = true
      cmk_service_principals = [{
        name = "events.amazonaws.com"
        actions = ["kms:GenerateDataKey*", "kms:Decrypt"]
        conditions = []
      }]
    }
  }
}