# Infrastructure as Code (IaC) with Terraform: A Comprehensive Guide

Infrastructure as Code (IaC) is a key practice in the world of DevOps, allowing infrastructure provisioning through code. This makes infrastructure reproducible, scalable, and maintainable. Terraform, by HashiCorp, stands out as one of the most popular IaC tools, supporting numerous cloud platforms and services.

This guide is designed to give you a step-by-step instruction on how to transition from a flat, hardcoded, unscalable structure to a modular design that follows best practices. By the end of this guide, we'll also delve into using the Terraform Cloud Development Kit (CDKtf) and discuss the unique benefits it brings to the table.

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

---

# 1. Basic Terraform with a Flat Structure

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

# 2. Advancing with Variables

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

# 4. Scaling with Modular Design

As we grow more sophisticated in our Terraform journey, moving from hardcoded values to variables, another transformative step awaits: the use of Terraform modules. Think back to those initial days when we copied snippets from the documentation. Those snippets were isolated configurations. But as we scaled, we realized that many of these configurations were repetitive, or at the very least, followed common patterns.

Enter Terraform modules. These are akin to functions in programming. Just as you wouldn't want to write the same code repeatedly in a software project, in the world of IaC, you shouldn't have to rewrite similar infrastructure configurations. Modules allow us to encapsulate a specific set of configurations and use them as self-contained units.

Let's delve deeper into the benefits:

1. **Organization**: With modules, you can structure your Terraform configurations in logical units. This is not just about cleanliness but about understanding. When you or a team member revisits the code, modules make it immediately clear how different infrastructure components relate to and depend on each other.

2. **Reusability**: Remember the principle of DRY (Don't Repeat Yourself)? Modules embody this principle. Once a module for, say, configuring an AWS VPC is created, it can be reused across different projects or environments. This not only saves time but ensures consistent and error-free configurations.

3. **Maintainability**: One of the challenges with a flat structure is maintenance. If you needed to change a configuration, it often meant changes in multiple places. But with modules, those configurations are centralized. Want to change the way your AWS VPCs are set up across ten different projects? If you're using a VPC module, that's one change, and it's reflected everywhere the module is used.

In essence, modules are the next evolutionary step in our Terraform journey. After understanding the basics and appreciating the power of variables, modules showcase how Terraform can be both powerful and elegant, simplifying complex infrastructures into manageable, reusable components.

--- 

This enhancement provides a progression from the initial stages of Terraform usage, reinforcing the benefits of modules in a more relatable and comprehensive manner.

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

# 5. Hierarchical Design in Terraform

In larger infrastructure setups, it's not just about organizing resources but also about organizing the way these resources relate to each other. A hierarchical design ensures that resources are managed at the right level of granularity, with dependencies clearly defined. 

For instance, networking components might be managed separately from application instances, but the latter would depend on the former. A hierarchical structure clearly depicts these relationships, making it easier to manage and understand the infrastructure as a whole.

---

# 6. Terraform with AWS and Azure Using CDKtf

The Cloud Development Kit for Terraform (CDKtf) brings the familiar procedural programming model to Terraform, allowing for more dynamic and complex configurations.

## AWS Configuration with CDKtf (`main.ts`)

```typescript
# ... (your configurations)
```
