# Basic Terraform with flat structure and variables
This example is still using a flat structure in Terraform. To make the code more modular, the parameters have been abstracted into a separate file, which can be used to parameterize the resources, allowing for the code to be easily reusable. This approach also helps reduce the risk of errors, which can occur when the same information is hard-coded in multiple places.

## [aws.tf](aws.tf)
The code starts with defining the AWS provider, and sets the region to use as a variable.

Then, it creates a Virtual Private Cloud (VPC) with a given CIDR block and name. It also creates a subnet within the VPC with a given CIDR block and name.

An internet gateway is created and attached to the VPC.

A route table is created with a default route pointing to the internet gateway.

The code then gets the latest Amazon Linux 2 AMI that uses the Linux kernel version 5.

A security group is created to allow inbound SSH traffic on port 22, and all outbound traffic.

Finally, an EC2 instance is launched with the given instance type, key pair, and user data. The instance is also associated with the previously created VPC and subnet, and assigned with the previously created security group.

All the resources created have tags to identify and organize them in the AWS console.

## [azure.tf](azure.tf)
The code first configures the azurerm provider with a feature that prevents resource group deletion if it contains resources.

Then, it creates an Azure resource group with the specified name and location.

After that, it creates a virtual network, a subnet, and a public IP address, all attached to the resource group. A network interface is created with a public IP address and attached to the subnet.

Finally, a virtual machine is created with the specified name, location, resource group, VM size, network interface, OS disk, and image reference. The OS profile is also set with the username and password for the virtual machine. The OS profile Linux configuration is also set to allow password authentication.

## [provider.tf](provider.tf)
Here we define the AWS and Azure provider which will be used.

## [variables.tf](variables.tf)
Here we define the **type** of [variables](https://developer.hashicorp.com/terraform/language/values/variables) to be used in the code.

## [terraform.tfvars](terraform.tfvars)
Here we define the **value** of variables to be used in the code. Terraform also automatically loads variable definitions file when it named exacly as ```terraform.tfvars```