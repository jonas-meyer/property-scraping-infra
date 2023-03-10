output "lambda_code_bucket_name" {
  value = aws_s3_bucket.lambda_code.bucket
}

output "lambda_code_bucket_arn" {
  value = aws_s3_bucket.lambda_code.arn
}

output "lambda_code_bucket_id" {
  value = aws_s3_bucket.lambda_code.id
}