output "azure_virtual_desktop_keyvault_resource_group" {
  description = "Name of the Resource group in which to deploy session host"
  value       = data.azurerm_resource_group.rg.name
}

output "azure_virtual_desktop_keyvault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "azure_virtual_desktop_keyvault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "location" {
  description = "The Azure region"
  value       = data.azurerm_resource_group.rg.location
}

output "azure_virtual_desktop_keyvault_secret_domainjoinerpassword" {
  description = "Domain joiner password"
  value       = azurerm_key_vault_secret.domainjoinerpassword.value
  sensitive   = true
}

output "azure_virtual_desktop_keyvault_secret_vmlocalpassword" {
  description = "Admin password"
  value       = azurerm_key_vault_secret.vmlocalpassword.value
  sensitive   = true
}

output "vault_uri" {
  value = azurerm_key_vault_secret.vault_uri
}
