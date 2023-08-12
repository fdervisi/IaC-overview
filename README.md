# 1. Infrastructure as Code (IaC) with Terraform: A Comprehensive Guide

Welcome to the comprehensive guide for Infrastructure as Code (IaC) with Terraform. This guide aims to present various capabilities of Terraform through easy-to-understand examples. We'll transition from a basic flat structure, where parameters are hard-coded, to a highly scalable modular design. The examples utilize standard Terraform modules and custom modules, featuring resources deployed in both AWS and Azure.

## What Will We Deploy?
Here's a glimpse of the infrastructure components we'll deploy in both AWS and Azure:

**AWS**:
- VPC
- Internet Gateway
- Subnet
- Virtual Machine

**Azure**:
- VNet
- Internet Gateway
- Subnet
- Virtual Machine

![IaC Overview](/mnt/data/IaC_overview.png)

# 2. Basic Terraform with flat structure

This section provides a simple example of how to define and provision resources using IaC on both AWS and Microsoft Azure. However, it emphasizes that this approach is not scalable and modular due to hardcoded parameters. This makes changes cumbersome and can introduce errors.

## AWS Configuration (`aws.tf`)
\```terraform
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
# ... (and more configurations)
\```

## Azure Configuration (`azure.tf`)
\```terraform
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
# Create a Resource Group
resource "azurerm_resource_group" "rg_iac" {
  name     = "fdervisi_IaC_basic"
  location = "North Europe"
}
# ... (and more configurations)
\```

# 3. Basic Terraform with Flat Structure and Variables

In this section, the Terraform code still uses a flat structure. However, the parameters have been abstracted into a separate file, enhancing modularity. This separation allows the code to be reusable and reduces potential errors from hard-coding the same information in multiple places.

## AWS Configuration with Variables (`aws.tf`)
\```terraform
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
# ... (and more configurations)
\```

## Azure Configuration with Variables (`azure.tf`)
\```terraform
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
# Create a Resource Group
resource "azurerm_resource_group" "rg_iac" {
  name     = "fdervisi_IaC_basic"
  location = "North Europe"
}
# ... (and more configurations)
\```

# 4. Basic Terraform with Custom Modular Design

This section showcases the modular design approach for scaling infrastructure resources with Terraform.

## AWS Configuration with Custom Modules (`main.tf`)
\```terraform
# Create EC2 and Networking Infrastructure in AWS
module "aws__instances_1" {
  source = "./modules/aws-instance"
  aws_region            = "eu-south-1"
  aws_vpc_name          = "vpc_1"
  aws_subnet_name       = "subnet_1"
  aws_ec2_name          = "ec2_1"
  aws_ec2_key_pair_name = "Key_MBP_fdervisi"
  aws_vpc_cidr          = "10.0.0.0/16"
  aws_subnet_cidr       = "10.0.0.0/24"
}
\```

## Azure Configuration with Custom Modules (`main.tf`)
\```terraform
# Create Virtual Instance and Networking Infrastructure in Azure
module "azure_instances_1" {
  source = "./modules/azure-instance"
  azure_resource_group  = "fdervisi_IaC_basic"
  azure_location        = "North Europe"
  azure_vnet_name       = "vnet_1"
  azure_subnet_name     = "subnet_1"
  azure_instance_name   = "vm_1"
  azure_vm_size         = "Standard_DS1_v2"
  azure_admin_username  = "fatos"
  azure_admin_password  = "Zscaler2022"
}
\```

# 5. Basic Terraform Deployment Using Standard Modules from the Terraform Registry

This section emphasizes the advantages of leveraging standard modules from the Terraform Registry. By utilizing these ready-to-use modules, infrastructure deployment becomes more scalable, as it leverages reusable components.

## AWS Configuration with Standard Modules (`aws.tf`)
\```terraform
provider "aws" {
  region = "eu-south-1"
}
# Get Availability Zones and AWS Linux AMI
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_ami" "amazon-linux-2-kernel-5" {
  # ... (configuration details)
}
# Create Networking using a standard VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"
  # ... (configuration details)
}
# Create EC2 instance using a standard EC2 module
module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"
  # ... (configuration details)
}
\```

# 6. Terraform with AWS and Azure Using CDKtf

This section provides a basic demonstration of using the Cloud Development Kit for Terraform (CDKtf) to define and provision infrastructure across both AWS and Azure.

## AWS Configuration with CDKtf (`main.ts`)
\```typescript
import { Construct } from 'constructs';
import { App, TerraformOutput, TerraformStack } from 'cdktf';
import { AwsProvider } from '@cdktf/provider-aws/lib/provider';
import { Vpc } from '@cdktf/provider-aws/lib/vpc';
import { Subnet as AwsSubnet } from '@cdktf/provider-aws/lib/subnet';
import { InternetGateway } from '@cdktf/provider-aws/lib/internet-gateway';
import { RouteTable } from '@cdktf/provider-aws/lib/route-table';
// ... (and more imports)
class MyAwsStack extends TerraformStack {
  // Definition of various AWS resources like VPC, Subnet, InternetGateway, etc.
  // ...
}
\```



