# define aws region replace it with your region

variable "region" {
  default = "us-east-1"
}

# aws provider block

provider "aws" {
  region = var.region
}

# S3 static website bucket

resource "aws_s3_bucket" "aws-cloud-resume-challenge" {
  bucket = "aws-cloud-resume-challenge-bucket11" # give a unique bucket name
  tags = {
    Name = "aws-cloud-resume-challenge"
  }
}

resource "aws_s3_bucket_website_configuration" "aws-cloud-resume-challenge" {
  bucket = aws_s3_bucket.aws-cloud-resume-challenge.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "aws-cloud-resume-challenge" {
  bucket = aws_s3_bucket.aws-cloud-resume-challenge.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket ACL access

resource "aws_s3_bucket_ownership_controls" "aws-cloud-resume-challenge" {
  bucket = aws_s3_bucket.aws-cloud-resume-challenge.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "aws-cloud-resume-challenge" {
  bucket = aws_s3_bucket.my-static-website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "aws-cloud-resume-challenge" {
  depends_on = [
    aws_s3_bucket_ownership_controls.aws-cloud-resume-challenge,
    aws_s3_bucket_public_access_block.aws-cloud-resume-challenge,
  ]

  bucket = aws_s3_bucket.aws-cloud-resume-challenge.id
  acl    = "public-read"
}




# s3 static website url

output "website_url" {
  value = "http://${aws_s3_bucket.aws-cloud-resume-challenge.bucket}.s3-website.${var.region}.amazonaws.com"
}
