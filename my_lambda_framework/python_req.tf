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