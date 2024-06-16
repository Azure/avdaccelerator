data "azurerm_role_definition" "role" { # access an existing built-in role
  name = "Desktop Virtualization User"
}

data "azuread_group" "adds_group" {
  display_name     = var.user_group_name
  security_enabled = true
}

resource "azurerm_role_assignment" "role" {
  scope              = module.avm_res_desktopvirtualization_hostpool.resource.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = data.azuread_group.adds_group.id
}

# Grant users access to Microsoft Entra ID-joined virtual machines
# https://learn.microsoft.com/azure/virtual-desktop/azure-ad-joined-session-hosts#assign-user-access-to-host-pools
data "azurerm_role_definition" "vm_useraad" {
  name = "Virtual Machine User Login"
}

resource "azurerm_role_assignment" "vm_useraad" {
  scope              = azurerm_resource_group.shrg.id
  role_definition_id = data.azurerm_role_definition.vm_useraad.id
  principal_id       = data.azuread_group.adds_group.id
}
