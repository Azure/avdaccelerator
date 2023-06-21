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

//  target_resource_type     = "microsoft.desktopvirtualization/hostpools"

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert_v2" {
  provider            = azurerm.spoke
  name                = "Unhealthy VM"
  resource_group_name = azurerm_resource_group.rg_shared_name.name
  location            = var.avdLocation

  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [data.azurerm_log_analytics_workspace.lawksp.id]
  severity             = 4

  criteria {
    query = <<-QUERY
       WVDAgentHealthStatus 
        | where EndpointState <> "Healthy" 
    QUERY

    time_aggregation_method = "Maximum"
    threshold               = 99.0
    operator                = "LessThan"

    resource_id_column    = "_ResourceId"
    metric_measure_column = "AggregatedValue"

    dimension {
      name     = "Computer"
      operator = "Include"
      values   = ["*"]
    }

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  auto_mitigation_enabled          = false
  workspace_alerts_storage_enabled = false
  description                      = "This is V2 custom log alert"
  display_name                     = "Unhealthy VM"
  enabled                          = true
  query_time_range_override        = "P2D"
  skip_query_validation            = false


}