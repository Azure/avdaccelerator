resource "azurerm_resource_group" "res-17" {
  location = var.avdLocation
  name     = azurerm_virtual_network.vnet.name
  tags = {
    Environment = "AVD Accelerator"
  }
}

resource "azurerm_network_security_group" "res-0" {
  location            = var.avdLocation
  name                = "nsg-${var.avdLocation}-avd-${var.prefix}"
  resource_group_name = var.rg_network
  depends_on = [
    azurerm_resource_group.res-17,
  ]
}

resource "azurerm_network_security_rule" "res-1" {
  access                      = "Allow"
  destination_address_prefix  = "AzureCloud"
  destination_port_range      = "8443"
  direction                   = "Outbound"
  name                        = "AzureCloud"
  network_security_group_name = azurerm_network_security_group.res-0.name
  priority                    = 110
  protocol                    = "Tcp"
  resource_group_name         = var.rg_network
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-0,
  ]
}
resource "azurerm_network_security_rule" "res-2" {
  access                      = "Allow"
  destination_address_prefix  = "AzureFrontDoor.Frontend"
  destination_port_range      = "443"
  direction                   = "Outbound"
  name                        = "AzureMarketplace"
  network_security_group_name = azurerm_network_security_group.res-0.name
  priority                    = 130
  protocol                    = "Tcp"
  resource_group_name         = azurerm_network_security_group.res-0.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-0,
  ]
}
resource "azurerm_network_security_rule" "res-4" {
  access                      = "Deny"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "DenyALL"
  network_security_group_name = azurerm_network_security_group.res-0.name
  priority                    = 4096
  protocol                    = "*"
  resource_group_name         = azurerm_network_security_group.res-0.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-0,
  ]
}

resource "azurerm_network_security_rule" "res-6" {
  access                      = "Allow"
  destination_address_prefix  = "Internet"
  destination_port_range      = "1688"
  direction                   = "Outbound"
  name                        = "WindowsActivation"
  network_security_group_name = azurerm_network_security_group.res-0.name
  priority                    = 140
  protocol                    = "Tcp"
  resource_group_name         = azurerm_network_security_group.res-0.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-0,
  ]
}
resource "azurerm_network_security_rule" "res-7" {
  access                      = "Allow"
  destination_address_prefix  = "169.254.169.254"
  destination_port_range      = "80"
  direction                   = "Outbound"
  name                        = "AzureInstanceMetadata"
  network_security_group_name = azurerm_network_security_group.res-0.name
  priority                    = 150
  protocol                    = "Tcp"
  resource_group_name         = azurerm_network_security_group.res-0.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-0,
  ]
}

resource "azurerm_network_security_rule" "res-10" {
  access                      = "Allow"
  destination_address_prefix  = "AzureMonitor"
  destination_port_range      = "443"
  direction                   = "Outbound"
  name                        = "AzureMonitor"
  network_security_group_name = azurerm_network_security_group.res-0.name
  priority                    = 120
  protocol                    = "Tcp"
  resource_group_name         = azurerm_network_security_group.res-0.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-0,
  ]
}
resource "azurerm_network_security_rule" "res-12" {
  access                      = "Allow"
  destination_address_prefix  = "WindowsVirtualDesktop"
  destination_port_range      = "443"
  direction                   = "Outbound"
  name                        = "AVDServiceTraffic"
  network_security_group_name = azurerm_network_security_group.res-0.name
  priority                    = 100
  protocol                    = "*"
  resource_group_name         = azurerm_network_security_group.res-0.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-0,
  ]
}
