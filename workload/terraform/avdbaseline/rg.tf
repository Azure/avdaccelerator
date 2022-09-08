## Create a Resource Group for Storage
resource "azurerm_resource_group" "rg_storage" {
  location = var.avdLocation
  name     = var.rg_stor
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_so
  location = var.avdLocation
}

resource "azurerm_resource_group" "shrg" {
  name     = var.rg_pool
  location = var.avdLocation
}
