# Resource group name is output when execution plan is applied.
resource "azurerm_resource_group" "sh" {
  name     = var.rg_so
  location = var.avdLocation
}

# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = var.workspace
  resource_group_name = azurerm_resource_group.sh.name
  location            = azurerm_resource_group.sh.location
  friendly_name       = "${var.prefix} Workspace"
  description         = "${var.prefix} Workspace"
}

# Create AVD Personal workspace
resource "azurerm_virtual_desktop_workspace" "pworkspace" {
  name                = var.pworkspace
  resource_group_name = azurerm_resource_group.sh.name
  location            = azurerm_resource_group.sh.location
  friendly_name       = "${var.prefix} Personal Workspace"
  description         = "${var.prefix} Personal Workspace"
}

# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  resource_group_name      = azurerm_resource_group.sh.name
  location                 = azurerm_resource_group.sh.location
  name                     = var.hostpool
  friendly_name            = var.hostpool
  validate_environment     = true
  custom_rdp_properties    = "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:1"
  description              = "${var.prefix} Pooled HostPool"
  type                     = "Pooled"
  maximum_sessions_allowed = 16
  load_balancer_type       = "DepthFirst" #[BreadthFirst DepthFirst]
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

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = var.rfc3339
}

# Create AVD Personal DAG
resource "azurerm_virtual_desktop_application_group" "pdag" {
  resource_group_name = azurerm_resource_group.sh.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.personalpool.id
  location            = azurerm_resource_group.sh.location
  type                = "Desktop"
  name                = "${var.prefix}-pdag"
  friendly_name       = "Desktop AppGroup"
  description         = "AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.personalpool, azurerm_virtual_desktop_workspace.pworkspace]
}

# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "dag" {
  resource_group_name = azurerm_resource_group.sh.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
  location            = azurerm_resource_group.sh.location
  type                = "Desktop"
  name                = "${var.prefix}-dag"
  friendly_name       = "Desktop AppGroup"
  description         = "AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace.workspace]
}

# Create AVD RAAG
resource "azurerm_virtual_desktop_application_group" "raag" {
  resource_group_name = azurerm_resource_group.sh.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.hostpool.id
  location            = azurerm_resource_group.sh.location
  type                = "RemoteApp"
  name                = "${var.prefix}-raag"
  friendly_name       = "RemoteAppGroup"
  description         = "AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace.workspace]
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
}

# Associate Workspace and RAAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-raag" {
  application_group_id = azurerm_virtual_desktop_application_group.raag.id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
}

# Associate Workspace and PDAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-pdag" {
  application_group_id = azurerm_virtual_desktop_application_group.pdag.id
  workspace_id         = azurerm_virtual_desktop_workspace.pworkspace.id
}