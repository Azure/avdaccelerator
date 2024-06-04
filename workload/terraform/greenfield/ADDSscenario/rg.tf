# Create a Resource Group for AVD Host Pool, Application Group, Workspace (Service Object)
resource "azurerm_resource_group" "this" {
  location = var.avdLocation
  name     = "rg-avd-${var.prefix}-${var.environment}-${var.avdLocation}-${var.rg_so}"
}

# Create a Resource Group for Storage 
resource "azurerm_resource_group" "rg" {
  location = var.avdLocation
  name     = "rg-avd-${var.prefix}-${var.environment}-${var.avdLocation}-${var.rg_stor}"
  tags     = local.tags
}

# Create a Resource Group for Pool Session Hosts
resource "azurerm_resource_group" "shrg" {
  location = var.avdLocation
  name     = "rg-avd-${var.prefix}-${var.environment}-${var.avdLocation}-${var.rg_pool}"
  tags     = local.tags
}

# Create a Resource Group for AVD insights
resource "azurerm_resource_group" "mon" {
  location = var.avdLocation
  name     = "rg-avd-${var.environment}-${var.avdLocation}-monitoring"
  tags     = local.tags
}
