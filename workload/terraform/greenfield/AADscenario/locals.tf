locals {
  keyvault_name = lower("kv-avd-${var.prefix}-${random_string.random.id}")
  storage_name  = lower(replace("stavd${var.prefix}${random_string.random.id}", "-", ""))
  allow_list_ip = var.allow_list_ip
  white_list_ip = ["0.0.0.0"]
  tags = {
    environment        = var.prefix
    source             = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
    cm-resource-parent = module.avm-ptn-avd-lza-managementplane.virtual_desktop_host_pool.id
  }
}

