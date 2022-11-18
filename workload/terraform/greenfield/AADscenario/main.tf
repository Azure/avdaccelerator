# Creates Azure Virtual Desktop Insights Log Analytics Workspace
module "avdi" {
  source      = "./insights"
  avdLocation = var.avdLocation
  prefix      = var.prefix
  rg_so       = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_so}"
}

# Creates the Azure Virtual Desktop Spoke Network resources
module "network" {
  source                = "./network"
  avdLocation           = var.avdLocation
  rg_network            = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}"
  vnet                  = "${var.vnet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  snet                  = "${var.snet}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  dns_servers           = var.dns_servers
  vnet_range            = var.vnet_range
  nsg                   = "${var.nsg}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  prefix                = var.prefix
  rt                    = "${var.rt}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  subnet_range          = var.subnet_range
  hub_subscription_id   = var.hub_subscription_id
  spoke_subscription_id = var.spoke_subscription_id
}
