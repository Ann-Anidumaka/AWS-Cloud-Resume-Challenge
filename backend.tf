terraform {
  backend "s3" {
    bucket         = "aws-cloud-resume-challenge"    # your-bucket-name 
    key            = "Terraform-State"        # path/to/your/terraform.tfstate
    region         = "us-east-1"             # your-region 
  }
}