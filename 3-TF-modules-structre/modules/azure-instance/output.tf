# Print Azure Instance Public
output "azure_vm_public_ip" {
  value = azurerm_public_ip.ip_1.ip_address
}
