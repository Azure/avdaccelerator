# Create a Resource Group for Storage
resource "azurerm_resource_group" "rg_storage" {
  location = var.avdLocation
  name     = var.rg_stor
}

# Create a Resource Group for AVD Host Pool, Application Group, Workspace (Service Object)
resource "azurerm_resource_group" "rg" {
  name     = var.rg_so
  location = var.avdLocation
}

# Create a Resource Group for Pool Session Hosts
resource "azurerm_resource_group" "shrg" {
  name     = var.rg_pool
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