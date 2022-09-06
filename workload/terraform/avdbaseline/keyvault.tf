resource "azurerm_resource_group" "rgkv" {
  name     = var.rg_so
  location = var.avdLocation
}

resource "azurerm_key_vault" "kv" {
  name                     = local.keyvault_name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  location                 = var.avdLocation
  resource_group_name      = var.rg_so
  sku_name                 = "standard"
  purge_protection_enabled = true
  tags                     = local.tags
  depends_on = [
    azurerm_resource_group.rgkv
  ]

  lifecycle { ignore_changes = [access_policy, tags] }

  network_acls {
    default_action = "Deny"
    bypass         = "None"
  }
}

resource "azurerm_key_vault_access_policy" "deploy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions         = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
  certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Purge", "Recover"]
  storage_permissions     = ["Get", "List", "Update", "Delete"]
}

resource "azurerm_private_endpoint" "kvpe" {
  name                = "pe-${local.keyvault_name}-vault"
  location            = var.avdLocation
  resource_group_name = var.rg_so
  subnet_id           = data.azurerm_subnet.subnet.id
  tags                = local.tags

  lifecycle { ignore_changes = [tags] }

  private_service_connection {
    name                           = "psc-kv-${var.prefix}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }
}

