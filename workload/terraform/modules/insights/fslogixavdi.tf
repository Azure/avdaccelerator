# Capture the windows FSLogix events for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts" {
  name                = "fslogixevts-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-FSLogix-Apps/Admin"
  event_types    = ["Error", "Warning", "Information"]
}

resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts6" {
  name                = "fslogixevts6-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin"
  event_types    = ["Error", "Warning", "Information"]
}

resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts5" {
  name                = "fslogixevts5-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational"
  event_types    = ["Error", "Warning", "Information"]
}

resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts4" {
  name                = "fslogixevts4-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
  event_types    = ["Error", "Warning", "Information"]
}

resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts1" {
  name                = "fslogixevts1-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-FSLogix-Apps/Operational"
  event_types    = ["Error", "Warning", "Information"]
}

resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts2" {
  name                = "fslogixevts2-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-FSLogix-Apps/Debug"
  event_types    = ["Error", "Warning"]
}

resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts3" {
  name                = "fslogixevts3-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-FSLogix-Apps/Perf"
  event_types    = ["Error", "Warning"]
}
