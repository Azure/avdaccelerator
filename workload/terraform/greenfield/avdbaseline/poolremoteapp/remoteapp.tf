# Resource group name is output when execution plan is applied.
resource "azurerm_resource_group" "sh" {
  name     = var.rg_so
  location = var.avdLocation
}

# Create AVD RAG workspace
resource "azurerm_virtual_desktop_workspace" "ragworkspace" {
  name                = var.ragworkspace
  resource_group_name = azurerm_resource_group.sh.name
  location            = azurerm_resource_group.sh.location
  friendly_name       = "${var.prefix} Workspace"
  description         = "${var.prefix} Workspace"
}

# Create AVD RAG host pool
resource "azurerm_virtual_desktop_host_pool" "raghostpool" {
  resource_group_name      = azurerm_resource_group.sh.name
  location                 = azurerm_resource_group.sh.location
  name                     = "${var.raghostpool}-${substr(var.avdLocation,0,5)}-${var.prefix}-remoteapp-${count.index + 1}"  //var.raghostpool
  friendly_name            = "${var.raghostpool}-${substr(var.avdLocation,0,5)}-${var.prefix}-remoteapp-${count.index + 1}"  //var.raghostpool
  validate_environment     = true
  custom_rdp_properties    = "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:1"
  description              = "${var.prefix} Pooled HostPool"
  type                     = "Pooled"
  maximum_sessions_allowed = 16
  load_balancer_type       = "DepthFirst" #[BreadthFirst DepthFirst]
}

# Create AVD RAAG
resource "azurerm_virtual_desktop_application_group" "raag" {
  resource_group_name = azurerm_resource_group.sh.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.raghostpool.id
  location            = azurerm_resource_group.sh.location
  type                = "RemoteApp"
  name                = var.rag
  friendly_name       = "RemoteAppGroup"
  description         = "AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.raghostpool, azurerm_virtual_desktop_workspace.ragworkspace]
}

# Associate Workspace and RAAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-raag" {
  application_group_id = azurerm_virtual_desktop_application_group.raag.id
  workspace_id         = azurerm_virtual_desktop_workspace.ragworkspace.id
}

# Get Log Analytics Workspace data
data "azurerm_log_analytics_workspace" "lawksp" {
  name                = lower(replace("law-avd-${var.prefix}", "-", ""))
  resource_group_name = azurerm_resource_group.sh.name

  depends_on = [
    azurerm_virtual_desktop_workspace.ragworkspace,
    azurerm_virtual_desktop_host_pool.raghostpool,
    azurerm_virtual_desktop_application_group.raag,
    azurerm_virtual_desktop_workspace_application_group_association.ws-raag,
    data.azurerm_log_analytics_workspace.lawksp
  ]
}




resource "azurerm_monitor_diagnostic_setting" "avd-hpr" {
  name                       = "AVD-Diag2"
  target_resource_id         = azurerm_virtual_desktop_host_pool.raghostpool.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp
  ]
  log {
    category = "AgentHealthStatus"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Checkpoint"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Connection"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Error"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "HostRegistration"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Management"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "NetworkData"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "SessionHostManagement"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
}




# Create Diagnostic Settings for AVD Desktop App Group
resource "azurerm_monitor_diagnostic_setting" "avd-rag1" {
  name                       = "AVD-Diag3"
  target_resource_id         = azurerm_virtual_desktop_application_group.raag.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp
  ]

  log {
    category = "Checkpoint"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "Error"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Management"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
}

# Create Diagnostic Settings for AVD Workspace
resource "azurerm_monitor_diagnostic_setting" "avd-wksp2" {
  name                       = "AVD-Diag4"
  target_resource_id         = azurerm_virtual_desktop_workspace.ragworkspace.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp
  ]

  log {
    category = "Checkpoint"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "Error"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Management"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

  log {
    category = "Feed"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
}
