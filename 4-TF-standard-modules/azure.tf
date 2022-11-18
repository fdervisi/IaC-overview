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

# Create Networking
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

# Create a VM
module "vm" {
  source              = "Azure/compute/azurerm"
  resource_group_name = azurerm_resource_group.rg_iac.name
  vm_size             = "Standard_DS1_v2"
  vm_os_simple        = "UbuntuServer"
  vnet_subnet_id      = module.vnet.vnet_subnets[0]
  admin_username      = "fatos"
  admin_password      = "Zscaler2022"

  tags = {
    Name = "vm_1"
  }
}
