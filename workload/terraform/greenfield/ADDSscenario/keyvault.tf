module "avm-res-keyvault-vault" {
  source                        = "Azure/avm-res-keyvault-vault/azurerm"
  version                       = "0.5.3"
  name                          = local.keyvault_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled      = true
  enabled_for_disk_encryption   = true
  tags                          = local.tags
  enabled_for_deployment        = true
  public_network_access_enabled = false
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [data.azurerm_private_dns_zone.pe-vaultdns-zone.id]
      subnet_resource_id            = data.azurerm_subnet.subnet.id
    }
  }
  diagnostic_settings = {
    to_la = {
      name                  = "to-law"
      workspace_resource_id = module.avm_res_operationalinsights_workspace.resource.id
    }
  }
  network_acls = {
    bypass   = "AzureServices"
    ip_rules = local.allow_list_ip
  }
}

check "dns" {
  data "azurerm_private_dns_a_record" "assertion" {
    name                = local.keyvault_name
    zone_name           = "privatelink.vaultcore.azure.net"
    resource_group_name = azurerm_resource_group.this.name
  }
  assert {
    condition     = one(data.azurerm_private_dns_a_record.assertion.records) == one(module.avm-res-keyvault-vault.private_endpoints["primary"].private_service_connection).private_ip_address
    error_message = "The private DNS A record for the private endpoint is not correct."
  }
}

# Get Private DNS Zone for the Key Vault Private Endpoints
data "azurerm_private_dns_zone" "pe-vaultdns-zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.hub_dns_zone_rg
  provider            = azurerm.hub
}

# Linking DNS Zone to the existing DNS Zone in the Hub VNET
resource "azurerm_private_dns_zone_virtual_network_link" "vaultlink" {
  name                  = "keydnsvnet_link-${var.prefix}"
  resource_group_name   = var.hub_dns_zone_rg
  private_dns_zone_name = data.azurerm_private_dns_zone.pe-vaultdns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  provider              = azurerm.hub

  lifecycle { ignore_changes = [tags] }
}

resource "time_sleep" "wait" {
  create_duration = "300s"
}

resource "azurerm_role_assignment" "keystor" {
  scope                = module.avm-res-keyvault-vault.resource.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
  depends_on = [
    time_sleep.wait
  ]
}
