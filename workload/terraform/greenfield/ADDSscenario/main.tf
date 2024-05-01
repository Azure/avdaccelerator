# Creates Azure Virtual Desktop Insights Log Analytics Workspace
module "avdi" {
  source      = "../../modules/insights-legacy"
  avdLocation = var.avdLocation
  prefix      = var.prefix
  rg_avdi     = var.rg_avdi
}

# Creates the Azure Virtual Desktop Spoke Network resources
module "network" {
  source                   = "../../modules/network"
  avdLocation              = var.avdLocation
  rg_network               = var.rg_network
  vnet                     = var.vnet
  snet                     = var.snet
  pesnet                   = var.pesnet
  vnet_range               = var.vnet_range
  nsg                      = "${var.nsg}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  prefix                   = var.prefix
  rt                       = "${var.rt}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  hub_connectivity_rg      = var.hub_connectivity_rg
  hub_vnet                 = var.hub_vnet
  subnet_range             = var.subnet_range
  pesubnet_range           = var.pesubnet_range
  next_hop_ip              = var.next_hop_ip
  fw_policy                = var.fw_policy
  hub_subscription_id      = var.hub_subscription_id
  spoke_subscription_id    = var.spoke_subscription_id
  identity_subscription_id = var.identity_subscription_id
  identity_rg              = var.identity_rg
  identity_vnet            = var.identity_vnet
}



# Optional - creates AVD hostpool, remote application group, and workspace for remote apps
# Uncomment out if needed - this is a separate module from the desktop one above
# Remove /* at beginning and */ at the end to uncomment out the entire module
/*
module "poolremoteapp" {
  source         = "../../modules/poolremoteapp"
  ragworkspace   = "${var.ragworkspace}-${substr(var.avdLocation,0,5)}-${var.prefix}-remote"  //var.ragworkspace
  raghostpool    = "${var.raghostpool}-${substr(var.avdLocation,0,5)}-${var.prefix}-poolremoteapp" //var.raghostpool
  rag            = "${var.rag}-${substr(var.avdLocation,0,5)}-${var.prefix}" //var.rag
  rg_so          = var.rg_so
  avdLocation    = var.avdLocation
  rg_shared_name = var.rg_shared_name
  prefix         = var.prefix
  rfc3339        = var.rfc3339
  depends_on     = [module.avdi.avdLocation]
}
*/

# Optional - creates AVD personal hostpool, desktop application group, and workspace for personal desktops
# Uncomment out if needed - this is a separate module from the desktop one above
# Remove /* at beginning and */ at the end to uncomment out the entire module
/*
module "personal" {
  source         = "../../modules/personal"
  personalpool   = "${var.personalpool}-${substr(var.avdLocation,0,5)}-${var.prefix}-personal" //var.personalpool
  pworkspace     = "${var.pworkspace}-${substr(var.avdLocation,0,5)}-${var.prefix}-personal" //var.pworkspace
  rg_so          = var.rg_so
  avdLocation    = var.avdLocation
  rg_shared_name = var.rg_shared_name
  prefix         = var.prefix
  rfc3339        = var.rfc3339
  pag            = "${var.pag}-${substr(var.avdLocation,0,5)}-${var.prefix}" //var.pag
  depends_on     = [module.avdi.avdLocation]
}
*/
