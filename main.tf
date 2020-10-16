module "inspector" {
  source = "./modules/inspector"
}

module "macie" {
  source = "./modules/macie"

  s3_bucket_name = "microfocus-multi-security-macie"
  kms_key_name   = "microfocus-multi-security-macie"
  aws_account_id = "621270530972"
  aws_region     = "eu-north-1"
  
}