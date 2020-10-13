# # ---------------------------------------------------------------------------------------------------------------------
# # CONFIGURE OUR AWS CONNECTION
# # ---------------------------------------------------------------------------------------------------------------------

# provider "aws" {
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

locals {
  create_resources        = var.create_resources ? 1 : 0
  scheduled_event_enabled = var.create_resources && var.scheduled_event_enabled ? 1 : 0

#   rule_package_arns = compact([
#     var.cis_rule_package_enabled ? "arn:aws:inspector:us-east-1:316112463485:rulespackage/0-rExsr2X8" : "",
#     var.cve_rule_package_enabled ? "arn:aws:inspector:us-east-1:316112463485:rulespackage/0-gEjTy7T7" : "",
#     var.network_reachability_rule_package_enabled ? "arn:aws:inspector:us-east-1:316112463485:rulespackage/0-PmNV0Tcd" : "",
#     var.security_best_practices_rule_package_enabled ? "arn:aws:inspector:us-east-1:316112463485:rulespackage/0-R01qwB5Q" : "",
#     ]
#   )
}

# The AWS Inspector Rules Packages data source 
# allows access to the list of AWS Inspector Rules Packages 
# which can be used by AWS Inspector within the region 
# configured in the provider.
data "aws_inspector_rules_packages" "rules" {}

resource "aws_inspector_assessment_target" "assessment" {
  count = local.create_resources
  name  = "${var.name_prefix}-assessment-target"
}

resource "aws_inspector_assessment_template" "assessment" {
  count              = local.create_resources

  name               = "${var.name_prefix}-assessment-template"
  target_arn         = aws_inspector_assessment_target.assessment[0].arn
  duration           = var.assessment_duration
  rules_package_arns = data.aws_inspector_rules_packages.rules.arns
}

data "aws_iam_policy_document" "inspector_event_role_policy" {
  count = local.scheduled_event_enabled

  statement {
    sid = "StartAssessment"
    actions = [
      "inspector:StartAssessmentRun",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "inspector_event_assume_role" {
  count = local.scheduled_event_enabled

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "inspector_event_role" {
  count = local.scheduled_event_enabled
  
  name  = "${var.name_prefix}-inspector-event-role"
  assume_role_policy = data.aws_iam_policy_document.inspector_event_assume_role[0].json
}

resource "aws_iam_role_policy" "inspector_event" {
  count  = local.scheduled_event_enabled

  name   = "${var.name_prefix}-inspector-event-policy"
  role   = aws_iam_role.inspector_event_role[0].id
  policy = data.aws_iam_policy_document.inspector_event_role_policy[0].json
}

resource "aws_cloudwatch_event_rule" "inspector_event_schedule" {
  count               = local.scheduled_event_enabled

  name                = "${var.name_prefix}-inspector-event-schedule"
  description         = "Trigger an Inspector Assessment"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "inspector_event_target" {
  count    = local.scheduled_event_enabled

  rule     = aws_cloudwatch_event_rule.inspector_event_schedule[0].name
  arn      = aws_inspector_assessment_template.assessment[0].arn
  role_arn = aws_iam_role.inspector_event_role[0].arn
}