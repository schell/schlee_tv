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
  //domain_name = terraform.workspace == "master" ? "schlee.tv" : "${terraform.workspace}.schlee.tv"
}


variable "AWS_ACCESS_KEY_ID" {
}


variable "AWS_SECRET_ACCESS_KEY" {
}


// aws
provider "aws" {
  region = "us-west-2"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}


provider "aws" {
  alias = "virginia"
  region = "us-east-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}


// origin id & cloudfront
resource "aws_cloudfront_origin_access_identity" "origin_identity" {
  comment = "identity for schlee.tv access origin"
}


// s3
resource "aws_s3_bucket" "schlee_tv_bucket" {
  bucket = "schlee.tv"
  acl = "private"

  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.origin_identity.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::schlee.tv/*"
        }
    ]
}
POLICY

  provisioner "local-exec" {
    when = destroy
    command = "aws s3 rm s3://${self.id}/ --recursive"
  }
}


// s3 site sync
resource "null_resource" "aws_sync" {
  provisioner "local-exec" {
    command = "aws s3 sync build/site s3://schlee.tv/"
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [aws_s3_bucket.schlee_tv_bucket]
}


data "aws_route53_zone" "zone" {
  provider = aws.virginia
  zone_id = "Z3TROWZ11JUKZU"
}


// ssl & route53 record stuff
resource "aws_acm_certificate" "cert" {
  provider = aws.virginia
  validation_method = "DNS"
  domain_name = "schlee.tv"
  tags = {
    Name = "schlee_tv_cert"
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "cert_validation" {
  provider = aws.virginia
  zone_id = data.aws_route53_zone.zone.id

  name = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl = 60
}


resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = aws_route53_record.cert_validation.*.fqdn
  timeouts {
    create = "60m"
  }
  lifecycle {
    ignore_changes = [id]
  }
}


resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.schlee_tv_bucket.bucket_regional_domain_name
    origin_id = aws_s3_bucket.schlee_tv_bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_identity.cloudfront_access_identity_path
    }
  }
  enabled = true
  is_ipv6_enabled = true
  comment = "schlee.tv cloudfront"
  default_root_object = "index.html"
  aliases = [
    "schlee.tv"
  ]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.schlee_tv_bucket.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Here's where our certificate is loaded in!
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}


// last bit of route53 stuff
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name = ""
  type = "A"
  alias {
    name = aws_cloudfront_distribution.distribution.domain_name
    zone_id = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
