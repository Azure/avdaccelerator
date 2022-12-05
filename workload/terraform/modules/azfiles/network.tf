# Creates the Azure Virtual Desktop Spoke Network resources
module "network" {
  source                = "../network"

  avdLocation           = var.avdLocation
  rg_network            = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_network}"
  vnet                  = var.vnet
  snet                  = var.snet
  pesnet                = var.pesnet
  vnet_range            = var.vnet_range
  nsg                   = "${var.nsg}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  prefix                = var.prefix
  rt                    = "${var.rt}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  ad_rg                 = var.ad_rg
  ad_vnet               = var.ad_vnet
  subnet_range          = var.subnet_range
  pesubnet_range        = var.pesubnet_range
  hub_subscription_id   = var.hub_subscription_id
  spoke_subscription_id = var.spoke_subscription_id
}