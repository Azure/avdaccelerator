# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource" {
  description = "The full output for the Monitor Data Collection Rule."
  value       = azurerm_monitor_data_collection_rule.this
}
