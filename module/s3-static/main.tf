
resource "aws_s3_bucket" "cloud-resume-assets-ac010614" {
  bucket = var.my-bucket-name
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id

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

  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
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
  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id

  index_document {
    suffix = "index.html"
  }
}

# AWS S3 object resource for hosting bucket files
resource "aws_s3_object" "Bucket_files" {
  bucket =  aws_s3_bucket.cloud-resume-assets-ac010614.id # ID of the S3 bucket

  for_each     = module.template_files.files
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  # ETag of the S3 object
  etag = each.value.digests.md5
}
