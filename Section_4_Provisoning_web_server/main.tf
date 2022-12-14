provider "aws" {
  region = "us-east-2"
  #profile = "admin"
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web_server01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = "ami_demo"

  tags = {
    Name  = "Web-Server01"
    Owner = "Yavor Tomov"
  }
}

output "web_server01_tags" {
  value = ["${aws_instance.web_server01.tags}"]
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance