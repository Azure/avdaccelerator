locals {
  keyvault_name      = lower("kv-avd-${var.prefix}-${random_string.random.id}")
  storage_name       = lower(replace("stavd${var.prefix}${random_string.random.id}", "-", ""))
  allow_list_ip      = var.allow_list_ip
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
  tags = {
    environment        = var.prefix
    source             = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
    cm-resource-parent = azurerm_virtual_desktop_host_pool.hostpool.id
  }
}

