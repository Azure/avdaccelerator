
data "azurerm_resource_group" "udrnet" {
  name = var.rg_network

  depends_on = [azurerm_resource_group.net]
}

resource "azurerm_route_table" "udr" {
  name                          = var.rt
  location                      = var.avdLocation
  resource_group_name           = data.azurerm_resource_group.udrnet.name
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  tags = {
    environment = "AVD Accelerator TF"
  }
}

resource "azurerm_subnet_route_table_association" "udrasso" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.udr.id
}
