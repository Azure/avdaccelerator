# Creates the Azure Virtual Desktop Spoke Network resources
module "network" {
  source                   = "../../modules/network"
  avdLocation              = var.avdLocation
  rg_network               = var.rg_network
  vnet                     = var.vnet
  snet                     = var.snet
  pesnet                   = var.pesnet
  vnet_range               = var.vnet_range
  nsg                      = "${var.nsg}-${var.prefix}-${var.environment}-${var.avdLocation}"
  prefix                   = var.prefix
  rt                       = "${var.rt}-${var.prefix}-${var.environment}-${var.avdLocation}"
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

# Create Azure Log Analytics workspace for Azure Virtual Desktop
module "avm_res_operationalinsights_workspace" {
  source              = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version             = "0.1.3"
  enable_telemetry    = var.enable_telemetry
  resource_group_name = azurerm_resource_group.mon.name
  location            = var.avdLocation
  name                = lower(replace("log-avd-${var.environment}-${var.avdLocation}", "-", ""))
  tags                = local.tags
}

module "avm_res_desktopvirtualization_hostpool" {
  source  = "Azure/avm-res-desktopvirtualization-hostpool/azurerm"
  version = "0.1.4"

  virtual_desktop_host_pool_location                 = azurerm_resource_group.this.location
  virtual_desktop_host_pool_name                     = "${var.hostpool}-${var.prefix}-${var.environment}-${var.avdLocation}"
  virtual_desktop_host_pool_type                     = "Pooled" // "Personal" or "Pooled"
  virtual_desktop_host_pool_resource_group_name      = azurerm_resource_group.this.name
  virtual_desktop_host_pool_load_balancer_type       = "BreadthFirst" // "DepthFirst" or "BreadthFirst"
  virtual_desktop_host_pool_custom_rdp_properties    = "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:0"
  virtual_desktop_host_pool_maximum_sessions_allowed = 16
  virtual_desktop_host_pool_start_vm_on_connect      = true
  resource_group_name                                = azurerm_resource_group.this.name
  virtual_desktop_host_pool_scheduled_agent_updates = {
    enabled = "true"
    schedule = tolist([{
      day_of_week = "Sunday"
      hour_of_day = 0
    }])
  }
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  expiration_date = timeadd(timestamp(), "48h")
  hostpool_id     = module.avm_res_desktopvirtualization_hostpool.resource.id
}

# Get an existing built-in role definition
data "azurerm_role_definition" "this" {
  name = "Desktop Virtualization User"
}

# Get an existing Azure AD group that will be assigned to the application group
data "azuread_group" "existing" {
  display_name     = var.user_group_name
  security_enabled = true
}

# Assign the Azure AD group to the application group
resource "azurerm_role_assignment" "this" {
  principal_id                     = data.azuread_group.existing.object_id
  scope                            = module.avm_res_desktopvirtualization_applicationgroup.resource.id
  role_definition_id               = data.azurerm_role_definition.this.id
  skip_service_principal_aad_check = false
}

# Create Azure Virtual Desktop application group
module "avm_res_desktopvirtualization_applicationgroup" {
  source                                                = "Azure/avm-res-desktopvirtualization-applicationgroup/azurerm"
  enable_telemetry                                      = var.enable_telemetry
  version                                               = "0.1.2"
  virtual_desktop_application_group_name                = "${var.dag}-${var.prefix}-${var.environment}-${var.avdLocation}-01"
  virtual_desktop_application_group_type                = "Desktop"
  virtual_desktop_application_group_host_pool_id        = module.avm_res_desktopvirtualization_hostpool.resource.id
  virtual_desktop_application_group_resource_group_name = azurerm_resource_group.this.name
  virtual_desktop_application_group_location            = azurerm_resource_group.this.location
  user_group_name                                       = var.user_group_name
  virtual_desktop_application_group_tags                = local.tags
}

# Create Azure Virtual Desktop workspace
module "avm_res_desktopvirtualization_workspace" {
  source              = "Azure/avm-res-desktopvirtualization-workspace/azurerm"
  version             = "0.1.2"
  enable_telemetry    = var.enable_telemetry
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  description         = "${var.prefix} Workspace"
  name                = "${var.workspace}-${var.prefix}-${var.environment}-${var.avdLocation}-01"
  tags                = local.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workappgrassoc" {
  application_group_id = module.avm_res_desktopvirtualization_applicationgroup.resource.id
  workspace_id         = module.avm_res_desktopvirtualization_workspace.resource.id
}

# Get the service principal for Azure Vitual Desktop
data "azuread_service_principal" "spn" {
  client_id = "9cdead84-a844-4324-93f2-b2e6bb768d07"
}

resource "random_uuid" "example" {}

data "azurerm_role_definition" "power_role" {
  name = "Desktop Virtualization Power On Off Contributor"
}

resource "azurerm_role_assignment" "new" {
  principal_id       = data.azuread_service_principal.spn.object_id
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = data.azurerm_role_definition.power_role.id

  lifecycle {
    ignore_changes = [role_definition_id]
  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# This is the storage account for the diagnostic settings
resource "azurerm_storage_account" "this" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.this.name
}

# Create Azure Virtual Desktop scaling plan
module "avm_res_desktopvirtualization_scaling_plan" {
  source                                           = "Azure/avm-res-desktopvirtualization-scalingplan/azurerm"
  enable_telemetry                                 = var.enable_telemetry
  version                                          = "0.1.2"
  virtual_desktop_scaling_plan_name                = "${var.scplan}-${var.prefix}-${var.environment}-${var.avdLocation}-01"
  virtual_desktop_scaling_plan_location            = azurerm_resource_group.this.location
  virtual_desktop_scaling_plan_resource_group_name = azurerm_resource_group.this.name
  virtual_desktop_scaling_plan_time_zone           = "Eastern Standard Time"
  virtual_desktop_scaling_plan_description         = "${var.prefix} Scaling Plan"
  virtual_desktop_scaling_plan_tags                = local.tags
  virtual_desktop_scaling_plan_host_pool = toset(
    [
      {
        hostpool_id          = module.avm_res_desktopvirtualization_hostpool.resource.id
        scaling_plan_enabled = true
      }
    ]
  )
  virtual_desktop_scaling_plan_schedule = toset(
    [
      {
        name                                 = "Weekday"
        days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        ramp_up_start_time                   = "09:00"
        ramp_up_load_balancing_algorithm     = "BreadthFirst"
        ramp_up_minimum_hosts_percent        = 50
        ramp_up_capacity_threshold_percent   = 80
        peak_start_time                      = "10:00"
        peak_load_balancing_algorithm        = "DepthFirst"
        ramp_down_start_time                 = "17:00"
        ramp_down_load_balancing_algorithm   = "BreadthFirst"
        ramp_down_minimum_hosts_percent      = 50
        ramp_down_force_logoff_users         = true
        ramp_down_wait_time_minutes          = 15
        ramp_down_notification_message       = "The session will end in 15 minutes."
        ramp_down_capacity_threshold_percent = 50
        ramp_down_stop_hosts_when            = "ZeroActiveSessions"
        off_peak_start_time                  = "18:00"
        off_peak_load_balancing_algorithm    = "BreadthFirst"
      },
      {
        name                                 = "Weekend"
        days_of_week                         = ["Saturday", "Sunday"]
        ramp_up_start_time                   = "09:00"
        ramp_up_load_balancing_algorithm     = "BreadthFirst"
        ramp_up_minimum_hosts_percent        = 50
        ramp_up_capacity_threshold_percent   = 80
        peak_start_time                      = "10:00"
        peak_load_balancing_algorithm        = "DepthFirst"
        ramp_down_start_time                 = "17:00"
        ramp_down_load_balancing_algorithm   = "BreadthFirst"
        ramp_down_minimum_hosts_percent      = 50
        ramp_down_force_logoff_users         = true
        ramp_down_wait_time_minutes          = 15
        ramp_down_notification_message       = "The session will end in 15 minutes."
        ramp_down_capacity_threshold_percent = 50
        ramp_down_stop_hosts_when            = "ZeroActiveSessions"
        off_peak_start_time                  = "18:00"
        off_peak_load_balancing_algorithm    = "BreadthFirst"
      }
    ]
  )
}
