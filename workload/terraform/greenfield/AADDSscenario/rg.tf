# Create a Resource Group for Storage
resource "azurerm_resource_group" "rg_storage" {
  location = var.avdLocation
  name     = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_stor}"
  tags     = local.tags
}

# Create a Resource Group for AVD Host Pool, Application Group, Workspace (Service Object)
resource "azurerm_resource_group" "rg" {
  name     = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_so}"
  location = var.avdLocation

}

# Create a Resource Group for Pool Session Hosts
resource "azurerm_resource_group" "shrg" {
  name     = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_pool}"
  location = var.avdLocation
  tags     = local.tags
}
