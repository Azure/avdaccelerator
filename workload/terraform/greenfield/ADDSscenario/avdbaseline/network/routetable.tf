resource "azurerm_route_table" "udr" {
  name                          = var.rt
  location                      = azurerm_resource_group.net.location
  resource_group_name           = azurerm_resource_group.net.name
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  tags = local.tags
}


resource "azurerm_subnet_route_table_association" "udrasso" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.udr.id
}
