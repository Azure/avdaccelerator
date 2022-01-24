module "storage" {
  source = "./modules/storage"

  location       = var.location
  prefix         = var.prefix
  aad_group_name = var.aad_group_name
}

module "SIG" {
  source = "./modules/SIG"

  signame  = var.signame
  rg_name  = var.rg_name
  location = var.location
  prefix   = var.prefix
}

module "log-analytics" {
  source = "./modules/log-analytics"

  location = var.location
  prefix   = var.prefix
}

module "avd" {
  source = "./modules/avd"

  location             = var.location
  rg_name              = var.rg_name
  signame              = var.signame
  prefix               = var.prefix
  aad_group_name       = var.aad_group_name
  domain_name          = var.domain_name
  domain_user_upn      = var.domain_user_upn
  domain_password      = var.domain_password
  ad_vnet              = var.ad_vnet
  ad_rg                = var.ad_rg
  local_admin_username = var.local_admin_username
  local_admin_password = var.local_admin_password
  vnet_range           = var.vnet_range
  subnet_range         = var.subnet_range
  dns_servers          = var.dns_servers
  host_pool            = var.host_pool
  workspace            = var.workspace
}