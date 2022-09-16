# Create a Resource Group for Storage
resource "azurerm_resource_group" "rg_storage" {
  location = var.avdLocation
  name     = "rg-avd-${substr(var.avdLocation,0,5)}-${var.prefix}-${var.rg_stor}" //var.rg_stor
}

# Create a Resource Group for AVD Host Pool, Application Group, Workspace (Service Object)
resource "azurerm_resource_group" "rg" {
  name     = "rg-avd-${substr(var.avdLocation,0,5)}-${var.prefix}-${var.rg_so}" //var.rg_so
  location = var.avdLocation
}

# Create a Resource Group for Pool Session Hosts
resource "azurerm_resource_group" "shrg" {
  name     = "rg-avd-${substr(var.avdLocation,0,5)}-${var.prefix}-${var.rg_pool}" //var.rg_pool
  location = var.avdLocation
}

/*
# Create a Resource Group for Personal Session Hosts
resource "azurerm_resource_group" "shp" {
  name     = var.rg_personal
  location = var.avdLocation
}

# Create a Resource Group for RemoteApp Session Hosts
resource "azurerm_resource_group" "shpr" {
  name     = var.rg_remoteapp  
  location = var.avdLocation
}
*/