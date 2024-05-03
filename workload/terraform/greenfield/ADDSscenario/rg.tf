# Create a Resource Group for AVD Host Pool, Application Group, Workspace (Service Object)
resource "azurerm_resource_group" "this" {
  name     = "rg-avd-${var.prefix}-${var.environment}-${var.avdLocation}-${var.rg_so}"
  location = var.avdLocation
}

# Create a Resource Group for Storage 
resource "azurerm_resource_group" "rg" {
  location = var.avdLocation
  name     = "rg-avd-${var.prefix}-${var.environment}-${var.avdLocation}-${var.rg_stor}"
  tags     = local.tags
}

# Create a Resource Group for Pool Session Hosts
resource "azurerm_resource_group" "shrg" {
  name     = "rg-avd-${var.prefix}-${var.environment}-${var.avdLocation}-${var.rg_pool}"
  location = var.avdLocation
  tags     = local.tags
}

# Create a Resource Group for AVD insights
resource "azurerm_resource_group" "mon" {
  name     = "rg-avd-${var.environment}-${var.avdLocation}-monitoring"
  location = var.avdLocation
  tags     = local.tags
}
