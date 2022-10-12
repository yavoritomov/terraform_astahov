provider "aws" {
  region = "us-east-2"
  profile = "admin"
}
#------------Lambda------------------
resource "aws_iam_role" "lambda_role" {
name   = "lambda_scripts"
assume_role_policy = file("./policies/lambda_role.json")
}

resource "aws_iam_policy" "iam_policy_for_lambda" {

 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = file("./policies/lambda_policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_python_code" {
 for_each = local.lambdas
 type        = "zip"
 source_file  = "${path.module}/scripts/${each.key}/index.py"
 output_path = "${path.module}/scripts/${each.key}/${each.key}_python.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
 for_each = local.lambdas
 filename                       = "${path.module}/scripts/${each.key}/${each.key}_python.zip"
 function_name                  = each.key
 description                    = each.value.lambda.description
 role                           = aws_iam_role.lambda_role.arn
 handler                        = "index.lambda_handler"
 runtime                        = each.value.lambda.runtime
 layers                         = [aws_lambda_layer_version.lambda_layer[each.key].arn]
 depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
 timeout                        = each.value.lambda.timeout
 source_code_hash               = data.archive_file.zip_the_python_code[each.key].output_base64sha256
}

#---------------Lambda Layer -----------
data "archive_file" "zip_the_python_request_module" {
 for_each = local.lambdas
 type        = "zip"
 source_dir  = "${path.module}/scripts/${each.key}/libs"
 output_path = "${path.module}/scripts/${each.key}/${each.key}_layer.zip"

  depends_on = [
    null_resource.install_python_libs
    ]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  for_each = local.lambdas
  filename   = "${path.module}/scripts/${each.key}/${each.key}_layer.zip"
  layer_name = "${each.key}_layer"
  source_code_hash = data.archive_file.zip_the_python_request_module[each.key].output_base64sha256

  compatible_runtimes = [each.value.lambda.runtime]
}

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
#--------------Python libs----------------
resource "null_resource" "install_python_libs" {
  for_each = local.lambdas
  provisioner "local-exec" {
    command = "pip3 install --platform manylinux2014_x86_64 --implementation cp --upgrade --python 3.8 --only-binary=:all: --target . -r ../../requirements.txt"
    working_dir = "./scripts/${each.key}/libs/python"
  }
  depends_on = [
    null_resource.requirements_file
  ]
}

resource "null_resource" "requirements_file" {
  for_each = local.lambdas
  provisioner "local-exec" {
    command = "pipreqs --mode gt --use-local --force ."
    working_dir = "./scripts/${each.key}"
  }
  depends_on = [
    null_resource.python_dir
  ]
}

resource "null_resource" "libs_dir" {
  for_each = local.lambdas
  provisioner "local-exec" {
    command = "mkdir -p libs"
    working_dir = "./scripts/${each.key}"
  }
}

resource "null_resource" "python_dir" {
  for_each = local.lambdas
  provisioner "local-exec" {
    command = "mkdir -p python"
    working_dir = "./scripts/${each.key}/libs"
  }
  depends_on = [
    null_resource.libs_dir
    ]
}