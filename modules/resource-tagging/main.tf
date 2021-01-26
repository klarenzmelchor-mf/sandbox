# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAMBDA FUNCTION THAT ALLOWS TO INVOKE IG/RPT REST API using PASSWORD OR CLIENT OATH2 grant
# 
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

# provider "aws" {
#   # The AWS region in which all resources will be created
#   region = var.aws_region

#   # Provider version 2.X series is the latest, but has breaking changes with 1.X series.
#   version = "~> 2.6"

#   # Only these AWS Account IDs may be operated on by this template
#   allowed_account_ids = [var.aws_account_id]
# }

# # ---------------------------------------------------------------------------------------------------------------------
# # CONFIGURE REMOTE STATE STORAGE
# # ---------------------------------------------------------------------------------------------------------------------

# terraform {
#   # The configuration for this backend will be filled in by Terragrunt
#   backend "s3" {}

#   # Only allow this Terraform version. Note that if you upgrade to a newer version, Terraform won't allow you to use an
#   # older version, so when you upgrade, you should upgrade everyone on your team and your CI servers all at once.
#   required_version = "= 0.12.29"
# }



# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "lambda" {
  source = "git::git@github.com:gruntwork-io/package-lambda.git//modules/lambda?ref=v0.9.2"

  name        = var.name
  description = "lambda function that creates a custom tag on all resources"

  source_path = "${path.module}/python"
  runtime     = "python3.7"
  handler     = "index.handler"

  timeout     = 90
  memory_size = 128

  environment_variables= {
      tag_key   = var.tag_key
      tag_value = var.tag_value
    }
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION TO ADD TAGS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "create_tag" {
  role   = module.lambda.iam_role_id
  policy = data.aws_iam_policy_document.create_tag.json
}

data "aws_iam_policy_document" "create_tag" {
  statement {
    effect    = "Allow"
    actions   = [
      "aws:createTags",
      "ec2:*",
      "elasticloadbalancing:*",
      "cloudwatch:*",
      "s3:*",
      "eks:*",
      "rds:*"
      ]
    resources = ["*"]
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE CLOUDWATCH EVENT
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_event_target" "lambda" {
  arn  = module.lambda.function_arn
  rule = aws_cloudwatch_event_rule.lambda.id
}

resource "aws_lambda_permission" "cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda.arn
}

resource "aws_cloudwatch_event_rule" "lambda" {
  name                = "${var.name}-event-rule"
  description         = var.description
  is_enabled          = var.is_enabled
  schedule_expression = var.schedule_expression
}