#-------------Eventbridge-------------

resource "aws_cloudwatch_event_rule" "trigger" {
 for_each = local.lambdas
  name                = each.key
  schedule_expression = each.value.eventbridge.schedule
  description         = each.value.eventbridge.description
  is_enabled          = each.value.eventbridge.enabled
}

resource "aws_cloudwatch_event_target" "target_lambda_function" {
  for_each = aws_cloudwatch_event_rule.trigger
  rule = each.value.name
  arn  = aws_lambda_function.terraform_lambda_func[each.key].arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  for_each = aws_lambda_function.terraform_lambda_func
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger[each.key].arn
}