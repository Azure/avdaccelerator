data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# Get the resource group
data "azurerm_resource_group" "rg" {
  name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_so}"
}

# Get network vnet data
data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  resource_group_name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}"
}

# Get network privated endpoint subnet data
data "azurerm_subnet" "subnet" {
  name                 = "${var.pesnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  resource_group_name  = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}"
  virtual_network_name = "${var.vnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
}