terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

data "aws_key_pair" "this" {
  key_name = var.access_key_name
  filter {
    name   = "tag:Project"
    values = ["warden"]
  }
}

# resource "aws_db_instance" "default" {
#   allocated_storage = 10
#   engine            = "postgres"
#   engine_version    = "13"
#   instance_class    = "db.t4g.micro"
#   username          = "bla"
#   password          = "sesurity"
# }

##need ec2 instance for connect to RDS