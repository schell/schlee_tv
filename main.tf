// backend
terraform {
  backend "s3" {
    bucket = "schell-terraform"
    key    = "schlee_tv"
    region = "us-west-2"
  }
}

// variables
locals {
  is_master = terraform.workspace == "master"
  domain_name = terraform.workspace == "master" ? "schlee.tv" : "${terraform.workspace}.schlee.tv"
}


variable "AWS_ACCESS_KEY_ID" {
}


variable "AWS_SECRET_ACCESS_KEY" {
}


// aws
provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = "us-west-2"
}


// s3
resource "aws_s3_bucket" "schlee_tv_bucket" {
  bucket = local.domain_name
  acl = "public-read"

  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
      {
        "Sid":"AddPerm",
        "Effect":"Allow",
        "Principal": "*",
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::${local.domain_name}/*"]
      }
    ]
  }
  EOF

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  provisioner "local-exec" {
    when = destroy
    command = "aws s3 rm s3://${self.id}/ --recursive"
  }
}


// s3 site sync
resource "null_resource" "aws_sync" {
  provisioner "local-exec" {
    command = <<EOF
      aws s3 sync build/site s3://${local.domain_name}/ && \
      echo endpoint is ${aws_s3_bucket.schlee_tv_bucket.website_endpoint}
    EOF
  }

  triggers = {
    always_run = timestamp()
  }
}
