resource "random_uuid" "example" {}

# Create AVD workspace vdws-{AzureRegionAcronym}-{deploymentPrefix}-{nnn}
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "${var.workspace}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001" //var.workspace
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  friendly_name       = "${var.prefix} Workspace"
  description         = "${var.prefix} Workspace"
}

# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  name                     = "${var.hostpool}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001" //var.hostpool
  friendly_name            = "${var.hostpool}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001" //var.hostpool
  validate_environment     = true
  custom_rdp_properties    = "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:0"
  description              = "${var.prefix} Pooled HostPool"
  type                     = "Pooled"
  maximum_sessions_allowed = 16
  load_balancer_type       = "DepthFirst" #[BreadthFirst DepthFirst]


  depends_on = [
    azurerm_resource_group.rg
  ]
  lifecycle {
    ignore_changes = all
  }
}

#Autoscale is currently only available in the public cloud.
data "azurerm_role_definition" "power_role" {
  name = "Desktop Virtualization Power On Off Contributor"
}

data "azuread_service_principal" "spn" {
  application_id = "9cdead84-a844-4324-93f2-b2e6bb768d07"
}

resource "azurerm_role_assignment" "power" {
  name                             = random_uuid.example.result
  scope                            = azurerm_resource_group.rg.id
  role_definition_id               = data.azurerm_role_definition.power_role.role_definition_id
  principal_id                     = data.azuread_service_principal.spn.object_id
  skip_service_principal_aad_check = true
  depends_on                       = [data.azurerm_role_definition.power_role]
}
# autoscale settings scenario 1 https://docs.microsoft.com/azure/virtual-desktop/autoscale-scenarios
resource "azurerm_virtual_desktop_scaling_plan" "scplan" {
  name                = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}" //var.scplan
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  friendly_name       = "Scaling Plan Example"
  description         = "Demo Scaling Plan"
  time_zone           = "Eastern Standard Time"
  schedule {
    name                                 = "Weekdays"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = "05:00"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 30
    ramp_up_capacity_threshold_percent   = 30
    peak_start_time                      = "09:00"
    peak_load_balancing_algorithm        = "BreadthFirst"
    ramp_down_start_time                 = "19:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 45
    ramp_down_notification_message       = "Please log off in the next 45 minutes..."
    ramp_down_capacity_threshold_percent = 5
    ramp_down_stop_hosts_when            = "ZeroSessions"
    off_peak_start_time                  = "22:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }
  schedule {
    name                                 = "Weekend"
    days_of_week                         = ["Saturday", "Sunday"]
    ramp_up_start_time                   = "09:00"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 30
    ramp_up_capacity_threshold_percent   = 10
    peak_start_time                      = "10:00"
    peak_load_balancing_algorithm        = "BreadthFirst"
    ramp_down_start_time                 = "16:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 45
    ramp_down_notification_message       = "Please log of in the next 45 minutes..."
    ramp_down_capacity_threshold_percent = 5
    ramp_down_stop_hosts_when            = "ZeroSessions"
    off_peak_start_time                  = "20:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }
  tags = local.tags

  depends_on = [azurerm_role_assignment.power, azurerm_virtual_desktop_host_pool.hostpool]

  host_pool {
    hostpool_id          = azurerm_virtual_desktop_host_pool.hostpool.id
    scaling_plan_enabled = true
  }
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id = azurerm_virtual_desktop_host_pool.hostpool.id
  # Generating RFC3339Time for the expiration of the token. 
  expiration_date = timeadd(timestamp(), "48h")
}

# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "dag" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
  type                = "Desktop"
  name                = "${var.dag}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001" //var.dag
  friendly_name       = "Desktop AppGroup"
  description         = "AVD Desktop application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace.workspace]
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
}

# Get Log Analytics Workspace data
data "azurerm_log_analytics_workspace" "lawksp" {
  name                = lower(replace("law-avd-${substr(var.avdLocation, 0, 5)}", "-", ""))
  resource_group_name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_avdi}"

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp,
    azurerm_virtual_desktop_workspace.workspace,
    azurerm_virtual_desktop_host_pool.hostpool,
    azurerm_virtual_desktop_application_group.dag,
    azurerm_virtual_desktop_workspace_application_group_association.ws-dag,
    module.avdi
  ]
}

# Create Diagnostic Settings for AVD Host Pool
resource "azurerm_monitor_diagnostic_setting" "avd-hp1" {
  name                       = "AVD-Diag"
  target_resource_id         = azurerm_virtual_desktop_host_pool.hostpool.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp,
    azurerm_virtual_desktop_host_pool.hostpool
  ]

  dynamic "enabled_log" {
    for_each = var.host_pool_log_categories
    content {
      category = enabled_log.value
    }
  }
  lifecycle {
    ignore_changes = [log]
  }
}

# Create Diagnostic Settings for AVD Desktop App Group
resource "azurerm_monitor_diagnostic_setting" "avd-dag1" {
  name                       = "diag-avd-${var.prefix}"
  target_resource_id         = azurerm_virtual_desktop_application_group.dag.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp
  ]
  dynamic "enabled_log" {
    for_each = var.dag_log_categories
    content {
      category = enabled_log.value
    }
  }
  lifecycle {
    ignore_changes = [log]
  }
}

# Create Diagnostic Settings for AVD Workspace
resource "azurerm_monitor_diagnostic_setting" "avd-wksp1" {
  name                       = "AVD-Diag"
  target_resource_id         = azurerm_virtual_desktop_workspace.workspace.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp
  ]

  dynamic "enabled_log" {
    for_each = var.ws_log_categories
    content {
      category = enabled_log.value
    }
  }
  lifecycle {
    ignore_changes = [log]
  }
}
