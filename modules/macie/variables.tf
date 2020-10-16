# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are required. A value must be passed in.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
}

variable "aws_account_id" {
  description = "The ID of the AWS Account in which to create resources."
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket that you want to associate with Amazon Macie."
  type        = string
}

variable "kms_key_name" {
  description = "The alias of the KMS key that you want to associate with Amazon Macie."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have default values that may be overwritten.
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_macie" {
  description = "Set to true to enable macie."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Set to true to delete the contents of the S3 bucket when you run 'terraform destroy'."
  type        = bool
  default     = false
}