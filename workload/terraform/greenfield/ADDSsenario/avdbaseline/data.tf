data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# generate a random string (consisting of four characters)
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length  = 5
  upper   = false
  special = false
}

# Get network subnet data
data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"              //var.vnet
  resource_group_name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}" //var.rg_network

  depends_on = [
    module.network
  ]
}

# Get network subnet data
data "azurerm_subnet" "subnet" {
  name                 = "${var.snet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"              //var.snet
  resource_group_name  = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}" //var.rg_network
  virtual_network_name = "${var.vnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"              //var.vnet

  depends_on = [
    module.network
  ]
}


# Get Log Analytics Workspace data
data "azurerm_log_analytics_workspace" "lawksp" {
  name                = lower(replace("law-avd-${var.prefix}", "-", ""))
  resource_group_name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_avdi}" //var.rg_avdi

  depends_on = [
    module.avdi
  ]
}

