# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are required. A value must be passed in.
# ---------------------------------------------------------------------------------------------------------------------

# variable "aws_region" {
#   description = "The AWS region in which all resources will be created"
#   type        = string
# }

# variable "aws_account_id" {
#   description = "The ID of the AWS Account in which to create resources."
#   type        = string
# }

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have default values that may be overwritten.
# ---------------------------------------------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Name prefix for resources that this module will create"
  type        = string
  default     = "microfocus"
}

variable "scheduled_event_enabled" {
  description = "Enable Cloudwatch Events to schedule an assessment"
  type        = bool
  default     = true
}

variable "assessment_duration" {
  description = "The duration of the Inspector assessment run"
  type        = string
  default     = "3600" # 1 hour
}

variable "schedule_expression" {
  type        = string
  description = "AWS Schedule Expression for recurring assessment: https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html"
  default     = "rate(7 days)"
}

variable "create_resources" {
  description = "If you set this variable to false, this module will not create any resources. This is used as a workaround because Terraform does not allow you to use the 'count' parameter on modules. By using this parameter, you can optionally create or not create the resources within this module."
  type        = bool
  default     = true
}