resource "azurerm_resource_group" "net" {
  name     = var.rg_network
  location = var.avdLocation
}