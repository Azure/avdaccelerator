module "avdi" {
  source      = "../insights"
  avdLocation = var.avdLocation
  prefix      = var.prefix
  rg_avdi     = var.rg_avdi
}

data "azurerm_log_analytics_workspace" "lawksp" {
  name                = lower(replace("law-avd-${substr(var.avdLocation, 0, 5)}", "-", ""))
  resource_group_name = "rg-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${var.rg_avdi}"

  depends_on = [
    data.azurerm_log_analytics_workspace.lawksp,
    module.avdi
  ]

}


# Azure Alert for AVD VMs Unhealthy
resource "azurerm_monitor_metric_alert" "avd_health_alert" {
  provider                 = azurerm.spoke
  name                     = "Unhealthy VM"
  resource_group_name      = azurerm_resource_group.rg_shared_name.name
  target_resource_location = var.avdLocation
  scopes                   = ["/subscriptions/${var.hub_subscription_id}"]
  description              = "Unhealthy AVD Session Host"
  target_resource_type     = "microsoft.desktopvirtualization/hostpools"
  frequency                = "PT1M"
  window_size              = "PT5M"

  query = <<-QUERY
  WVDAgentHealthStatus 
    | where EndpointState <> "Healthy" 
  QUERY
  criteria {
    metric_namespace = "Microsoft.DesktopVirtualization/hostpools"
    metric_name      = "Unhealthy VMs"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}