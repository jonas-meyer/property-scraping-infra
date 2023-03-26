resource "aws_s3_bucket" "listing_upload" {
  bucket = "${local.resource_prefix}-listing-upload"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "listing_upload" {
  bucket = aws_s3_bucket.listing_upload.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "alias/aws/s3"
    }
  }
}

resource "aws_s3_bucket_versioning" "listing_upload" {
  bucket = aws_s3_bucket.listing_upload.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "listing_upload" {
  bucket = aws_s3_bucket.listing_upload.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "listing_upload" {
  bucket = aws_s3_bucket.listing_upload.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_lambda_permission" "s3-lambda-permission" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamodb_pusher_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.listing_upload.arn
}