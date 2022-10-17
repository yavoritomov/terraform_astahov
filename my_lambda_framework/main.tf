#terraform {
#  backend "s3" {
#    bucket         = "<your_bucket_name>"
#    key            = "terraform.tfstate"
#    region         = "<your_aws_region>"
#    dynamodb_table = "<your_dynamo_dbtable_name>"
#  }
#}

provider "aws" {
  region = "us-east-2"
  profile = "admin"
}