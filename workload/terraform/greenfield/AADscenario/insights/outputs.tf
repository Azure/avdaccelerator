output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.lawksp.workspace_id
}

output "log_analytics_workspace_key" {
  value = azurerm_log_analytics_workspace.lawksp.primary_shared_key
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.lawksp.name
}
