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

data "azurerm_virtual_network" "ad_vnet_data" {
  name                = var.ad_vnet
  resource_group_name = var.ad_rg
}

resource "azurerm_virtual_network_peering" "peer1" {
  name                         = "peer_${var.prefix}_avdspoke_ad"
  resource_group_name          = azurerm_resource_group.net.name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.ad_vnet_data.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peer2" {
  name                         = "peer_${var.prefix}_ad_avdspoke"
  resource_group_name          = var.ad_rg
  virtual_network_name         = var.ad_vnet
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
