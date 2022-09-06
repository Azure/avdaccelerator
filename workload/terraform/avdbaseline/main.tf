# Creates Azure Virtual Desktop Insights Log Analytics Workspace
module "avdi" {
  source      = "./insights"
  avdLocation = var.avdLocation
  prefix      = var.prefix
  rg_so       = var.rg_so
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

