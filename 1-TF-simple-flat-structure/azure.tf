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