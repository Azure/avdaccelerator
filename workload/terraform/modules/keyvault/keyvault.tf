resource "azurerm_key_vault" "kv" {
  name                     = local.kv_name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  location                 = data.azurerm_resource_group.rg.location
  resource_group_name      = data.azurerm_resource_group.rg.name
  sku_name                 = "standard"
  purge_protection_enabled = true

  depends_on = [
    data.azurerm_resource_group.rg
  ]


  lifecycle { ignore_changes = [access_policy, tags] }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"

    # The list of allowed ip addresses.
    ip_rules = ["0.0.0.0"]
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
  name                = "pe-${lower("kv-avd-${var.prefix}-${random_string.random.id}")}-vault"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet.id

  lifecycle { ignore_changes = [tags] }

  private_service_connection {
    name                           = "psc-kv-${var.prefix}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }
}

#Create VM local admin password
resource "random_password" "vmlocalpassword" {
  length  = 20
  special = true
}
#Create Key Vault Secret for local admin password
resource "azurerm_key_vault_secret" "vmlocalpassword" {
  name         = "avdVmLocalUserName"
  value        = random_password.vmlocalpassword.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

#Create Key Vault Secret for domain password
resource "azurerm_key_vault_secret" "domainjoinerpassword" {
  name         = var.domain_user
  value        = var.domain_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}