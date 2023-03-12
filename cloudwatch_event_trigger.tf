resource "aws_cloudwatch_event_rule" "listing_getter_lambda_schedule" {
  name                = "go_lambda_schedule"
  description         = "Schedule for the Go Lambda function"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "listing_getter_lambda_target" {
  target_id = "listing_getter_lambda_target"
  rule      = aws_cloudwatch_event_rule.listing_getter_lambda_schedule.name
  arn       = aws_lambda_function.listing-getter-lambda.arn
}

resource "aws_lambda_permission" "go_lambda_permission_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.listing-getter-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.listing_getter_lambda_schedule.arn
}
