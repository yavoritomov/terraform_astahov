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
#----------------Function_URL-------------------

resource "aws_lambda_function_url" "test_latest" {
  for_each = local.lambda_function_url
  function_name      = aws_lambda_function.terraform_lambda_func[each.key].function_name
  authorization_type = "NONE"
}
