resource "azurerm_key_vault" "kv" {
  location                    = azurerm_resource_group.this.location
  name                        = local.keyvault_name
  resource_group_name         = azurerm_resource_group.this.name
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization   = true
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
  tags                        = local.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = local.allow_list_ip
  }

  lifecycle {
    ignore_changes = [access_policy, tags]
  }
}

# Get Private DNS Zone for the Key Vault Private Endpoints
data "azurerm_private_dns_zone" "pe-vaultdns-zone" {
  provider = azurerm.hub

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.hub_dns_zone_rg
}

resource "azurerm_private_endpoint" "kvpe" {
  location            = azurerm_resource_group.rg.location
  name                = "pe-${local.keyvault_name}-vault"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.subnet.id
  tags                = local.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "psc-kv-${var.prefix}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["Vault"]
  }
  private_dns_zone_group {
    name                 = "dns-kv-${var.prefix}"
    private_dns_zone_ids = data.azurerm_private_dns_zone.pe-vaultdns-zone.*.id
  }

  depends_on = [
    azurerm_key_vault.kv, azurerm_key_vault_secret.localpassword, azurerm_private_endpoint.kvpe
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Generate VM local password
resource "random_password" "vmpass" {
  length  = 20
  special = true
}
# Create Key Vault Secret
resource "azurerm_key_vault_secret" "localpassword" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "vmlocalpassword"
  value        = random_password.vmpass.result
  content_type = "Password"

  depends_on = [
    azurerm_role_assignment.keystor
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

# Linking DNS Zone to the existing DNS Zone in the Hub VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vaultlink" {
  provider = azurerm.hub

  name                  = "keydnsvnet_link-${var.prefix}"
  private_dns_zone_name = data.azurerm_private_dns_zone.pe-vaultdns-zone.name
  resource_group_name   = var.hub_dns_zone_rg
  virtual_network_id    = data.azurerm_virtual_network.vnet.id

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "time_sleep" "wait" {
  create_duration = "300s"
}

resource "azurerm_role_assignment" "keystor" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"

  depends_on = [
    time_sleep.wait
  ]
}

# Customer Managed Key for Storage Account
resource "azurerm_storage_account_customer_managed_key" "cmky" {
  provider = azurerm.spoke

  key_name                  = azurerm_key_vault_key.stkek.name
  storage_account_id        = azurerm_storage_account.azfile.id
  key_vault_id              = azurerm_key_vault.kv.id
  user_assigned_identity_id = azurerm_user_assigned_identity.mi.id

  depends_on = [
    azurerm_key_vault.kv, azurerm_key_vault_key.stcmky, azurerm_user_assigned_identity.mi
  ]
}

# Storage Account Encryption Key
resource "azurerm_key_vault_key" "stkek" {
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  key_type     = "RSA"
  key_vault_id = azurerm_key_vault.kv.id
  name         = "af-key"
  key_size     = 4096

  rotation_policy {
    expire_after         = "P90D"
    notify_before_expiry = "P29D"

    automatic {
      time_before_expiry = "P30D"
    }
  }
}


# Customer Managed Key for Disk Encryption
resource "azurerm_key_vault_key" "stcmky" {
  key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  key_type     = "RSA"
  key_vault_id = azurerm_key_vault.kv.id
  name         = "stor-key"
  key_size     = 4096

  rotation_policy {
    expire_after         = "P90D"
    notify_before_expiry = "P29D"

    automatic {
      time_before_expiry = "P30D"
    }
  }

  depends_on = [
    azurerm_role_assignment.keystor
  ]
}


