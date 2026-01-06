terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws"{
    region = "us-east-1"
}

resource "aws_s3_bucket" "angular_bucket"{
    bucket = "my-angular-app-bucket123456"
}

resource "aws_s3_bucket_website_configuration" "angular_website"{
    bucket = aws_s3_bucket.angular_bucket.id

    index_document {
        suffix = "index.html"
    }

    error_document{
        key = "index.html"
    }
}

resource "aws_s3_bucket_public_access_block" "public_access" { 
  bucket = aws_s3_bucket.angular_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.angular_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.angular_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "angular_files" {
  for_each = fileset("${path.module}/../../../trade-app/dist/trade-app", "**/*")

  bucket = aws_s3_bucket.angular_bucket.bucket
  key = replace(each.value, "browser/", "")
  source = "${path.module}/../../../trade-app/dist/trade-app/${each.value}"
  etag   = filemd5("${path.module}/../../../trade-app/dist/trade-app/${each.value}")

  content_type = lookup({
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    png  = "image/png"
    jpg  = "image/jpeg"
    svg  = "image/svg+xml"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "binary/octet-stream")
}

