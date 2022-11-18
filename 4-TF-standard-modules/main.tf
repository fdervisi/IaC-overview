# Terraform configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "aws" {
  region = "eu-south-1"
}

# Get Availability Zones Linux AMI
data "aws_availability_zones" "available" {
  state = "available"
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

# Create Networking
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  azs            = var.vpc_azs
  name           = "vpc_1"
  cidr           = "10.0.0.0/16"
  public_subnets = ["10.0.0.0/24"]
  tags = {
    Name = "vpc_1"
  }
}

# Create Instance
module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  name                   = "ec2_1"
  instance_count         = 1
  ami                    = data.aws_ami.amazon-linux-2-kernel-5.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  tags = {
    Name = "ec2_1"
  }
}

# Create a Ressource Group
resource "azurerm_resource_group" "rg_iac" {
  name     = "fdervisi_IaC_basic"
  location = "North Europe"
}


module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "3.0.0"
  resource_group_name = azurerm_resource_group.rg_iac.name
  vnet_location = azurerm_resource_group.rg_iac.location
}
