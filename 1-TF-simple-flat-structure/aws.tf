# Configure the AWS Provider
provider "aws" {
  region = "eu-south-1"
}

# Create a VPC
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "vpc_1"
  }
}

# Create a Subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.0.0/24"
  tags = {
    "Name" = "subnet_1"
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
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }
}

# Create Security Group
resource "aws_security_group" "sg_allow_ssh" {
  name   = "sg_allow_ssh"
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
  instance_type               = "t3.micro"
  key_name                    = "Key_MBP_fdervisi"
  user_data                   = <<EOF
  	#! /bin/bash
    sudo yum update -y
  	sudo touch /home/ec2-user/USERDATA_EXECUTED
  EOF
  vpc_security_group_ids      = [aws_security_group.sg_allow_ssh.id]
  tags = {
    "Name" = "ec2_linux"
  }
}

# Output Public IP
output "aws_ec2_public_ip" {
  value = aws_instance.ec2_linux.public_ip
}
