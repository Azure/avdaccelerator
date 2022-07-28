data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "keyrg" {
  name     = var.rg_so
  location = var.avdLocation
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "avd-${random_string.random.id}-acctf"
  location                    = azurerm_resource_group.keyrg.location
  resource_group_name         = azurerm_resource_group.keyrg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "azurerm_private_endpoint" "pe" {
  name                = "keyvault-endpoint"
  location            = azurerm_resource_group.keyrg.location
  resource_group_name = azurerm_resource_group.keyrg.name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "${random_string.random.result}-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}
