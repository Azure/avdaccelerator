data "azuread_user" "aad_user" {
  for_each            = toset(var.avd_users)
  user_principal_name = each.key
}

data "azurerm_role_definition" "role" { # access an existing built-in role
  name = "Desktop Virtualization User"
}

data "azuread_group" "adds_group" {
  display_name     = var.aad_group_name
  security_enabled = true
}

resource "azurerm_role_assignment" "role" {
  scope              = azurerm_virtual_desktop_application_group.dag.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = data.azuread_group.adds_group.id
}