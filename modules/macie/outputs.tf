output "s3_bucket_name" {
  description = "The name of the S3 Bucket."
  value = aws_s3_bucket.macie.bucket
}