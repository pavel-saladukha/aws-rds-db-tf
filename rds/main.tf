locals {
  rds_name     = "main"
  path_to_file = "infra.yaml"
}

resource "null_resource" "db_user_pass_generator" {

  triggers = {
    hash = filemd5(local.path_to_file)
    path = local.path_to_file
  }

  provisioner "local-exec" {
    command = "bash ./rds/db_user_pass_generate.sh ${local.rds_name}"
  }

}

resource "null_resource" "db_user_pass_creator" {
  provisioner "local-exec" {
    
    command = "bash ./rds/db_user_pass_generate.sh ${local.rds_name}"
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

# #need ec2 instance for connect to RDS

