# Basic Terraform Deployment Using Standard Modules from the Terraform Registry
This example demonstrates a modular design approach for scaling infrastructure resources in Terraform. By leveraging standard modules from the Terraform Registry, the example showcases how to create a highly scalable infrastructure using reusable components.

In Terraform, modules are self-contained packages of Terraform configuration, which can be used to organize and encapsulate resource configurations. By using a modular design approach, it becomes easier to create and manage infrastructure resources that share common functionality and can be replicated as needed.

For instance, if the infrastructure requires multiple instances of the same resource with different parameters, it's easier to create a module that encapsulates the resource configurations and use that module to create multiple instances with different parameters. This helps in reducing the duplication of code, making the code easier to manage, and reducing the likelihood of errors.

The use of standard modules from the Terraform Registry provides a powerful tool for easily accessing and reusing common infrastructure resources. With thousands of available modules, it's easy to find pre-built solutions for common infrastructure components, such as databases, load balancers, and security groups, among others.

By combining modular design and the use of standard modules from the Terraform Registry, the infrastructure resources can be deployed and managed easily, making the code more scalable and maintainable over time.

## [aws.tf](aws.tf)
This Terraform code creates an AWS VPC (Virtual Private Cloud), a public subnet, and an EC2 (Elastic Compute Cloud) instance within the VPC. The VPC and EC2 resources are created using the standard modules from the Terraform Registry.

The AWS provider is configured with the region "eu-south-1". The aws_availability_zones data source is used to get the available availability zones for the selected region. The aws_ami data source is used to get the latest available Amazon Linux 2 AMI with kernel 5.

The terraform-aws-modules/vpc/aws module is used to create the VPC and public subnet resources. The VPC has the name "vpc_1" and a CIDR block of "10.0.0.0/16". The public subnet has a CIDR block of "10.0.0.0/24" and is associated with the VPC. The VPC and subnet are both tagged with "Name = vpc_1".

The terraform-aws-modules/ec2-instance/aws module is used to create the EC2 instance. The instance has the name "ec2_1", is of type "t3.micro", and is associated with the public subnet created in the previous step. The user-data script is executed on the instance, which updates the OS and creates a file. The EC2 instance and security group are both tagged with "Name = ec2_1".

## [azure.tf](azure.tf)
This code creates a basic Azure infrastructure using Terraform, where a Resource Group and a Virtual Network are created. The Virtual Network is created using the official Azure vnet module, which is sourced from the Terraform Registry. The module is used to define the Azure Virtual Network and Subnet. A virtual machine is also created using the official Azure compute module, which is sourced from the Terraform Registry. The virtual machine is configured to use the previously created Resource Group and Virtual Network.

The Azure provider is configured, and a resource group named "fdervisi_IaC_basic" is created in the North Europe region. The Terraform code then uses the Azure vnet module to create a virtual network named "vnet_1" with a single subnet named "subnet_1" in the defined Resource Group.

The Terraform code also creates a virtual machine named "vm_1" using the Azure compute module. The virtual machine uses the previously created Resource Group and Virtual Network, has an Ubuntu operating system, and is configured with an administrative username and password. The virtual machine is also tagged with "Name = vm_1".
