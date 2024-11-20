terraform {
  backend "s3" {
    bucket = "vbolzani-terraform-state-1"
    key    = "tfstate/state"
    region = "us-east-1"
  }
}


resource "null_resource" "default" {
  provisioner "local-exec" {
    command = "echo 'Hello World'"
  }
}