# Infrastructure as Code (IaC) with Terraform: A Comprehensive Guide

Infrastructure as Code (IaC) is a pivotal practice in the modern DevOps landscape. It paves the way for provisioning infrastructure through code, turning the infrastructure into something reproducible, scalable, and maintainable. Among the myriad of IaC tools available, Terraform by HashiCorp stands tall, offering support for a plethora of cloud platforms and services.

This guide aims to walk you through a transformation journey: starting from a flat, hardcoded, unscalable structure, gradually evolving into a modular design that aligns with best practices. As a consistent theme throughout this guide, we will be provisioning the same basic infrastructure on both AWS and Azure. This consistent reference point will make it easier for you to track the changes, witnessing firsthand how the code refines and enhances from one section to the next. By the culmination of this guide, we'll also explore the Terraform Cloud Development Kit (CDKtf) and shed light on the distinct advantages it offers.

Join us on this transformative journey, as we navigate the intricacies of Infrastructure as Code, making it more efficient, modular, and powerful with each step.

## What Will We Deploy?
Throughout this guide, we'll be deploying the following components in both AWS and Azure:

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

![IaC Overview](drawings/IaC_overview.png)

---

# 1. [Basic Terraform with a Flat Structure](1-TF-simple-flat-structure)

Starting with the basics, most of us begin our Terraform journey by picking up snippets and examples from the official documentation. We tend to copy, paste, and adjust these examples to fit our immediate needs, directly modifying the hardcoded parameters. While this method offers a quick way to define and provision resources using IaC on platforms like AWS and Microsoft Azure, it's akin to taking our first steps in the vast world of infrastructure automation.

Yet, as our infrastructure needs grow and configurations become more complex, this approach starts to show its limitations. Relying on hardcoded parameters can quickly become cumbersome, leading to potential inconsistencies and errors. While this flat design might seem practical in the beginning, especially when we're still familiarizing ourselves with Terraform, it's not a scalable design for larger, more intricate deployments.

## AWS Configuration (`aws.tf`)

```terraform
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

```

## Azure Configuration (`azure.tf`)

```terraform
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Create a Ressource Group
resource "azurerm_resource_group" "rg_iac" {
  name     = "fdervisi_IaC_basic"
  location = "North Europe"
}

# Create a VNet
resource "azurerm_virtual_network" "vnet_1" {
  resource_group_name = azurerm_resource_group.rg_iac.name
  name                = "vnet_1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_iac.location
}

# Create a Subnet
resource "azurerm_subnet" "subnet_1" {
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = azurerm_resource_group.rg_iac.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  name                 = "subnet_1"
}

# Create a Public IP
resource "azurerm_public_ip" "ip_1" {
  allocation_method = "Static"
  name = "public_ip_1"
  resource_group_name = azurerm_resource_group.rg_iac.name
  location = azurerm_resource_group.rg_iac.location
}

# Create a Network Interface
resource "azurerm_network_interface" "nic_1" {
  name                = "nic_1"
  location            = azurerm_resource_group.rg_iac.location
  resource_group_name = azurerm_resource_group.rg_iac.name
  ip_configuration {
    name                          = "nic_ip"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ip_1.id
  }
}

# Create a VM
resource "azurerm_virtual_machine" "vm_1" {
  name                = "vm_1" 
  location            = azurerm_resource_group.rg_iac.location
  resource_group_name = azurerm_resource_group.rg_iac.name
  vm_size             = "Standard_DS1_v2"
  #key_name            = "fdervisi_cc_ssh_key"
  network_interface_ids = [azurerm_network_interface.nic_1.id]
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  os_profile {
    computer_name  = "ubuntu"
    admin_username = "fatos"
    admin_password = "Zscaler2022"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Print Public IP
  output "azure_vm_public_ip" {
    value = azurerm_public_ip.ip_1.ip_address
  }
```

---

# 2. [Advancing with Variable](2-TF-simple-flat-structure-with-variables)

After our initial foray into Terraform using hardcoded values, the next logical progression is the introduction of variables. Remember those snippets we copied and adjusted from the documentation? They often had direct values mentioned in them. For instance, you might have an AWS region like `eu-south-1` hardcoded multiple times across various configurations. Now, imagine the tedious task of changing this region in every single location should the need arise.

This is where variables come into play. Instead of scattering these values throughout our configurations, we can externalize them into separate variable definitions. By doing this, our configurations become:

1. **Reusable**: Define a variable once, and reference it everywhere in your Terraform files. If you need to change the value, you do it at one place, and it's reflected everywhere the variable is used.
  
2. **Consistent**: Hardcoding values can lead to discrepancies. Maybe you mistype the region in one location or forget to update it in another. Variables ensure consistency across your configurations.
  
3. **Maintainable**: As your infrastructure grows, so does the number of parameters. Keeping track of these in a flat, hardcoded structure can be a nightmare. Variables streamline this by centralizing these parameters, making it easier to manage and modify configurations.

In essence, variables transition our Terraform setup from a one-time, static configuration to a dynamic, adaptable, and scalable infrastructure blueprint. They act as the bridge between the basic, copied-from-the-docs setup and a more professional, scalable design.


## AWS Configuration with Variables (`aws.tf`)

```terraform
# Configure the AWS Provider
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
```

## Azure Configuration with Variables (`azure.tf`)

```terraform
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Create a Ressource Group
resource "azurerm_resource_group" "rg_iac" {
  name     = var.azure_resource_group
  location = var.azure_location
}

# Create a VNet
resource "azurerm_virtual_network" "vnet_1" {
  resource_group_name = azurerm_resource_group.rg_iac.name
  name                = var.azure_vnet_name
  address_space       = [var.azure_vnet_cidr]
  location            = azurerm_resource_group.rg_iac.location
}

# Create a Subnet
resource "azurerm_subnet" "subnet_1" {
  address_prefixes     = [var.azure_subnet_cidr]
  resource_group_name  = azurerm_resource_group.rg_iac.name
  virtual_network_name = azurerm_virtual_network.vnet_1.name
  name                 = var.azure_subnet_name
}

# Create a Public IP
resource "azurerm_public_ip" "ip_1" {
  allocation_method = "Static"
  name = "public_ip_1"
  resource_group_name = azurerm_resource_group.rg_iac.name
  location = azurerm_resource_group.rg_iac.location
}

# Create a Network Interface
resource "azurerm_network_interface" "nic_1" {
  name                = "nic_1"
  location            = azurerm_resource_group.rg_iac.location
  resource_group_name = azurerm_resource_group.rg_iac.name
  ip_configuration {
    name                          = "nic_ip"
    subnet_id                     = azurerm_subnet.subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ip_1.id
  }
}

# Create a VM
resource "azurerm_virtual_machine" "vm_1" {
  name                = var.azure_instance_name
  location            = azurerm_resource_group.rg_iac.location
  resource_group_name = azurerm_resource_group.rg_iac.name
  vm_size             = var.azure_vm_size
  network_interface_ids = [azurerm_network_interface.nic_1.id]
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  os_profile {
    computer_name  = "ubuntu"
    admin_username = var.azure_admin_username
    admin_password = var.azure_admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

```

## Variable File (`variables.tf`)

```terraform
## Input variable definitions
# AWS

variable "aws_region" {
  description = "Region of AWS"
  type        = string
}

variable "aws_vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "aws_subnet_name" {
  description = "Name of Subnet"
  type        = string
}

variable "aws_ec2_name" {
  description = "Name of EC2"
  type        = string
}

variable "aws_ec2_instance_type" {
  description = "Instance Type of EC2"
  type        = string
  default     = "t3.micro"
}

variable "aws_ec2_key_pair_name" {
  description = "Key Pair Name for EC2"
  type        = string
}

# Azure

variable "azure_resource_group" {
  description = "Name of Resource Group"
  type        = string
}

variable "azure_location" {
  description = "Location of Resource Group"
  type        = string
}

variable "azure_vnet_name" {
  description = "Name of VPC"
  type        = string
}

variable "azure_vnet_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azure_subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "azure_subnet_name" {
  description = "Name of Subnet"
  type        = string
}

variable "azure_instance_name" {
  description = "Name of the Instance"
  type        = string
}

variable "azure_vm_size" {
  description = "VM Size of the Instance"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "azure_admin_username" {
  description = "Admin Username for Instance"
  type        = string
}

variable "azure_admin_password" {
  description = "Admin Password for Instance"
  type        = string
}


variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

```

---

# 3. Scaling with Modular Design

As we grow more sophisticated in our Terraform journey, moving from hardcoded values to variables, another transformative step awaits: the use of Terraform modules. Think back to those initial days when we copied snippets from the documentation. Those snippets were isolated configurations. But as we scaled, we realized that many of these configurations were repetitive, or at the very least, followed common patterns.

Enter Terraform modules. These are akin to functions in programming. Just as you wouldn't want to write the same code repeatedly in a software project, in the world of IaC, you shouldn't have to rewrite similar infrastructure configurations. Modules allow us to encapsulate a specific set of configurations and use them as self-contained units.

Let's delve deeper into the benefits:

1. **Organization**: With modules, you can structure your Terraform configurations in logical units. This is not just about cleanliness but about understanding. When you or a team member revisits the code, modules make it immediately clear how different infrastructure components relate to and depend on each other.

2. **Reusability**: Remember the principle of DRY (Don't Repeat Yourself)? Modules embody this principle. Once a module for, say, configuring an AWS VPC is created, it can be reused across different projects or environments. This not only saves time but ensures consistent and error-free configurations.

3. **Maintainability**: One of the challenges with a flat structure is maintenance. If you needed to change a configuration, it often meant changes in multiple places. But with modules, those configurations are centralized. Want to change the way your AWS VPCs are set up across ten different projects? If you're using a VPC module, that's one change, and it's reflected everywhere the module is used.

In essence, modules are the next evolutionary step in our Terraform journey. After understanding the basics and appreciating the power of variables, modules showcase how Terraform can be both powerful and elegant, simplifying complex infrastructures into manageable, reusable components.


## AWS Configuration with Custom Modules (`main.tf`)

```terraform
# Create EC2 and Networking Infrastructre in AWS
module "aws__instances_1" {
  source = "./modules/aws-instance"

  aws_region            = "eu-south-1"
  aws_vpc_name          = "vpc_1"
  aws_subnet_name       = "subnet_1"
  aws_ec2_name          = "ec2_1"
  aws_ec2_key_pair_name = "Key_MBP_fdervisi"

  aws_vpc_cidr    = "10.0.0.0/16"
  aws_subnet_cidr = "10.0.0.0/24"
}
```

## Azure Configuration with Custom Modules (`main.tf`)

```terraform
# Create Virtual Instance and Networking Infrastructre in Azure
module "azure_instances_1" {
  source = "./modules/azure-instance"

  azure_resource_group = "fdervisi_IaC_basic"
  azure_location       = "North Europe"
  azure_vnet_name      = "vnet_1"
  azure_subnet_name    = "subnet_1"
  azure_instance_name  = "vm_1"
  azure_vm_size        = "Standard_DS1_v2"
  azure_admin_username = "fatos"
  azure_admin_password = "Zscaler2022"

  azure_subnet_cidr = "10.0.0.0/16"
  azure_vnet_cidr   = "10.0.0.0/24"
}
```

---

# 4. Leveraging Standard Modules from the Terraform Registry

While creating custom modules offers tailored infrastructure deployment, there's a wealth of community-contributed modules available on the [Terraform Registry](https://registry.terraform.io/). These modules are tested, maintained, and often cover most general use cases, making them a great starting point or supplement to our infrastructure code.

Using such pre-defined modules can significantly reduce the time and effort required to deploy infrastructure components, as they encapsulate best practices and avoid common pitfalls.

Let's see how we can leverage these standard modules for our AWS and Azure deployments:

## AWS Configuration using Terraform Registry Modules (`main.tf`)

```terraform
provider "aws" {
  region = "eu-south-1"
}

# Fetch Available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Fetch latest AWS Linux AMI
data "aws_ami" "amazon-linux-2-kernel-5" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5*"]
  }
}

# Set up AWS Networking using VPC module
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

# Set up AWS EC2 Instances
module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.12.0"

  name                   = "ec2_1"
  instance_count         = 1
  ami                    = data.aws_ami.amazon-linux-2-kernel-5.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  user_data              = <<EOF
  	#! /bin/bash
    sudo yum update -y
  	sudo touch /home/ec2-user/USERDATA_EXECUTED
  EOF
  
  tags = {
    Name = "ec2_1"
  }
}

```

## Azure Configuration using Terraform Registry Modules (`main.tf`)

```terraform
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Define Azure Resource Group
resource "azurerm_resource_group" "rg_iac" {
  name     = "fdervisi_IaC_basic"
  location = "North Europe"
}

# Set up Azure Networking using VNet module
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "3.0.0"
  resource_group_name = azurerm_resource_group.rg_iac.name
  vnet_location       = azurerm_resource_group.rg_iac.location
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.0.0/24"]
  vnet_name           = "vnet_1"
  subnet_names        = ["subnet_1"]
  tags = {
    Name = "vnet_1"
  }
}

# Set up Azure VM using Compute module
module "vm" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.rg_iac.name
  vm_size             = "Standard_DS1_v2"
  vm_os_simple        = "UbuntuServer"
  vnet_subnet_id      = module.vnet.vnet_subnets[0]
  remote_port         = 22
  admin_username      = "fatos"
  admin_password      = "Zscaler2022"

  tags = {
    Name = "vm_1"
  }

  depends_on = [
    azurerm_resource_group.rg_iac
  ]
}
```

---

# 5. Terraform Cloud Development Kit (CDK) vs. Terraform HCL

After exploring the traditional Terraform HashiCorp Configuration Language (HCL) in the previous section, let's delve into the Terraform Cloud Development Kit (CDK) and highlight its differences and benefits compared to standard HCL.

## What is Terraform CDK?

The Terraform CDK is a software development framework that provides a way for users to leverage familiar programming languages, such as TypeScript and Python, to define and provision cloud infrastructure. Instead of writing declarative HCL code, developers can use imperative programming constructs, making it feel more natural to those with a software development background.

Underneath, the Terraform CDK translates the code into standard Terraform configuration (HCL), thus allowing it to leverage the robustness and capabilities of the Terraform engine.

## Benefits of Terraform CDK Over HCL

1. **Familiarity for Developers:** Developers can use the programming languages they are comfortable with, bridging the gap between traditional software development and infrastructure as code.
2. **Reusability:** Thanks to the object-oriented nature of programming languages, developers can create reusable constructs and components. This feature promotes best practices and ensures consistency across multiple projects.
3. **Iterative Development:** With the CDK, developers can use iterative programming constructs, like loops and conditions, to generate dynamic infrastructure configurations.
4. **Provider Agnostic:** The Terraform CDK maintains Terraform's advantage of being provider agnostic. This means that it can be used to provision infrastructure across multiple cloud providers.

```typescript
import { Construct } from 'constructs';
import { App, TerraformOutput, TerraformStack } from 'cdktf';
import { AwsProvider } from '@cdktf/provider-aws/lib/provider';
import { AzurermProvider } from '@cdktf/provider-azurerm/lib/provider';
import { Vpc } from '@cdktf/provider-aws/lib/vpc';
import { Subnet as AwsSubnet } from '@cdktf/provider-aws/lib/subnet';
import { InternetGateway } from '@cdktf/provider-aws/lib/internet-gateway';
import { RouteTable } from '@cdktf/provider-aws/lib/route-table';
import { RouteTableAssociation } from '@cdktf/provider-aws/lib/route-table-association';
import { Route } from '@cdktf/provider-aws/lib/route';
import { DataAwsAmi } from '@cdktf/provider-aws/lib/data-aws-ami';
import { SecurityGroup } from '@cdktf/provider-aws/lib/security-group';
import { Instance } from '@cdktf/provider-aws/lib/instance';
import { ResourceGroup } from '@cdktf/provider-azurerm/lib/resource-group';
import { VirtualNetwork } from '@cdktf/provider-azurerm/lib/virtual-network';
import { LinuxVirtualMachine } from '@cdktf/provider-azurerm/lib/linux-virtual-machine';
import { Subnet } from '@cdktf/provider-azurerm/lib/subnet';
import { NetworkInterface } from '@cdktf/provider-azurerm/lib/network-interface';

class MyAwsStack extends TerraformStack {
  region: any;
  vpc: Vpc;
  subnet: AwsSubnet;
  igw: InternetGateway;
  rt: RouteTable;
  rt_association: RouteTableAssociation;
  route_igw: Route;
  aws_ami: DataAwsAmi;
  sg: SecurityGroup;
  ec2: Instance;
  constructor(scope: Construct, id: string) {
    super(scope, id);

    // Region
    this.region = 'eu-south-1';

    // Configure the AWS Provider
    new AwsProvider(this, 'AWS', { region: this.region });

    // Create a VPC
    this.vpc = new Vpc(this, 'vpc_1', {
      cidrBlock: '10.0.0.0/16',
      tags: { Name: 'vpc_1' },
    });

    // Create a Subnet
    this.subnet = new AwsSubnet(this, 'subnet_1', {
      cidrBlock: '10.0.0.0/24',
      vpcId: this.vpc.id,
      tags: { Name: 'subnet_1' },
    });

    // Create a IGW
    this.igw = new InternetGateway(this, 'igw', {
      vpcId: this.vpc.id,
      tags: { Name: 'igw_vpc_1' },
    });

    // Create a Route Table
    this.rt = new RouteTable(this, 'rt', {
      vpcId: this.vpc.id,
      tags: { Name: 'rt_vpc_1' },
    });

    // Create a Route Table Association
    this.rt_association = new RouteTableAssociation(
      this,
      'rt_association_vpc1',
      { routeTableId: this.rt.id, subnetId: this.subnet.id }
    );

    // Create a Default Route
    this.route_igw = new Route(this, 'route_igw', {
      routeTableId: this.rt.id,
      destinationCidrBlock: '0.0.0.0/0',
      gatewayId: this.igw.id,
    });

    // Get latest AWS Linux AMI
    this.aws_ami = new DataAwsAmi(this, 'aws_ami', {
      mostRecent: true,
      owners: ['amazon'],
      filter: [{ name: 'name', values: ['amzn2-ami-kernel-5*'] }],
    });

    // Create Security Group
    this.sg = new SecurityGroup(this, 'sg', {
      name: 'sg_allow_ssh',
      vpcId: this.vpc.id,
      ingress: [
        { description: 'ssh', protocol: 'tcp', fromPort: 22, toPort: 22 },
      ],
    });

    // Create EC2 instance
    this.ec2 = new Instance(this, 'ec2_1', {
      ami: this.aws_ami.id,
      associatePublicIpAddress: true,
      subnetId: this.subnet.id,
      instanceType: 't3.micro',
      vpcSecurityGroupIds: [this.sg.id],
      userData: `
        #! /bin/bash
        sudo yum update -y
        sudo touch /home/ec2-user/USERDATA_EXECUTED
        `,
      tags: { Name: 'ec2_1' },
    });

    // Output Public IP
    new TerraformOutput(this, 'public_ip', {
      value: this.ec2.publicIp,
      description: 'EC2 Public IP',
    });
  }
}

class MyAzureStack extends TerraformStack {
  rg: ResourceGroup;
  vnet: VirtualNetwork;
  subnet: Subnet;
  network_interface: NetworkInterface;
  vm: LinuxVirtualMachine;

  constructor(scope: Construct, name: string) {
    super(scope, name);

    new AzurermProvider(this, 'AzureRm', {
      features: {
        resourceGroup: { preventDeletionIfContainsResources: false },
      },
    });

    // Create a Ressource Group
    this.rg = new ResourceGroup(this, 'rg', {
      name: 'fdervisi_IaC_basic',
      location: 'North Europe',
    });

    // Create a VNet
    this.vnet = new VirtualNetwork(this, 'vnet_1', {
      resourceGroupName: this.rg.name,
      name: 'vnet_1',
      location: this.rg.location,
      addressSpace: ['10.0.0.0/16'],
    });

    // Create a Subnet
    this.subnet = new Subnet(this, 'subnet', {
      addressPrefixes: ['10.0.0.0/16'],
      resourceGroupName: this.rg.name,
      virtualNetworkName: this.vnet.name,
      name: 'subnet_1',
    });

    // Create Network Interface
    this.network_interface = new NetworkInterface(this, 'nic', {
      name: 'nic_1',
      location: this.rg.location,
      resourceGroupName: this.rg.name,
      ipConfiguration: [
        {
          name: 'nic_ip',
          subnetId: this.subnet.id,
          privateIpAddressAllocation: 'Dynamic',
        },
      ],
    });

    // Create a VM
    this.vm = new LinuxVirtualMachine(this, 'vm', {
      name: 'vm-1',
      location: this.rg.location,
      resourceGroupName: this.rg.name,
      size: 'Standard_DS1_v2',
      networkInterfaceIds: [this.network_interface.id],
      disablePasswordAuthentication: false,
      adminUsername: 'Fatos',
      adminPassword: 'Zscaler2022',
      osDisk: { caching: 'ReadWrite', storageAccountType: 'Standard_LRS' },
      sourceImageReference: {
        publisher: 'Canonical',
        offer: 'UbuntuServer',
        sku: '16.04-LTS',
        version: 'latest',
      },
    });
  }
}

const app = new App();
new MyAwsStack(app, 'AwsStack');
new MyAzureStack(app, 'AzureStack');

app.synth();

```

## Analyzing the Code

The code offers an insightful look into the Terraform CDK's capabilities:

1. **Hardcoded Values:** As with the earlier HCL example, the CDK code also has hardcoded values for various infrastructure components. This means there's a direct mapping between the CDK and its equivalent HCL, making it easier for those familiar with HCL to transition to the CDK.
2. **Class-Based Definitions:** The code uses classes like `MyAwsStack` and `MyAzureStack` to define infrastructure for AWS and Azure, respectively. Each class encapsulates the logic for provisioning specific cloud resources, promoting a modular approach.
3. **App Synthesis:** The CDK uses the `App` construct to combine multiple infrastructure stacks and generate the corresponding HCL code.


## Conclusion

The Terraform CDK offers a fresh perspective on defining cloud infrastructure. While it might not replace HCL for all use cases, it provides an alternative for those who prefer a more programmatic approach to infrastructure as code. Whether you're a seasoned developer or an infrastructure specialist, understanding the strengths and use cases for both HCL and the Terraform CDK can help in selecting the right tool for the job.

It's important to note that the provided CDK example is a basic representation and doesn't employ programming best practices. Many of the values are hardcoded, similar to our initial flat hardcoded example in Terraform HCL. If there's interest, I can also delve into a more comprehensive guide on best practices with Terraform CDK, ensuring that you're equipped to craft efficient, scalable, and maintainable infrastructure code.
