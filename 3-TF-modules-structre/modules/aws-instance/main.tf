# Configure the AWS Provider
# provider "aws" {
#   region = var.aws_region
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "vpc1" {
  cidr_block = var.aws_vpc_cidr
  tags = {
    "Name" = var.aws_vpc_name
  }
}

# Create a Subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.aws_subnet_cidr
  tags = {
    "Name" = var.aws_subnet_name
  }
}

# Create a IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    "Name" = "igw_vpc_1"
  }
}

# Create a Route Table
resource "aws_route_table" "rt_vpc1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    "Name" = "rt_vpc_1"
  }
}

# Create a Route Table Association
resource "aws_route_table_association" "rt_association_vpc1" {
  route_table_id = aws_route_table.rt_vpc1.id
  subnet_id      = aws_subnet.subnet1.id
}

# Create a Route Default Route
resource "aws_route" "route_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.rt_vpc1.id
}

# Get latest AWS Linux AMI
data "aws_ami" "amazon-linux-2-kernel-5" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }
}

# Create Security Group
resource "aws_security_group" "sg_allow_ssh" {
  name   = "sc_allow_ssh"
  vpc_id = aws_vpc.vpc1.id
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
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

# Create EC2 Instance
resource "aws_instance" "ec2_linux" {
  ami                         = data.aws_ami.amazon-linux-2-kernel-5.id
  subnet_id                   = aws_subnet.subnet1.id
  associate_public_ip_address = true
  instance_type               = var.aws_ec2_instance_type
  key_name                    = var.aws_ec2_key_pair_name
  tags = {
    "Name" = var.aws_ec2_name
  }
  user_data              = <<EOF
  	#! /bin/bash
    sudo yum update -y
  	sudo touch /home/ec2-user/USERDATA_EXECUTED
  EOF
  vpc_security_group_ids = [aws_security_group.sg_allow_ssh.id]
}
