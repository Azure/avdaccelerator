data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "role" { # access an existing built-in role
  name = "Desktop Virtualization User"
}

data "azuread_group" "adds_group" {
  display_name     = var.aad_group_name
  security_enabled = true
}