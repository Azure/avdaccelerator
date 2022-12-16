resource "azurerm_resource_group" "net" {
  name     = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}"
  location = var.avdLocation
}