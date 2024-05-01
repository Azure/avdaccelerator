locals {
  keyvault_name      = lower("kv-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${random_string.random.id}")
  storage_name       = lower(replace("stavd${var.prefix}${random_string.random.id}", "-", ""))
  allow_list_ip      = var.allow_list_ip
  white_list_ip      = ["0.0.0.0"]
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
  tags = {
    environment        = var.prefix
    cm-resource-parent = module.avm_res_desktopvirtualization_hostpool.resource.id
  }
}
