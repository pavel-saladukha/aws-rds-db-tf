
resource "null_resource" "db_user_pass_generator" {
  provisioner "local_exec" {
    command = ""
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

