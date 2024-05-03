resource "azurerm_user_assigned_identity" "mi" {
  name                = "id-avd-umi-${var.avdLocation}-${var.prefix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

## Azure Storage Accounts requires a globally unique names
## https://docs.microsoft.com/azure/storage/common/storage-account-overview
## Create a File Storage Account 
resource "azurerm_storage_account" "azfile" {
  name                      = local.storage_name
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  min_tls_version           = "TLS1_2"
  account_tier              = "Premium"
  account_replication_type  = "ZRS"
  account_kind              = "FileStorage"
  enable_https_traffic_only = true
  tags                      = local.tags
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi.id]
  }
  azure_files_authentication {
    directory_type = "AD"
      active_directory {
        domain_name          = var.domain_name
        netbios_domain_name  = "jensheerin"
        forest_name          = var.domain_name
        domain_guid          = "4a642002-4bbe-4969-b7c8-f5b361a717df"
        domain_sid           = "S-1-5-21-1296217075-2831364558-3283102104"
      }
    }
  }

resource "azurerm_storage_share" "FSShare" {
  name             = "fslogix"
  quota            = "100"
  enabled_protocol = "SMB"

  storage_account_name = azurerm_storage_account.azfile.name
  depends_on           = [azurerm_storage_account.azfile]

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
  scope              = azurerm_storage_account.azfile.id
  role_definition_id = data.azurerm_role_definition.storage_role.id
  principal_id       = data.azuread_group.existing.object_id

  depends_on = [azurerm_storage_account.azfile]
}

# Get Private DNS Zone for the Storage Private Endpoints
data "azurerm_private_dns_zone" "pe-filedns-zone" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.hub_dns_zone_rg
  provider            = azurerm.hub
  depends_on          = [azurerm_storage_share.FSShare]
}

resource "azurerm_private_endpoint" "afpe" {
  name                = "pe-${local.storage_name}-file"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.pesubnet.id
  tags                = local.tags

  private_service_connection {
    name                           = "psc-file-${var.prefix}"
    private_connection_resource_id = azurerm_storage_account.azfile.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
  private_dns_zone_group {
    name                 = "dns-file-${var.prefix}"
    private_dns_zone_ids = data.azurerm_private_dns_zone.pe-filedns-zone.*.id
  }
}

# Deny Traffic from Public Networks with white list exceptions
resource "azurerm_storage_account_network_rules" "stfw" {
  storage_account_id = azurerm_storage_account.azfile.id
  default_action     = "Deny"
  bypass             = ["AzureServices", "Metrics", "Logging"]
  ip_rules           = local.allow_list_ip
  depends_on = [azurerm_private_endpoint.afpe,
  azurerm_role_assignment.af_role, azurerm_storage_share.FSShare]
}

resource "azurerm_private_dns_zone_virtual_network_link" "filelink" {
  name                  = "azfilelink-${var.prefix}"
  resource_group_name   = var.hub_dns_zone_rg
  private_dns_zone_name = data.azurerm_private_dns_zone.pe-filedns-zone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  provider              = azurerm.hub

  lifecycle { ignore_changes = [tags] }
}

