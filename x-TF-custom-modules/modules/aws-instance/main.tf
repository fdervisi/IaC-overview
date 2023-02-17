# Configure the AWS Provider
# provider "aws" {
#   region = var.aws_region
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "vpc1" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name  = var.aws_vpc_name
    Owner = var.aws_owner_tag
  }
}

# Create a Subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = var.aws_subnet_cidr
  tags = {
    Name  = var.aws_subnet_name
    Owner = var.aws_owner_tag
  }
}

# Create a IGW
resource "aws_internet_gateway" "igw" {
  # create ressource only if aws_vpc_public_ip is set to true
  count  = var.aws_vpc_public_ip ? 1 : 0
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name  = "igw_vpc_1"
    Owner = var.aws_owner_tag
  }
}

# Create a Route Table
resource "aws_route_table" "rt_vpc1" {
  # create ressource only if aws_vpc_public_ip is set to true
  count  = var.aws_vpc_public_ip ? 1 : 0
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name  = "rt_vpc_1"
    Owner = var.aws_owner_tag
  }
}

# Create a Route Table Association
resource "aws_route_table_association" "rt_association_vpc1" {
  # create ressource only if aws_vpc_public_ip is set to true
  count          = var.aws_vpc_public_ip ? 1 : 0
  route_table_id = aws_route_table.rt_vpc1[count.index].id
  subnet_id      = aws_subnet.subnet1.id
}

# Create a Route Default Route
resource "aws_route" "route_igw" {
  # create ressource only if aws_vpc_public_ip is set to true
  count                  = var.aws_vpc_public_ip ? 1 : 0
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[count.index].id
  route_table_id         = aws_route_table.rt_vpc1[count.index].id
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
  tags = {
    Name  = "sg_allow_ssh"
    Owner = var.aws_owner_tag
  }
}

## create SSM Manager Endpoint
# security group for SSM endpoints
resource "aws_security_group" "sg_endpoint" {
  name_prefix = "sg_endpoints"
  description = "Allow HTTPS outbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "sg_ssm_endpoints"
    Owner = var.aws_owner_tag
  }
}

# iam role for SSM Manager
resource "aws_iam_instance_profile" "ssm_manager_iam_profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ssm_manager_iam_role.name
}
resource "aws_iam_role" "ssm_manager_iam_role" {
  name               = "ssm_manager_iam_role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    Owner = var.aws_owner_tag
  }
}
resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.ssm_manager_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# endpoints for SSM Manager
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.vpc1.id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [
    aws_security_group.sg_endpoint.id,
  ]
  subnet_ids          = [aws_subnet.subnet1.id]
  private_dns_enabled = true
  tags = {
    Owner = var.aws_owner_tag
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.vpc1.id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg_endpoint.id,
  ]
  subnet_ids          = [aws_subnet.subnet1.id]
  private_dns_enabled = true
  tags = {
    Owner = var.aws_owner_tag
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.vpc1.id
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg_endpoint.id,
  ]
  subnet_ids          = [aws_subnet.subnet1.id]
  private_dns_enabled = true
  tags = {
    Owner = var.aws_owner_tag
  }
}


# Create EC2 Instance
resource "aws_instance" "ec2_linux" {
  ami                         = data.aws_ami.amazon-linux-2-kernel-5.id
  subnet_id                   = aws_subnet.subnet1.id
  iam_instance_profile        = aws_iam_instance_profile.ssm_manager_iam_profile.id
  associate_public_ip_address = true
  instance_type               = var.aws_ec2_instance_type
  key_name                    = var.aws_ec2_key_pair_name
  tags = {
    Name  = var.aws_ec2_name
    Owner = var.aws_owner_tag
  }
  user_data              = <<EOF
  	#! /bin/bash
    sudo yum update -y
  	sudo touch /home/ec2-user/USERDATA_EXECUTED
  EOF
  vpc_security_group_ids = [aws_security_group.sg_allow_ssh.id]
}


