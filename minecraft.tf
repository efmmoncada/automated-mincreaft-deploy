terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["./.credentials"]
  shared_config_files      = ["./.config"]
  profile                  = "default"
}

resource "aws_key_pair" "minecraft_server_key" {
  key_name   = "minecraft_server_key"
  public_key = file("./minecraft.pub")
}

resource "aws_security_group" "minecraft_server_sg" {
  name = "allow_ssh"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TCP Minecraft Port"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 4434
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

resource "aws_instance" "minecraft_server" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.large"
  key_name               = aws_key_pair.minecraft_server_key.key_name
  vpc_security_group_ids = [aws_security_group.minecraft_server_sg.id]
  tags = {
    Name = "Minecraft Server"
  }
}

output "hostname" {
  value = aws_instance.minecraft_server.public_dns
}

output "ansible_user" {
  value = "ubuntu"
}

output "ansible_ssh_private_key_file" {
  value = "./minecraft"
}

output "server_ip" {
  description = "ip address server is running on to connect to"
  value       = "${aws_instance.minecraft_server.public_ip}:25565"
}

