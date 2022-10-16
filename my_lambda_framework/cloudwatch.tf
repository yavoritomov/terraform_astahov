#--------------CloudWatch-------------
resource "aws_cloudwatch_log_group" "loggroups" {
  for_each = local.lambdas
  name              = "/aws/lambda/${each.key}"

  retention_in_days = each.value.cloudwatch.retention_in_days
}

