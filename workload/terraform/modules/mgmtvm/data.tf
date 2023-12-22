data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg_storage" {
  name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_stor}"
}

data "azurerm_resource_group" "rg" {
  name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_so}"
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.rg_network
}

#Get network subnet data
data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.rg_network
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

# generate a random string (consisting of four characters)
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}
