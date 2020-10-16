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


# ---------------------------------------------------------------------------------------------------------------------
# Macie2 is not supported yet with terraform
# A workaround is to use the aws-cli to enable/disable macie2
# aws-cli is required to run this module
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# null_resource can't use provider and will run on
# the default region configured in your local computer
# we can pass the variable region as a workaround
# ---------------------------------------------------------------------------------------------------------------------

resource "null_resource" "enable_macie" {

  triggers = {
    region = var.aws_region
  }

  provisioner "local-exec" {
    command = "aws macie2 enable-macie --status ENABLED --region ${self.triggers.region}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws macie2 disable-macie --region ${self.triggers.region}"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE KMS MASTER KEY
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "macie_kms_key_policy" {
  statement {
    sid = "AllowMacieToUseTheKey"

    principals {
      type        = "Service"
      identifiers = ["macie.amazonaws.com"]
    }

    actions = [
      "kms:GenerateDataKey",
      "kms:Encrypt"
    ]

    effect = "Allow"

    resources = ["*"]

  }

  statement {
    sid = "EnableIAMUserPermissions"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    effect = "Allow"

    resources = ["*"]

  }
}

resource "aws_kms_key" "macie_kms_key" {
  description = "Allow macie to enrypt the S3 Bucket"
  policy      = data.aws_iam_policy_document.macie_kms_key_policy.json
}

resource "aws_kms_alias" "macie_kms_key" {
  name          = "alias/${var.kms_key_name}"
  target_key_id = aws_kms_key.macie_kms_key.key_id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN S3 BUCKET FOR MACIE DISCOVERY RESULTS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "macie" {
  bucket        = lower(var.s3_bucket_name)
  force_destroy = var.force_destroy
  acl           = "private"

  # Always enable server-side encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        # If a KMS key is not provided (kms_key_arn is null), the default aws/s3 key is used
        kms_master_key_id = aws_kms_key.macie_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

}

data "aws_iam_policy_document" "macie" {
  statement {
    sid = "AllowMacieToUseTheGetBucketLocationOperation"

    principals {
      type        = "Service"
      identifiers = ["macie.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    effect = "Allow"

    resources = ["${aws_s3_bucket.macie.arn}/*"]
  }

  statement {
    sid = "AllowMacieToUploadObjectsToTheBucket"

    principals {
      type        = "Service"
      identifiers = ["macie.amazonaws.com"]
    }

    actions = ["s3:GetBucketLocation"]

    effect = "Allow"

    resources = [aws_s3_bucket.macie.arn]
  }
  
  statement {
    sid = "AllowSSLRequestsOnly"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    effect = "Deny"

    resources = [
      aws_s3_bucket.macie.arn,
      "${aws_s3_bucket.macie.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }

  statement {
    sid = "DenyUnencryptedObjectUploads"

    principals {
      type        = "Service"
      identifiers = ["macie.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    effect = "Deny"

    resources = ["${aws_s3_bucket.macie.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values = ["aws:kms"]
    }
  }

  statement {
    sid = "DenyIncorrectEncryptionHeaders"

    principals {
      type        = "Service"
      identifiers = ["macie.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    effect = "Deny"

    resources = ["${aws_s3_bucket.macie.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values = [aws_kms_key.macie_kms_key.arn]
    }
  }

}

resource "aws_s3_bucket_policy" "macie" {
  bucket = aws_s3_bucket.macie.id
  policy = data.aws_iam_policy_document.macie.json
}