data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "./build"
  output_path = "./zip/deployment.zip"
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "${local.lambda_name}.zip"
  source = data.archive_file.lambda_zip.output_path
}

locals {
  lambda_name = "listing-getter"
}

resource "aws_lambda_function" "listing-getter-lambda" {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_role.arn
  runtime       = "go1.x"
  handler       = "main"
  publish       = true
  s3_bucket     = aws_s3_bucket.lambda_code.bucket
  s3_key        = "${local.lambda_name}.zip"
  timeout       = 10

  environment {
    variables = {
      ZOOPLA_API_KEY     = var.zoopla_api_key
      LAMBDA_ENVIRONMENT = var.environment
      LOG_LEVEL          = var.log_level
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash
    ]
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "${local.lambda_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3-policy" {
  name   = "tf-policydocument"
  policy = data.aws_iam_policy_document.s3-access.json
}

resource "aws_iam_role_policy_attachment" "basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "attach-s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3-policy.arn
}

data "aws_iam_policy_document" "s3-access" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.listing_upload.arn
    ]
  }
  statement {
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.listing_upload.arn}/*"
    ]
  }
}
