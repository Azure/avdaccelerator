# Create a Resource Group for Personal Session Hosts
resource "azurerm_resource_group" "rg" {
  name     = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_personal}"
  location = var.avdLocation
}

resource "random_uuid" "example" {}

# Create AVD workspace vdws-{AzureRegionAcronym}-{deploymentPrefix}-{nnn} pworkspace
resource "azurerm_virtual_desktop_workspace" "pworkspace" {
  name                = "${var.pworkspace}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  friendly_name       = "${var.prefix} Personal Workspace"
  description         = "${var.prefix} Personal Workspace"
}

# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "personalpool" {
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  name                     = "${var.personalpool}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"
  friendly_name            = "${var.personalpool}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"
  validate_environment     = true
  custom_rdp_properties    = "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:0"
  description              = "${var.prefix} Personal HostPool"
  type                     = "Personal"
  maximum_sessions_allowed = 1
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
  principal_id                     = data.azuread_service_principal.spn.application_id
  skip_service_principal_aad_check = true
  depends_on                       = [data.azurerm_role_definition.power_role]
}


resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id = azurerm_virtual_desktop_host_pool.personalpool.id
  # Generating RFC3339Time for the expiration of the token. 
  expiration_date = timeadd(timestamp(), "48h")
}

# Create AVD pag
resource "azurerm_virtual_desktop_application_group" "pag" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.personalpool.id
  type                = "Desktop"
  name                = "${var.pag}-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001" //var.pag
  friendly_name       = "Desktop AppGroup"
  description         = "AVD Desktop application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.personalpool, azurerm_virtual_desktop_workspace.pworkspace]
}

# Associate Workspace and pag
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.pag.id
  workspace_id         = azurerm_virtual_desktop_workspace.pworkspace.id
}

# Get Log Analytics Workspace data
data "azurerm_log_analytics_workspace" "lawksp" {
  name                = lower(replace("law-avd-${var.prefix}", "-", ""))
  resource_group_name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_avdi}"

  depends_on = [
    azurerm_virtual_desktop_workspace.pworkspace,
    azurerm_virtual_desktop_host_pool.personalpool,
    azurerm_virtual_desktop_application_group.pag,
    azurerm_virtual_desktop_workspace_application_group_association.ws-dag,
  ]
}

# Create Diagnostic Settings for AVD Host Pool
resource "azurerm_monitor_diagnostic_setting" "avd-hp1" {
  name                       = "AVD-Diag"
  target_resource_id         = azurerm_virtual_desktop_host_pool.personalpool.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp,
    azurerm_virtual_desktop_host_pool.personalpool
  ]

  enabled_log {
    category = "Checkpoint"

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  enabled_log {
    category = "Error"

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  enabled_log {
    category = "Management"

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  enabled_log {
    category = "Connection"

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  enabled_log {
    category = "HostRegistration"

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  enabled_log {
    category = "AgentHealthStatus"

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  enabled_log {
    category = "NetworkData"

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  enabled_log {
    category = "SessionHostManagement"

    retention_policy {
      days    = 7
      enabled = true
    }
  }
}

# Create Diagnostic Settings for AVD Desktop App Group
resource "azurerm_monitor_diagnostic_setting" "avd-pag1" {
  name                       = "AVD-Diag"
  target_resource_id         = azurerm_virtual_desktop_application_group.pag.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp
  ]

  enabled_log {
    category = "Checkpoint"

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  enabled_log {
    category = "Error"

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  enabled_log {
    category = "Management"

    retention_policy {
      days    = 7
      enabled = true
    }
  }
}

# Create Diagnostic Settings for AVD Workspace
resource "azurerm_monitor_diagnostic_setting" "avd-wksp1" {
  name                       = "AVD-Diag"
  target_resource_id         = azurerm_virtual_desktop_workspace.pworkspace.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp
  ]

  enabled_log {
    category = "Checkpoint"

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  enabled_log {
    category = "Error"

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  enabled_log {
    category = "Management"

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  enabled_log {
    category = "Feed"

    retention_policy {
      days    = 7
      enabled = true
    }
  }
}
