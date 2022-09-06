# Resource group name is output when execution plan is applied.
resource "azurerm_resource_group" "sh" {
  name     = var.rg_so
  location = var.avdLocation
}


# Create AVD Personal workspace
resource "azurerm_virtual_desktop_workspace" "pworkspace" {
  name                = var.pworkspace
  resource_group_name = azurerm_resource_group.sh.name
  location            = azurerm_resource_group.sh.location
  friendly_name       = "${var.prefix} Personal Workspace"
  description         = "${var.prefix} Personal Workspace"
}

# Create AVD personal pool
resource "azurerm_virtual_desktop_host_pool" "personalpool" {
  resource_group_name   = azurerm_resource_group.sh.name
  location              = azurerm_resource_group.sh.location
  name                  = var.personalpool
  friendly_name         = var.personalpool
  validate_environment  = false
  custom_rdp_properties = "audiocapturemode:i:1;audiomode:i:0;"
  description           = "${var.prefix} Personal HostPool"
  type                  = "Personal"
  load_balancer_type    = "DepthFirst" #[BreadthFirst DepthFirst]
}

# Create AVD Personal DAG
resource "azurerm_virtual_desktop_application_group" "pdag" {
  resource_group_name = azurerm_resource_group.sh.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.personalpool.id
  location            = azurerm_resource_group.sh.location
  type                = "Desktop"
  name                = var.pag
  friendly_name       = "Desktop AppGroup"
  description         = "AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.personalpool, azurerm_virtual_desktop_workspace.pworkspace]
}

# Associate Workspace and PDAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-pdag" {
  application_group_id = azurerm_virtual_desktop_application_group.pdag.id
  workspace_id         = azurerm_virtual_desktop_workspace.pworkspace.id
}

# Get Log Analytics Workspace data
data "azurerm_log_analytics_workspace" "lawksp" {
  name                = lower(replace("law-avd-${var.prefix}", "-", ""))
  resource_group_name = azurerm_resource_group.sh.name

  depends_on = [
    azurerm_virtual_desktop_workspace.pworkspace,
    azurerm_virtual_desktop_host_pool.personalpool,
    azurerm_virtual_desktop_application_group.pdag,
    azurerm_virtual_desktop_workspace_application_group_association.ws-pdag,
    data.azurerm_log_analytics_workspace.lawksp
  ]
}

resource "azurerm_monitor_diagnostic_setting" "avd-hp2" {
  name                       = "AVD-Diag5"
  target_resource_id         = azurerm_virtual_desktop_host_pool.personalpool.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.lawksp.id

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
resource "azurerm_monitor_diagnostic_setting" "avd-dag2" {
  name                       = "AVD-Diag6"
  target_resource_id         = azurerm_virtual_desktop_application_group.pdag.id
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
  name                       = "AVD-Diag6"
  target_resource_id         = azurerm_virtual_desktop_workspace.pworkspace.id
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
