resource "aws_s3_bucket" "resume-bucket"{
    bucket = var.my-bucket-name
}


resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.resume-bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}



resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.resume-bucket.id

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

  bucket = aws_s3_bucket.resume-bucket.id

  acl    = "public-read"
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.resume-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.my-bucket-name}/*"
        ]
      }
    ]
  })
}

module "template_files"{
    source = "hashicorp/dir/template"
    base_dir = "${path.module}/website"
}

resource "aws_s3_bucket_website_configuration" "web-config" {
  bucket = aws_s3_bucket.resume-bucket.id


  index_document {
    suffix = "index.html"
  }

 
resource "aws_s3_bucket_object" "static_files" {
  for_each = module.template_files.files

  bucket       = aws_s3_bucket.resume-bucket.id
  key          = each.key
  content_type = each.value.content_type

  # The template_files module guarantees that only one of these two attributes
  # will be set for each file, depending on whether it is an in-memory template
  # rendering result or a static file on disk.
  source  = each.value.source_path
  content = each.value.content

  # Unless the bucket has encryption enabled, the ETag of each object is an
  # MD5 hash of that object.
  etag = each.value.digests.md5
}