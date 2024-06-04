resource "azurerm_user_assigned_identity" "mi" {
  location            = azurerm_resource_group.rg.location
  name                = "id-avd-umi-${var.avdLocation}-${var.prefix}"
  resource_group_name = azurerm_resource_group.rg.name
}

## Azure Storage Accounts requires a globally unique names
## https://docs.microsoft.com/azure/storage/common/storage-account-overview
## Create a File Storage Account 
resource "azurerm_storage_account" "azfile" {
  account_replication_type  = "ZRS"
  account_tier              = "Premium"
  location                  = azurerm_resource_group.rg.location
  name                      = local.storage_name
  resource_group_name       = azurerm_resource_group.rg.name
  account_kind              = "FileStorage"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = local.tags

  azure_files_authentication {
    directory_type = "AD"

    active_directory {
      domain_guid         = var.domain_guid
      domain_name         = var.domain_name
      domain_sid          = var.domain_sid
      forest_name         = var.domain_name
      netbios_domain_name = var.netbios_domain_name
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi.id]
  }
}

resource "azurerm_storage_share" "FSShare" {
  name                 = "fslogix"
  quota                = "100"
  storage_account_name = azurerm_storage_account.azfile.name
  enabled_protocol     = "SMB"

  depends_on = [azurerm_storage_account.azfile]

  lifecycle {
    ignore_changes = [quota]
  }
}


## Azure built-in roles
## https://docs.microsoft.com/azure/role-based-access-control/built-in-roles
data "azurerm_role_definition" "storage_role" {
  name = "Storage File Data SMB Share Contributor"
}

resource "azurerm_role_assignment" "af_role" {
  principal_id       = data.azuread_group.existing.object_id
  scope              = azurerm_storage_account.azfile.id
  role_definition_id = data.azurerm_role_definition.storage_role.id

  depends_on = [azurerm_storage_account.azfile]
}

# Get Private DNS Zone for the Storage Private Endpoints
data "azurerm_private_dns_zone" "pe-filedns-zone" {
  provider = azurerm.hub

  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.hub_dns_zone_rg

  depends_on = [azurerm_storage_share.FSShare]
}

resource "azurerm_private_endpoint" "afpe" {
  location            = azurerm_resource_group.rg.location
  name                = "pe-${local.storage_name}-file"
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.pesubnet.id
  tags                = local.tags

  private_service_connection {
    is_manual_connection           = false
    name                           = "psc-file-${var.prefix}"
    private_connection_resource_id = azurerm_storage_account.azfile.id
    subresource_names              = ["file"]
  }
  private_dns_zone_group {
    name                 = "dns-file-${var.prefix}"
    private_dns_zone_ids = data.azurerm_private_dns_zone.pe-filedns-zone.*.id
  }
}

# Deny Traffic from Public Networks with white list exceptions
resource "azurerm_storage_account_network_rules" "stfw" {
  default_action     = "Deny"
  storage_account_id = azurerm_storage_account.azfile.id
  bypass             = ["AzureServices", "Metrics", "Logging"]
  ip_rules           = local.allow_list_ip

  depends_on = [azurerm_private_endpoint.afpe,
  azurerm_role_assignment.af_role, azurerm_storage_share.FSShare]
}

resource "azurerm_private_dns_zone_virtual_network_link" "filelink" {
  provider = azurerm.hub

  name                  = "azfilelink-${var.prefix}"
  private_dns_zone_name = data.azurerm_private_dns_zone.pe-filedns-zone.name
  resource_group_name   = var.hub_dns_zone_rg
  virtual_network_id    = data.azurerm_virtual_network.vnet.id

  lifecycle {
    ignore_changes = [tags]
  }
}

