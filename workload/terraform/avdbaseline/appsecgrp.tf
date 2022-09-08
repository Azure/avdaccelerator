data "azurerm_client_config" "cfg" {}

resource "azurerm_application_security_group" "example" {
  name                = "avdasg-${var.avdLocation}-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Environment = "ACC Terraform"
  }
}