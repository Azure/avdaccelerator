provider "azurerm" {
  features {}
  alias           = "hub"
  subscription_id = var.hub_subscription_id
}

provider "azurerm" {
  features {}
  alias           = "spoke"
  subscription_id = var.spoke_subscription_id
}
data "azurerm_virtual_network" "vnet" {
  provider            = azurerm.spoke
  name                = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.net.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  address_space       = var.vnet_range
  dns_servers         = var.dns_servers
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name
  tags                = local.tags
  lifecycle { ignore_changes = [tags] }

  depends_on = [azurerm_resource_group.net]
}

resource "azurerm_subnet" "subnet" {
  name                                      = var.snet
  resource_group_name                       = azurerm_resource_group.net.name
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  address_prefixes                          = var.subnet_range
  private_endpoint_network_policies_enabled = true
  depends_on                                = [azurerm_resource_group.net]
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.res-0.id
}
