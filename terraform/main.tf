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

data "aws_vpc" "default" {
 default = true
}

resource "aws_security_group" "juice-shop-sg" {
  name        = "juiceshop-security-group"
  description = "Allow 8080 and 22"

  ingress {
    description = "SSH ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP ingress"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
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