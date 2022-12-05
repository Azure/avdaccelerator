# Create a Resource Group for Storage
resource "azurerm_resource_group" "rg_storage" {
  location = var.avdLocation
  name     = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_stor}"
}

# Create a Resource Group for FSLogix temp Hosts
resource "azurerm_resource_group" "rg_fslogix" {
  name     = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_fslogix}"
  location = var.avdLocation
}