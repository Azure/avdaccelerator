data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "remote" {
  provider            = azurerm.hub
  name                = var.ad_vnet
  resource_group_name = var.ad_rg
}

data "azurerm_virtual_network" "vnet" {
  provider            = azurerm.spoke
  name                = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.net.name
}