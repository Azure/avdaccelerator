# Create a Resource Group for Shared items like AVD Alerts
resource "azurerm_resource_group" "rg_shared_name" {
  name     = "rg-shared"
  location = var.avdLocation
}

# Azure Action group for AVD Alerts
resource "azurerm_monitor_action_group" "ag" {
  provider            = azurerm.hub
  name                = "AVD_Alert_ActionGroup"
  resource_group_name = azurerm_resource_group.rg_shared_name.name
  short_name          = "avdactgrp" #  short_name to be in the range (1 - 12)
  email_receiver {
    name          = "sendtoavdadmin"
    email_address = var.email_address
  }
}

# Azure Alert for AVD VMs CPU
resource "azurerm_monitor_metric_alert" "avd_alert_cpu" {
  provider                 = azurerm.hub
  name                     = "AVD_Alert_CPU-metricalert"
  resource_group_name      = azurerm_resource_group.rg_shared_name.name
  target_resource_location = var.avdLocation
  scopes                   = ["/subscriptions/${var.hub_subscription_id}/resourceGroups/${var.rg_shared_name}"]
  description              = "AVD alert CPU"
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  severity                 = 3 # informational

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }
}
