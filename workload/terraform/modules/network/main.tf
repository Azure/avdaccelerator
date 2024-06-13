resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"
  address_space       = var.vnet_range
  location            = azurerm_resource_group.net.location
  resource_group_name = azurerm_resource_group.net.name
  tags                = local.tags
  lifecycle { ignore_changes = [tags] }

  depends_on = [azurerm_resource_group.net]
}

resource "azurerm_subnet" "subnet" {
  name                                      = "${var.snet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"
  resource_group_name                       = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}"
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  address_prefixes                          = var.subnet_range
  depends_on                                = [azurerm_resource_group.net]
}

resource "azurerm_subnet" "pesubnet" {
  name                                      = "${var.pesnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"
  resource_group_name                       = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}"
  virtual_network_name                      = azurerm_virtual_network.vnet.name
  address_prefixes                          = var.pesubnet_range
  private_endpoint_network_policies = "Enabled"
  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
  depends_on                                = [azurerm_resource_group.net]
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.res-0.id
  depends_on = [
    azurerm_subnet.subnet
  ]
}

resource "azurerm_virtual_network_peering" "peer1" {
  name                         = "peer_${var.prefix}_avdspoke_hub"
  resource_group_name          = azurerm_resource_group.net.name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.remote.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  provider                     = azurerm.spoke

  depends_on = [
    azurerm_virtual_network.vnet, azurerm_resource_group.net, azurerm_subnet.subnet
  ]

}

resource "azurerm_virtual_network_peering" "peer4" {
  name                         = "peer_${var.prefix}_avdspoke_identity"
  resource_group_name          = azurerm_resource_group.net.name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = data.azurerm_virtual_network.identity.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  provider                     = azurerm.spoke

  depends_on = [
    azurerm_virtual_network_peering.peer1
  ]
}
resource "azurerm_virtual_network_peering" "peer2" {
  name                         = "peer_${var.prefix}_hub_avdspoke"
  resource_group_name          = var.hub_connectivity_rg
  virtual_network_name         = var.hub_vnet
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  provider                     = azurerm.hub

  depends_on = [
    azurerm_virtual_network_peering.peer1
  ]
}

resource "azurerm_virtual_network_peering" "peer3" {
  name                         = "peer_${var.prefix}_identity_avdspoke"
  resource_group_name          = var.identity_rg
  virtual_network_name         = var.identity_vnet
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  provider                     = azurerm.identity

  depends_on = [
    azurerm_virtual_network_peering.peer2
  ]
}

# optional - Creates the Azure Virtual Desktop Firewall Rules assuming you have a firewall in the hub
/*
module "firewall" {
  source              = "./firewallrules"
  avdLocation         = var.avdLocation
  prefix              = var.prefix
  fw_policy           = var.fw_policy
  hub_subscription_id = var.hub_subscription_id
  hub_connectivity_rg = var.hub_connectivity_rg
  hub_vnet            = var.hub_vnet
}
*/
