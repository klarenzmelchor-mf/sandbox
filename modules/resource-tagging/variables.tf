# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
  type        = string
}

variable "name" {
  description = "The name of the resources in this module."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "tag_key" {
  description = "The tag key"
  type        = string
  default     = "map-migrated"
}

variable "tag_value" {
  description = "The value of the tag key"
  type        = string
  default     = "d-server-00l6aags6i42uj"
}

variable "description" {
  description = "The event rule description"
  type        = string
  default     = "Event rule for AWS tagging lambda"
}

variable "is_enabled" {
  description = "Set to true to enable cloudwatch event. Otherwise, set to false."
  type        = bool
  default     = true
}

variable "schedule_expression" {
  description = "The scheduling expression."
  type        = string
  default     = "cron(0 0 * * ? *)"
}