provider "aws" {
  region = "us-east-2"
  #profile = "admin"
}
#------------Lambda------------------
resource "aws_iam_role" "lambda_role" {
name   = "lambda_scripts"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {

 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
  #Move policy to file
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_python_code" {
 for_each = local.lambdas
 type        = "zip"
 source_dir  = "${path.module}/scripts/${each.key}/"
 output_path = "${path.module}/scripts/${each.key}/${each.key}-python.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
 for_each = local.lambdas
 filename                       = "${path.module}/scripts/${each.key}/${each.key}-python.zip"
 function_name                  = each.key
 description                    = each.value.lambda.description
 role                           = aws_iam_role.lambda_role.arn
 handler                        = "index.lambda_handler"
 runtime                        = each.value.lambda.runtime
# layers                         = [aws_lambda_layer_version.lambda_layer.arn]
 depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
 timeout                        = each.value.lambda.timeout
 source_code_hash               = data.archive_file.zip_the_python_code[each.key].output_base64sha256
}

#---------------Lambda Layer -----------
#data "archive_file" "zip_the_python_request_module" {
# type        = "zip"
# source_dir  = "${path.module}/scripts/python_requests/"
# output_path = "${path.module}/scripts/requests_layer.zip"
#}
#
#resource "aws_lambda_layer_version" "lambda_layer" {
#  filename   = "${path.module}/scripts/requests_layer.zip"
#  layer_name = "python_requests"
#  source_code_hash = data.archive_file.zip_the_python_request_module.output_base64sha256
#
#  compatible_runtimes = ["python3.8"]
#}


#--------------CloudWatch-------------
resource "aws_cloudwatch_log_group" "loggroups" {
  for_each = local.lambdas
  name              = "/aws/lambda/${each.key}"
  retention_in_days = each.value.cloudwatch.retention_in_days
}
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