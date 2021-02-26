# schlee_tv
schlee.tv

- [deployment status](https://github.com/schell/schlee_tv/actions)

## learnings
* in order for the rout53 alias record to be pointed at the cloudfront url, the
  cloudfront distribution must have the domain name listed in its aliases, eg.
  ```terraform
  resource "aws_cloudfront_distribution" "distribution" {
    ...
    aliases = [
      "schlee.tv"
    ]
    ...
  ```
* in order for cloudfront to be able to read from the s3 bucket we must first
  create a cloudfront access origin id and then place a policy on the bucket that
  allows the origin id to read the bucket's objects:
  ```terraform
  resource "aws_cloudfront_origin_access_identity" "origin_identity" {
    comment = "identity for schlee.tv access origin"
  }

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
  }
  ```
  ...and then set this as the aws_cloudfront_distribution.s3_origin_config.origin_access_identity:
  ```terraform
  resource "aws_cloudfront_distribution" "distribution" {
    origin {
      ...
      s3_origin_config {
        origin_access_identity = aws_cloudfront_origin_access_identity.origin_identity.cloudfront_access_identity_path
      }
    }
    ...
  }
  ```
