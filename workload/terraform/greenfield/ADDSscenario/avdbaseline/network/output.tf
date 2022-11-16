output "location" {
  value       = azurerm_resource_group.net.location
  description = "Azure Resource Group Location"
}

output "rg_name" {
  value       = azurerm_resource_group.net.name
  description = "Azure Resource Group Name"
}

output "rg_id" {
  value       = azurerm_resource_group.net.id
  description = "Azure Resource Group ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "Azure Vnet Name"
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "The ID of the VNet."
}

output "subnet_subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "subnet_name" {
  value = azurerm_subnet.subnet.name
}

output "nsg_name" {
  value       = azurerm_network_security_group.res-0.name
  description = "Azure NSG Name"
}

output "nsg_id" {
  value       = azurerm_network_security_group.res-0.id
  description = "The ID of the NSG."
}

