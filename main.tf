provider "aws" {
  region  = "us-east-1"
  # profile = "akarsh"
  # shared_config_files      = ["/c/Users/MITHUN/.aws/config"]
  # shared_credentials_files = ["/c/Users/MITHUN/.aws/credentials"]
}
#terraform { 
  #cloud { 
    
   # organization = "MithunTechTraining" 

   # workspaces { 
     # name = "cloud" 
   # } 
 # } 
#}
 terraform {
   backend "s3" {
     bucket = "s3backend-terraform-2024"
     key    = "global/terraform.tfstate"
     region = "us-east-1"
     # Replace this with your DynamoDB table name!
     dynamodb_table = "terraform"
     profile = "akarsh"
   }
 }

locals {
  bucket_name = "${terraform.workspace}-bucket" 
  app_name = "${terraform.workspace}-app"
}

resource "aws_s3_bucket" "duck" {
  bucket = "${local.bucket_name}-${local.app_name}"


  tags = {
    Name        = var.bucket_name
    Environment = var.env
    ManagedBy   = "Terraform"
    version     = "1.9.8"
  }

}
#Adding Bucket Ownership
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.duck.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  depends_on = [aws_s3_bucket_ownership_controls.example]
  bucket = aws_s3_bucket.duck.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.duck.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.duck.id

  rule {
    expiration {
      days = 365
    }

    filter {
      prefix = "logs/"
    }
    status = "Enabled"
    id     = "logs"
  }

  rule {
    expiration {
      days = 7
    }

    filter {
      prefix = "temp/"
    }
    status = "Enabled"
    id     = "temp"
  }

}

