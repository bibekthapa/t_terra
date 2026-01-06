output "files_to_upload" {
  value = fileset("${path.module}/../../../trade-app/dist/trade-app/", "**/*")
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.angular_website.website_endpoint
}

