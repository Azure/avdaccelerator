# Creates Azure Virtual Desktop Insights Log Analytics Workspace
module "avdi" {
  source      = "../../modules/insights"
  avdLocation = var.avdLocation
  prefix      = var.prefix
  rg_avdi     = var.rg_avdi
}

# Creates the Azure Virtual Desktop Spoke Network resources
module "network" {
  source = "../../modules/network"
  avdLocation           = var.avdLocation
  rg_network            = var.rg_network
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
