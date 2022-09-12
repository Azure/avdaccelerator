# Creates Azure Virtual Desktop Insights Log Analytics Workspace
module "avdi" {
  source      = "./insights"
  avdLocation = var.avdLocation
  prefix      = var.prefix
  rg_so       = var.rg_so

}

# Creates the Azure Virtual Desktop Spoke Network resources
module "network" {
  source       = "./network"
  avdLocation  = var.avdLocation
  rg_network   = var.rg_network
  vnet         = var.vnet
  snet         = var.snet
  dns_servers  = var.dns_servers
  vnet_range   = var.vnet_range
  nsg          = var.nsg
  prefix       = var.prefix
  rt           = var.rt
  ad_rg        = var.ad_rg
  ad_vnet      = var.ad_vnet
  subnet_range = var.subnet_range
}

# Optional - creates AVD hostpool, remote application group, and workspace for remote apps
# Uncomment out if needed - this is a separate module from the desktop one above
# Remove /* at beginning and */ at the end to uncomment out the entire module
/*
module "poolremoteapp" {
  source         = "./poolremoteapp"
  ragworkspace   = var.ragworkspace
  raghostpool    = var.raghostpool
  rag            = var.rag
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
  source         = "./personal"
  personalpool   = var.personalpool
  pworkspace     = var.pworkspace
  rg_so          = var.rg_so
  avdLocation    = var.avdLocation
  rg_shared_name = var.rg_shared_name
  prefix         = var.prefix
  rfc3339        = var.rfc3339
  pag            = var.pag
  depends_on     = [module.avdi.avdLocation]
}
*/

