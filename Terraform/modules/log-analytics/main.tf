provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "log" {
  name     = "${var.prefix}law-rg"
  location = var.location
}

# Creates Log Anaylytics Workspace
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "log${random_string.random.id}"
  location            = var.location
  resource_group_name = azurerm_resource_group.log.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}