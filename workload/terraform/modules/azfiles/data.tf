data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azuread_group" "adds_group" {
  display_name     = var.aad_group_name
  security_enabled = true
}

# Get network vnet data
data "azurerm_virtual_network" "spokevnet" {
  name                = module.network.vnet_name
  resource_group_name = module.network.rg_name
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