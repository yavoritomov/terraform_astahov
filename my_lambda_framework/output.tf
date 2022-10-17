output "lambda_arn" {
  value = tomap({
    for arn, lamb in aws_lambda_function.terraform_lambda_func : arn => lamb.arn
  })
}

output "eventbridge_arn" {
  value = tomap({
    for arn, eventbridge in aws_cloudwatch_event_rule.trigger : arn => eventbridge.arn
  })
}

output "function_endpoint" {
  value = aws_lambda_function_url.test_latest
}