# Terraform configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region = "eu-south-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  azs = var.vpc_azs
  name = "vpc_1"
  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.0.0/24"]
  public_subnets  = ["10.0.1.0/24"]

  enable_nat_gateway = "true"

  tags = {
    Name        = "vpc_1"
    Environment = "dev"
  }
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  name           = "ec2_1"
  instance_count = 1

  ami                    = "ami-027379bcf3d69010d"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Name        = "ec2_1"
    Environment = "dev"
  }
}
