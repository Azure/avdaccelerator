output "azure_virtual_desktop_compute_resource_group" {
  description = "Name of the Resource group in which to deploy session host"
  value       = azurerm_resource_group.rg.name
}

output "azure_virtual_desktop_host_pool" {
  description = "Name of the Azure Virtual Desktop host pool"
  value       = azurerm_virtual_desktop_host_pool.hostpool.name
}

output "azurerm_virtual_desktop_application_group" {
  description = "Name of the Azure Virtual Desktop DAG"
  value       = azurerm_virtual_desktop_application_group.dag.name
}

output "azurerm_virtual_desktop_workspace" {
  description = "Name of the Azure Virtual Desktop workspace"
  value       = azurerm_virtual_desktop_workspace.workspace.name
}

output "location" {
  description = "The Azure region"
  value       = azurerm_resource_group.rg.location
}

output "session_host_count" {
  description = "The number of VMs created"
  value       = var.rdsh_count
}

output "dnsservers" {
  description = "Custom DNS configuration"
  value       = data.azurerm_virtual_network.vnet.dns_servers
}

output "vnetrange" {
  description = "Address range for deployment vnet"
  value       = data.azurerm_virtual_network.vnet.address_space
}

output "AVD_user_groupname" {
  description = "Microsoft Entra ID Group for AVD users"
  value       = data.azuread_group.adds_group.display_name
}
output "vault_uri" {
  value     = azurerm_key_vault.kv.vault_uri
  sensitive = false
}
output "vault_name" {
  value     = azurerm_key_vault.kv.name
  sensitive = false
}
output "KeyVaultResourceId" {
  value     = azurerm_key_vault.kv.id
  sensitive = false
}

output "storge_idnetity" {
  value     = azurerm_storage_account.storage.identity
  sensitive = false
}
