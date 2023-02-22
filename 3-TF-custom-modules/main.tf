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
