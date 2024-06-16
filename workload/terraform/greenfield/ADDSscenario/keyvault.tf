module "avm-res-keyvault-vault" {
  source                      = "Azure/avm-res-keyvault-vault/azurerm"
  version                     = "0.5.3"
  location                    = azurerm_resource_group.this.location
  name                        = local.keyvault_name
  resource_group_name         = azurerm_resource_group.this.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
  tags                        = local.tags
  diagnostic_settings = {
    to_la = {
      name                  = "to-la"
      workspace_resource_id = module.avm_res_operationalinsights_workspace.resource.id
    }
  }

  public_network_access_enabled = true
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [data.azurerm_private_dns_zone.pe-vaultdns-zone.id]
      subnet_resource_id            = data.azurerm_subnet.pesubnet.id
    }
  }

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["136.28.83.128"]
    virtual_network_subnet_ids = [
      data.azurerm_subnet.pesubnet.id
    ]
  }

  keys = {
    cmk_for_storage_account = {
      key_opts = [
        "decrypt",
        "encrypt",
        "sign",
        "unwrapKey",
        "verify",
        "wrapKey"
      ]

      key_type     = "RSA"
      key_vault_id = module.avm-res-keyvault-vault.resource.id
      name         = "cmk-for-storage-account"
      key_size     = 2048
    }
  }
}

# Generate VM local password
resource "random_password" "vmpass" {
  length  = 20
  special = true
}

# Create Key Vault Secret
resource "azurerm_key_vault_secret" "localpassword" {
  key_vault_id = module.avm-res-keyvault-vault.resource.id
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

# Sets RBAC permission for Key Vault
resource "azurerm_role_assignment" "keystor" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = module.avm-res-keyvault-vault.resource.id
  role_definition_name = "Key Vault Administrator"
}
