# Create a new log analytics workspace for the AVD insights workbook
resource "azurerm_log_analytics_workspace" "lawksp" {
  name                = lower(replace("law-avd-${var.prefix}", "-", ""))
  location            = var.avdLocation
  resource_group_name = azurerm_resource_group.share.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = local.tags
}