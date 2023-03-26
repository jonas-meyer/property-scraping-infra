resource "aws_s3_object" "dynamodb_lambda_zip" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "${local.dynamodb_lambda_name}.zip"
  source = data.archive_file.lambda_zip.output_path
}

locals {
  dynamodb_lambda_name = "dynamodb-pusher"
}

resource "aws_lambda_function" "dynamodb_pusher_lambda" {
  function_name = local.dynamodb_lambda_name
  role          = aws_iam_role.lambda_role.arn
  runtime       = "go1.x"
  handler       = "main"
  publish       = true
  s3_bucket     = aws_s3_bucket.lambda_code.bucket
  s3_key        = "${local.dynamodb_lambda_name}.zip"
  timeout       = 10

  environment {
    variables = {
      LAMBDA_ENVIRONMENT = var.environment
      LOG_LEVEL          = var.log_level
      DYNAMODB_TABLE     = aws_dynamodb_table.listing_table.name
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash
    ]
  }
}

resource "aws_iam_role" "dynamodb_pusher_lambda_role" {
  name = "${local.dynamodb_lambda_name}-lambda-role"

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

resource "aws_iam_role_policy_attachment" "lambda" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.dynamodb_pusher_lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.dynamodb_pusher_lambda_role.name
}

resource "aws_s3_bucket_notification" "listing_upload_bucket_notification" {
  bucket = aws_s3_bucket.listing_upload.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.dynamodb_pusher_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }
}
