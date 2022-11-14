# Create a Resource Group for Monitoring
resource "azurerm_resource_group" "share" {
  name     = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_avdi}"
  location = var.avdLocation
}