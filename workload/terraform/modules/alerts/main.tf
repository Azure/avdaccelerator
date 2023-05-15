# Azure Action group for AVD Alerts
resource "azurerm_monitor_action_group" "ag" {
  provider            = azurerm.hub
  name                = "AVD_Alert_ActionGroup"
  resource_group_name = azurerm_resource_group.share.name
  short_name          = "avdactiongroup"
  email_receiver {
    name          = "sendto'***REMOVED***'"
    email_address = "jensheerin@microsoft.com"
  }
}

# Azure Alert for AVD VMs CPU
resource "azurerm_monitor_metric_alert" "avd_alert_cpu" {
  provider             = azurerm.hub
  name                 = "AVD_Alert_CPU-metricalert"
  resource_group_name  = azurerm_resource_group.share.name
  target_resource_location = "Global"
  scopes               = [azurerm_virtual_desktop_host_pool.hostpool.id]
  description          = "AVD alert CPU"
  target_resource_type = "Microsoft.Compute/virtualMachines"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name = "% Processor Time"  # "% Processor Time" is the metric name for CPU
    aggregation = "Total"
    operator  = "GreaterThan"
    threshold = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}
