## Create a Resource Group for Storage
resource "azurerm_resource_group" "rg_storage" {
  location = var.avdLocation
  name     = var.rg_stor
}

# generate a random string (consisting of four characters)
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

## Azure Storage Accounts requires a globally unique names
## https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
## Create a File Storage Account 
resource "azurerm_storage_account" "storage" {
  name                      = "stor${random_string.random.id}"
  resource_group_name       = azurerm_resource_group.rg_storage.name
  location                  = azurerm_resource_group.rg_storage.location
  min_tls_version           = "TLS1_2"
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  account_kind              = "FileStorage"
  enable_https_traffic_only = true
}

resource "azurerm_storage_share" "FSShare" {
  name                 = "fslogix"
  quota                = "100"
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

resource "azurerm_private_endpoint" "pestor" {
  name                = "${var.prefix}-pe"
  location            = azurerm_resource_group.rg_storage.location
  resource_group_name = azurerm_resource_group.rg_storage.name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "${random_string.random.result}-privateserviceconnection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["file"]
  }
}
