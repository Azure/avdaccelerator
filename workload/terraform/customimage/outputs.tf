output "resource_group_name" {
  value = azurerm_resource_group.aib.name
}

output "location" {
  value = azurerm_resource_group.aib.location
}

output "managed_identity_name" {
  value = azurerm_user_assigned_identity.aib.name
}

output "shared_image_id" {
  value = azurerm_shared_image.aib.id
}