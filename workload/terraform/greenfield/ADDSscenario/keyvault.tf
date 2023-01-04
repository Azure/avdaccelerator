resource "azurerm_key_vault" "kv" {
  name                     = local.keyvault_name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  sku_name                 = "standard"
  purge_protection_enabled = true
  tags                     = local.tags

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_desktop_host_pool.hostpool,
    azurerm_virtual_desktop_workspace.workspace,
    azurerm_virtual_desktop_application_group.dag
  ]


  lifecycle { ignore_changes = [access_policy, tags] }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = local.allow_list_ip
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

# Get Private DNS Zone for the Key Vault Private Endpoints
data "azurerm_private_dns_zone" "pe-vaultdns-zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.ad_rg
  provider            = azurerm.hub
}
resource "azurerm_private_endpoint" "kvpe" {
  name                = "pe-${local.keyvault_name}-vault"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet.id
  tags                = local.tags

  lifecycle { ignore_changes = [tags] }

  private_service_connection {
    name                           = "psc-kv-${var.prefix}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["Vault"]
  }
  depends_on = [
    azurerm_key_vault.kv, azurerm_key_vault_secret.localpassword
  ]
  private_dns_zone_group {
    name                 = "dns-kv-${var.prefix}"
    private_dns_zone_ids = data.azurerm_private_dns_zone.pe-vaultdns-zone.*.id
  }
}

# Generate VM local password
resource "random_password" "vmpass" {
  length  = 20
  special = true
}
# Create Key Vault Secret
resource "azurerm_key_vault_secret" "localpassword" {
  name            = "vmlocalpassword"
  value           = random_password.vmpass.result
  key_vault_id    = azurerm_key_vault.kv.id
  content_type    = "Password"
}

# Linking DNS Zone to the VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vaultlink" {
  name                  = "keydnsvnet_link"
  resource_group_name   = var.ad_rg
  private_dns_zone_name = data.azurerm_private_dns_zone.pe-vaultdns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id

  lifecycle { ignore_changes = [tags] }
}