resource "azurerm_route_table" "udr" {
  name                          = "rt-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001" #route-avd-{AzureRegionAcronym}-{deploymentPrefix}-{nnn}
  location                      = azurerm_resource_group.net.location
  resource_group_name           = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}"
  disable_bgp_route_propagation = false
  tags = local.tags
  # Optional uncomment to set a route
  /*
  route {
    name                   = "defaultroute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.next_hop_ip
  }

  tags = local.tags
*/
}
resource "azurerm_subnet_route_table_association" "udrasso" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.udr.id
}
