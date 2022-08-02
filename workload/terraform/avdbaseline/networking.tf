resource "azurerm_resource_group" "net" {
  name     = var.rg_network
  location = var.avdLocation
}

resource "azurerm_virtual_network" "vnet" {
  name                = "avd-${var.prefix}-VNet"
  address_space       = var.vnet_range
  dns_servers         = var.dns_servers
  location            = var.avdLocation
  resource_group_name = var.rg_network
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "subnet" {
  name                                           = "avd-subnet"
  resource_group_name                            = var.rg_network
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = var.subnet_range
  enforce_private_link_endpoint_network_policies = false
  depends_on                                     = [azurerm_resource_group.rg]
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
  name                      = "peer_${var.prefix}_avdspoke_ad"
  resource_group_name       = var.rg_network
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.ad_vnet_data.id
}
resource "azurerm_virtual_network_peering" "peer2" {
  name                      = "peer_${var.prefix}_ad_avdspoke"
  resource_group_name       = var.ad_rg
  virtual_network_name      = var.ad_vnet
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

# Creating a Private DNS Zone for the Storage Private Endpoints
resource "azurerm_private_dns_zone" "pe-dns-zone" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.share.name

}

# Creating a Private DNS Zone for the Key Vault Endpoints
resource "azurerm_private_dns_zone" "key-dns-zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.share.name
}

# Linking DNS Zone to the VNET
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_network_link" {
  name                  = "pdnsvnet_link"
  resource_group_name   = var.rg_shared_name
  private_dns_zone_name = azurerm_private_dns_zone.pe-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Linking DNS Zone to the VNET
resource "azurerm_private_dns_zone_virtual_network_link" "netlink" {
  name                  = "keydnsvnet_link"
  resource_group_name   = var.rg_shared_name
  private_dns_zone_name = azurerm_private_dns_zone.key-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
