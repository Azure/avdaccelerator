# Configure the AVD insights workbook settings

# Capture the windows events for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_event" "winevts" {
  name                = "winevts-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Application"
  event_types    = ["Error", "Warning"]
}

# Capture the windows system events for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_event" "wsysevts" {
  name                = "winsysevts-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "System"
  event_types    = ["Error", "Warning"]
}

# Capture the windows FSLogix events for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts" {
  name                = "fslogixevts-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-FSLogix-Apps/Admin"
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

# Capture the windows Terminal events for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts4" {
  name                = "fslogixevts4-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
  event_types    = ["Error", "Warning", "Information"]
}

# Capture the windows Terminal events for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts5" {
  name                = "fslogixevts5-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational"
  event_types    = ["Error", "Warning", "Information"]
}

# Capture the windows Terminal events for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_event" "fslogixevts6" {
  name                = "fslogixevts6-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name

  event_log_name = "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin"
  event_types    = ["Error", "Warning", "Information"]
}


# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf" {
  name                = "winperf-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "Processor Information"
  counter_name        = "% Processor Time"
  instance_name       = "_Total"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf1" {
  name                = "winperf1-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "LogicalDisk"
  counter_name        = "% Free Space"
  instance_name       = "C:"
  interval_seconds    = "60"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf2" {
  name                = "winperf2-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "LogicalDisk"
  counter_name        = "Avg. Disk Queue Length"
  instance_name       = "C:"
  interval_seconds    = "30"

}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf3" {
  name                = "winperf3-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "LogicalDisk"
  counter_name        = "Avg. Disk sec/Transfer"
  instance_name       = "C:"
  interval_seconds    = "60"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf4" {
  name                = "winperf4-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "LogicalDisk"
  counter_name        = "Current Disk Queue Length"
  instance_name       = "C:"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf5" {
  name                = "winperf5-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "Memory"
  counter_name        = "% Committed Bytes In Use"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf6" {
  name                = "winperf6-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "Memory"
  counter_name        = "Available Mbytes"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf7" {
  name                = "winperf7-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "Memory"
  counter_name        = "Page Faults/sec"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf8" {
  name                = "winperf8-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "Memory"
  counter_name        = "Pages/sec"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf9" {
  name                = "winperf9-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "PhysicalDisk"
  counter_name        = "Avg. Disk Queue Length"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf10" {
  name                = "winperf10-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "PhysicalDisk"
  counter_name        = "Avg. Disk sec/Read"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf11" {
  name                = "winperf11-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "PhysicalDisk"
  counter_name        = "Avg. Disk sec/Transfer"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf12" {
  name                = "winperf12-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "PhysicalDisk"
  counter_name        = "Avg. Disk sec/Write"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf13" {
  name                = "winperf13-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "RemoteFX Network"
  counter_name        = "Current TCP RTT"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf14" {
  name                = "winperf14-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "RemoteFX Network"
  counter_name        = "Current UDP Bandwidth"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf15" {
  name                = "winperf15-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "Terminal Services"
  counter_name        = "Active Sessions"
  instance_name       = "*"
  interval_seconds    = "60"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf16" {
  name                = "winperf16-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "Terminal Services"
  counter_name        = "Inactive Sessions"
  instance_name       = "*"
  interval_seconds    = "60"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf17" {
  name                = "winperf17-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "Terminal Services"
  counter_name        = "Total Sessions"
  instance_name       = "*"
  interval_seconds    = "60"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf18" {
  name                = "winperf18-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "User Input Delay per Process"
  counter_name        = "Max Input Delay"
  instance_name       = "*"
  interval_seconds    = "30"
}

# capture the performance counters for the AVD insights workbook
resource "azurerm_log_analytics_datasource_windows_performance_counter" "winperf19" {
  name                = "winperf19-lad-wpc"
  resource_group_name = azurerm_resource_group.share.name
  workspace_name      = azurerm_log_analytics_workspace.lawksp.name
  object_name         = "User Input Delay per Session"
  counter_name        = "Max Input Delay"
  instance_name       = "*"
  interval_seconds    = "30"
}