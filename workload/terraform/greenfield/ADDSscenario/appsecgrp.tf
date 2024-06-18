data "azurerm_client_config" "cfg" {}

resource "azurerm_application_security_group" "example" {
  location            = azurerm_resource_group.shrg.location
  name                = "asg-avd-${var.avdLocation}-${var.prefix}-001"
  resource_group_name = azurerm_resource_group.shrg.name
  tags                = local.tags
}