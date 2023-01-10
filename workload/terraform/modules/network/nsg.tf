resource "azurerm_network_security_group" "res-0" {
  location            = azurerm_resource_group.net.location
  name                = var.nsg
  resource_group_name = azurerm_resource_group.net.name
  tags                = local.tags

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "AzureCloud"
    destination_port_range     = "8443"
    direction                  = "Outbound"
    name                       = "AzureCloud"
    priority                   = 110
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "AzureFrontDoor.Frontend"
    destination_port_range     = "443"
    direction                  = "Outbound"
    name                       = "AzureMarketplace"
    priority                   = 130
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

/*
  security_rule {
    access                     = "Deny"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "DenyALL"
    priority                   = 4096
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
*/
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "Internet"
    destination_port_range     = "1688"
    direction                  = "Outbound"
    name                       = "WindowsActivation"
    priority                   = 140
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }


  security_rule {
    access                     = "Allow"
    destination_address_prefix = "169.254.169.254"
    destination_port_range     = "80"
    direction                  = "Outbound"
    name                       = "AzureInstanceMetadata"
    priority                   = 150
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "AzureMonitor"
    destination_port_range     = "443"
    direction                  = "Outbound"
    name                       = "AzureMonitor"
    priority                   = 120
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "WindowsVirtualDesktop"
    destination_port_range     = "443"
    direction                  = "Outbound"
    name                       = "AVDServiceTraffic"
    priority                   = 100
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}