data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# generate a random string (consisting of four characters)
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

# Get network subnet data
data "azurerm_subnet" "subnet" {
  name                 = var.snet
  resource_group_name  = var.rg_network
  virtual_network_name = var.vnet
}