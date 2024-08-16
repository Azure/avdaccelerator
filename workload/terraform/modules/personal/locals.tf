locals {
  tags = {
    environment        = var.prefix
    source             = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
    cm-resource-parent = azurerm_virtual_desktop_host_pool.personalpool.id
  }
}