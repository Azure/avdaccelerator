data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "remote" {
  provider = azurerm.hub
  name                = var.hub_vnet
  resource_group_name = var.hub_connectivity_rg
}

# generate a random string (consisting of four characters)
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

# Get network vnet data
data "azurerm_virtual_network" "vnet" {
  provider = azurerm.spoke

  name                = "${var.vnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"          //var.vnet
  resource_group_name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}" //var.rg_network

  depends_on = [
    module.network
  ]
}

# Get network subnet data
data "azurerm_subnet" "subnet" {
  provider = azurerm.spoke

  name                 = "${var.snet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"          //var.snet
  resource_group_name  = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}" //var.rg_network
  virtual_network_name = "${var.vnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"          //var.vnet

  depends_on = [
    module.network
  ]
}

# Get network PE subnet data
data "azurerm_subnet" "pesubnet" {
  provider = azurerm.spoke

  name                 = "${var.pesnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"        //var.snet
  resource_group_name  = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}" //var.rg_network
  virtual_network_name = "${var.vnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"          //var.vnet

  depends_on = [
    module.network
  ]
}

# Get Private DNS Zone for the Key Vault Private Endpoints
data "azurerm_private_dns_zone" "pe-vaultdns-zone" {
  provider = azurerm.hub

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.hub_dns_zone_rg
}
