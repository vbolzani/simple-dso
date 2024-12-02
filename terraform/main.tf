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

variable "EC2_PUBLIC_KEY" {
  type = string
}

resource "aws_key_pair" "ubuntu-cicd" {
  key_name   = "ubuntu-cicd"
  public_key = var.EC2_PUBLIC_KEY
}

data "aws_vpc" "default" {
 default = true
}

resource "aws_security_group" "too-open-security-group" {
  name        = "too-open-security-group"
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

resource "aws_instance" "test1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name        = aws_key_pair.ubuntu-cicd.key_name
  vpc_security_group_ids = [aws_security_group.too-open-security-group.id]


  user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt install -y nodejs npm
EOF

}

output "deployed_public_ip" {
    value = aws_instance.test1.public_ip
}