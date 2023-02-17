# Terraform configuration

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.0"
#     }
#   }
# }

# provider "aws" {
#   region = "eu-south-1"
# }

# Create EC2 and Networking Infrastructre in AWS
module "aws_instances_1" {
  source = "./modules/aws-instance"

  aws_region            = "eu-south-1"
  aws_owner_tag         = "fdervisi"
  aws_vpc_name          = "vpc_1"
  aws_subnet_name       = "subnet_1"
  aws_ec2_name          = "ec2_1"
  aws_ec2_key_pair_name = "Key_MBP_fdervisi"

  aws_vpc_cidr      = "10.0.0.0/16"
  aws_subnet_cidr   = "10.0.0.0/24"
  aws_vpc_public_ip = false
}

provider "aws" {
  region = "eu-south-1"
}

module "tgw" {
  source = "terraform-aws-modules/transit-gateway/aws"

  name        = "tgw_cc"
  description = "TGW for central Cloud Connector VPC"

  #transit_gateway_cidr_blocks = ["10.99.0.0/24"]

  # When "true" there is no need for RAM resources if using multiple AWS accounts
  enable_auto_accept_shared_attachments = true
  share_tgw                             = false

  vpc_attachments = {
    vpc1 = {
      vpc_id                                          = module.aws_instances_1.vpc_id
      subnet_ids                                      = [module.aws_instances_1.subnet_id]
      dns_support                                     = true
      ipv6_support                                    = false
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      # tgw_routes = [
      #   {
      #     destination_cidr_block = "30.0.0.0/16"
      #   },
      #   {
      #     blackhole              = true
      #     destination_cidr_block = "0.0.0.0/0"
      #   }
      # ]
    },
    vpc2 = {
      vpc_id     = "vpc-00f0bdfa2fa2b6bce"
      subnet_ids = ["subnet-0230288b43405b9fe", "subnet-0fd46d9f96d54fe5b"]

      tgw_routes = [
        {
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    },
  }

  tags = {
    Owner = "fdervisi"
  }
}
