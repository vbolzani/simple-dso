terraform {
  backend "s3" {
    bucket = "vbolzani-terraform-state-1"
    key    = "tfstate/state"
    region = "us-east-1"
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = file("key.pub")
}

resource "aws_instance" "test" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt install nodejs npm
EOF

}

output "deployed_public_ip" {
    value = aws_instance.test.public_ip
}