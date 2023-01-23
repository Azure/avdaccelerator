resource "azurerm_virtual_network_dns_servers" "customdns" {
  virtual_network_id = data.azurerm_virtual_network.vnet.id
  dns_servers        = var.dns_servers
}