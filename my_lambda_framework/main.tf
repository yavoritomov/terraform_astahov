#terraform {
#  backend "s3" {
#    bucket         = "<your_bucket_name>"
#    key            = "terraform.tfstate"
#    region         = "<your_aws_region>"
#    dynamodb_table = "<your_dynamo_dbtable_name>"
#  }
#}
#https://proofpointisolation.com/browser?url=https%3A%2F%2Fwww.golinuxcloud.com%2Fconfigure-s3-bucket-as-terraform-backend%2F

provider "aws" {
  region = "us-east-2"
  profile = "admin"
}