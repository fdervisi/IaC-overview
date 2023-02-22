# Basic Terraform with Custom Modular Design
This example demonstrates a modular design approach for scaling infrastructure resources in Terraform.

In Terraform, modules are self-contained packages of Terraform configuration, which can be used to organize and encapsulate resource configurations. By using a modular design approach, it becomes easier to create and manage infrastructure resources that share common functionality and can be replicated as needed.

For instance, if the infrastructure requires multiple instances of the same resource with different parameters, it's easier to create a module that encapsulates the resource configurations and use that module to create multiple instances with different parameters. This helps in reducing the duplication of code, making the code easier to manage, and reducing the likelihood of errors.

The use of modules also allows for easier maintenance and updating of the resources over time, and it enables the reuse of resource configurations across different projects.

By combining modular design, the infrastructure resources can be deployed and managed easily, and it makes the code more scalable and maintainable over time.

## [main.tf](main.tf)
This Terraform code is deploying infrastructure on both AWS and Azure using modules to achieve a modular design. The aws_instances_1 module creates an EC2 instance and networking infrastructure on AWS, while the azure_instances_1 module creates a virtual instance and networking infrastructure on Azure.

For the aws_instances_1 module, the AWS region is specified as eu-south-1, the VPC and subnet names are specified as vpc_1 and subnet_1, respectively, and the name of the EC2 instance is ec2_1. Additionally, the key pair name and the CIDR blocks for the VPC and subnet are specified.

For the azure_instances_1 module, the resource group name is specified as fdervisi_IaC_basic, the location is specified as North Europe, the VNet name is specified as vnet_1, and the subnet name is specified as subnet_1. The name of the virtual instance is specified as vm_1, and the size of the virtual machine is specified as Standard_DS1_v2. The admin username and password are also specified. Additionally, the CIDR blocks for the VNet and subnet are specified.

Both modules use a source value to specify the location of the module code. The AWS module is located in ./modules/aws-instance, while the Azure module is located in ./modules/azure-instance.