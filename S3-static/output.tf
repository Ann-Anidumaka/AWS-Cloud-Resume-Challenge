output "website_url" {
    description = "My website_URL"
    value = "aws_s3_bucket_website_configuration.web-config.website_endpoint" 
}