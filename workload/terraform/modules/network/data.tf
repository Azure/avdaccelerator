data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "remote" {
  provider            = azurerm.hub
  name                = var.hub_vnet
  resource_group_name = var.hub_connectivity_rg
}

data "azurerm_virtual_network" "identity" {
  provider            = azurerm.hub
  name                = var.identity_vnet
  resource_group_name = var.identity_rg
}