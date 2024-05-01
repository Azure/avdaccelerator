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

# Create AVD Workspace
module "avm-res-desktopvirtualization-workspace" {
  source              = "Azure/avm-res-desktopvirtualization-workspace/azurerm"
  version             = "0.1.0"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  workspace           = "${var.workspace}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  diagnostic_settings = {
    to_law = {
      name                  = "to-law"
      workspace_resource_id = data.azurerm_log_analytics_workspace.this.id
    }
  }
  depends_on = [azurerm_resource_group.rg, module.avm-res-desktopvirtualization-hostpool]
}

# Create AVD host pool
module "avm-res-desktopvirtualization-hostpool" {
  source              = "Azure/avm-res-desktopvirtualization-hostpool/azurerm"
  version             = "0.1.2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  hostpool            = "${var.hostpool}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  hostpooltype        = "Pooled"
  diagnostic_settings = {
    to_law = {
      name                  = "to-law"
      workspace_resource_id = data.azurerm_log_analytics_workspace.this.id
    }
  }

  depends_on = [azurerm_resource_group.rg]
}

# Create AVD Desktop Application Group
module "avm-res-desktopvirtualization-applicationgroup" {
  source              = "Azure/avm-res-desktopvirtualization-applicationgroup/azurerm"
  version             = "0.1.0"
  resource_group_name = azurerm_resource_group.rg.name
  hostpool            = module.avm-res-desktopvirtualization-hostpool.azure_virtual_desktop_host_pool_id
  name                = "${var.dag}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  description         = "AVD application group"
  user_group_name     = var.aad_group_name
  type                = "Desktop"
  diagnostic_settings = {
    to_law = {
      name                  = "to-law"
      workspace_resource_id = data.azurerm_log_analytics_workspace.this.id
    }
  }
  depends_on = [azurerm_resource_group.rg, module.avm-res-desktopvirtualization-hostpool, module.avm-res-desktopvirtualization-workspace]
}

# Create Scaling Plan
module "avm-res-desktopvirtualization-scalingplan" {
  source              = "Azure/avm-res-desktopvirtualization-scalingplan/azurerm"
  version             = "0.1.0"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  scalingplan         = "${var.scplan}-${substr(var.avdLocation, 0, 5)}-${var.prefix}"
  hostpool            = module.avm-res-desktopvirtualization-hostpool.azure_virtual_desktop_host_pool_id
}
