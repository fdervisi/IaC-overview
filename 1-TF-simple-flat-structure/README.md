# Basic Terraform with flat structure
This code is a simple example of how to define and provision resources using IaC on both AWS and Microsoft Azure. However, it is not a scalable and modular design because all of the parameters are hard coded in the code.

This means that if changes need to be made to any of the resources, such as the region or the size of the virtual machine, they would need to be manually edited in the code. This can become cumbersome and error-prone, especially as the number of resources and the complexity of the infrastructure grows.


## [aws.tf](aws.tf)
The code starts by configuring the AWS provider with the region set to "eu-south-1".

The code then creates a Virtual Private Cloud (VPC) with the CIDR block "10.0.0.0/16" and the name "vpc_1". Next, it creates a subnet with the CIDR block "10.0.0.0/24" and associates it with the VPC.

An internet gateway (IGW) is created and associated with the VPC. A route table is created and associated with the VPC. A route table association is created to associate the subnet with the route table.

A default route is created to allow traffic to the internet via the IGW.

The code then retrieves the latest Amazon Machine Image (AMI) for the Amazon Linux 2 operating system with kernel version 5.

A security group is created to allow SSH traffic from any IP address. An EC2 instance is created with the retrieved AMI, the previously created subnet, a t3.micro instance type, and a key pair named "Key_MBP_fdervisi". The EC2 instance is also associated with the security group and has a user data script that updates the operating system and creates a file.

The public IP address of the EC2 instance is printed as an output variable.

## [azure.tf](azure.tf)
The code starts by configuring the Azure provider with features that enable resource group deletion only if it doesn't contain any resources.

The code then creates a resource group with the name "fdervisi_IaC_basic" and the location "North Europe". Next, it creates a virtual network with the name "vnet_1" and the address space "10.0.0.0/16". It also creates a subnet with the address prefix "10.0.0.0/24" and associates it with the virtual network.

A public IP is created with the name "public_ip_1" and the allocation method set to "Static". The public IP is associated with a network interface card (NIC) that is created next. The NIC is named "nic_1" and is associated with the subnet and virtual network created earlier.

Finally, a virtual machine is created with the name "vm_1" and is associated with the NIC. The virtual machine uses an Ubuntu Server image and is configured with a static public IP address and an admin username and password. The public IP address is printed as an output variable.


## [provider.tf](provider.tf)
Here we define the AWS and Azure provider which will be used.