resource "aws_s3_bucket" "unique-cloud-resume-bucket-040424" {
  bucket = var.my-bucket-name
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.public_access,
  ]

  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject","s3:PutObject"]
        Resource  = ["arn:aws:s3:::${var.my-bucket-name}/*"]
      }
    ]
  })
}

module "template_files" {
  source   = "hashicorp/dir/template"

  base_dir = "${path.module}/website"
}

resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id

  index_document {
    suffix = "index.html"
  }
}

# AWS S3 object resource for hosting bucket files
resource "aws_s3_object" "Bucket_files" {
  bucket =  aws_s3_bucket.unique-cloud-resume-bucket-040424.id  # ID of the S3 bucket

  for_each     = module.template_files.files
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  # ETag of the S3 object
  etag = each.value.digests.md5
}

# Cloudfront 

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "s3-my-webapp.example.com"
}


locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "cf_s3_distribution" {
  origin {
    domain_name =  aws_s3_bucket.unique-cloud-resume-bucket-040424.bucket_regional_domain_name
    origin_id                = local.s3_origin_id

    
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers = ["origin"]
     
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

   tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Dynamo DB
resource "aws_dynamodb_table" "resume_table" {
  name           = "cloud_resume"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "views"
    type = "N"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }
}

#Lambda