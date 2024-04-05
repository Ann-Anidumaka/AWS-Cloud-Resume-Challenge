
<<<<<<< HEAD:module/s3-static/main.tf
resource "aws_s3_bucket" "cloud-resume-assets-ac010614" {
=======
resource "aws_s3_bucket" "unique-cloud-resume-bucket-040424" {
>>>>>>> 6e373c66e08fed65578094e6eeb0b25dbd76b180:S3-static/main.tf
  bucket = var.my-bucket-name
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
<<<<<<< HEAD:module/s3-static/main.tf
  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id
=======
  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id
>>>>>>> 6e373c66e08fed65578094e6eeb0b25dbd76b180:S3-static/main.tf
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
<<<<<<< HEAD:module/s3-static/main.tf
  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id
=======
  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id
>>>>>>> 6e373c66e08fed65578094e6eeb0b25dbd76b180:S3-static/main.tf

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

<<<<<<< HEAD:module/s3-static/main.tf
  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id
=======
  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id
>>>>>>> 6e373c66e08fed65578094e6eeb0b25dbd76b180:S3-static/main.tf
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
<<<<<<< HEAD:module/s3-static/main.tf
  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id
=======
  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id

>>>>>>> 6e373c66e08fed65578094e6eeb0b25dbd76b180:S3-static/main.tf
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
<<<<<<< HEAD:module/s3-static/main.tf
  bucket = aws_s3_bucket.cloud-resume-assets-ac010614.id
=======
  bucket = aws_s3_bucket.unique-cloud-resume-bucket-040424.id
>>>>>>> 6e373c66e08fed65578094e6eeb0b25dbd76b180:S3-static/main.tf

  index_document {
    suffix = "index.html"
  }
}

# AWS S3 object resource for hosting bucket files
resource "aws_s3_object" "Bucket_files" {
<<<<<<< HEAD:module/s3-static/main.tf
  bucket =  aws_s3_bucket.cloud-resume-assets-ac010614.id # ID of the S3 bucket
=======
  bucket =  aws_s3_bucket.unique-cloud-resume-bucket-040424.id  # ID of the S3 bucket
>>>>>>> 6e373c66e08fed65578094e6eeb0b25dbd76b180:S3-static/main.tf

  for_each     = module.template_files.files
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  # ETag of the S3 object
  etag = each.value.digests.md5
}
