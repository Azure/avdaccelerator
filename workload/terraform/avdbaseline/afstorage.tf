resource "azurerm_user_assigned_identity" "mi" {
  name                = "id-avd-fslogix-eus-${var.prefix}"
  resource_group_name = azurerm_resource_group.rg_storage.name
  location            = azurerm_resource_group.rg_storage.location
}

## Azure Storage Accounts requires a globally unique names
## https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
## Create a File Storage Account 
resource "azurerm_storage_account" "storage" {
  name                      = local.storage_name
  resource_group_name       = azurerm_resource_group.rg_storage.name
  location                  = azurerm_resource_group.rg_storage.location
  min_tls_version           = "TLS1_2"
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  account_kind              = "FileStorage"
  enable_https_traffic_only = true

  network_rules {
    default_action = "Deny"
    bypass         = ["Metrics", "Logging", "AzureServices"]
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_share" "FSShare" {
  name             = "fslogix"
  quota            = "100"
  enabled_protocol = "SMB"


  storage_account_name = azurerm_storage_account.storage.name
  depends_on           = [azurerm_storage_account.storage]
}


## Azure built-in roles
## https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
data "azurerm_role_definition" "storage_role" {
  name = "Storage File Data SMB Share Contributor"
}

resource "azuread_group" "aad_group" {
  display_name     = var.aad_group_name
  security_enabled = true
}

resource "azurerm_role_assignment" "af_role" {
  scope              = azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.storage_role.id
  principal_id       = azuread_group.aad_group.id
}


resource "azurerm_private_endpoint" "afpe" {
  name                = "pe-${local.storage_name}-file"
  location            = azurerm_resource_group.rg_storage.location
  resource_group_name = azurerm_resource_group.rg_storage.name
  subnet_id           = data.azurerm_subnet.subnet.id
  tags                = local.tags

  lifecycle { ignore_changes = [tags] }

  private_service_connection {
    name                           = "psc-file-${var.prefix}"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}




