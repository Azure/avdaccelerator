# Resource block to generate a random string for the local admin password
resource "random_string" "AVD_local_password" {
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}

# User Assigned Managed Identity for the MGMT VM to join storage accounts to the domain
resource "azurerm_user_assigned_identity" "stguai" {
  name                = "id-storage-${var.prefix}-${var.deployment_environment}-001"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Assigns the Managed Identity Storage Account Contributor RBAC to the Storage RG scope
resource "azurerm_role_assignment" "assign_stguai_sac" {
  scope                = data.azurerm_resource_group.rg_storage.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.stguai.principal_id
}

# Assigns the Managed Identity Reader RBAC to the Storage RG scope
resource "azurerm_role_assignment" "assign_stguai_sar" {
  scope                = data.azurerm_resource_group.rg_storage.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.stguai.principal_id
}

# Resource block to create a network interface for the AVD VM
resource "azurerm_network_interface" "avd_vm_nic" {
  name                          = "${var.prefix}-nic"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "nic_config"
    subnet_id                     = var.snet_ID
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

# Resource block to create an MGMT VM
resource "azurerm_windows_virtual_machine" "mgmt_vm" {
  name                       = "vm-mgmt-${var.prefix}"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = data.azurerm_resource_group.rg.location
  size                       = var.vm_size
  license_type               = "Windows_Client"
  network_interface_ids      = ["${azurerm_network_interface.avd_vm_nic.id}"]
  provision_vm_agent         = true
  admin_username             = var.local_admin_username
  admin_password             = var.localpassword
  encryption_at_host_enabled = true //'Microsoft.Compute/EncryptionAtHost' feature is must be enabled in the subscription for this setting to work https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-powershell
  secure_boot_enabled        = true
  vtpm_enabled               = true
  os_disk {
    name                 = lower(var.prefix)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  # To use marketplace image, uncomment the following lines and comment the source_image_id line
  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "latest"
  }
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.stguai.id
    ]
  }
}

# Resource block to join the MGMT VM to a domain
resource "azurerm_virtual_machine_extension" "domain_join" {
  name                       = "${var.prefix}-domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.mgmt_vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "${var.domain_name}",
      "OUPath": "${var.ou_path}",
      "User": "${var.domain_user}@${var.domain_name}",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${var.domain_password}"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

# resource "azurerm_virtual_machine_extension" "dscStorageScript" {
#   name                 = "AzureFilesDomainJoin"
#   virtual_machine_id   = azurerm_windows_virtual_machine.mgmt_vm.id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"

#     settings = jsonencode({
#     fileUris         = [var.baseScriptUri]
#     commandToExecute = "powershell.exe -ExecutionPolicy Unrestricted -File ${var.vfile} -DscPath ${var.dsc_storage_path} -StorageAccountName ${var.storage_account_name} -StorageAccountRG ${var.storage_account_rg} -StoragePurpose fslogix -DomainName ${var.domain_name} -IdentityServiceProvider ${var.IdentityServiceProvider} -AzureCloudEnvironment ${var.azure_cloud_environment} -SubscriptionId ${var.workloadSubsId} -DomainAdminUserName ${var.domain_user}@${var.domain_name} -CustomOuPath ${var.ou_path} -OUName ${var.ou_path} -CreateNewOU ${var.create_ou_for_storage_string} -ShareName ${var.fsshare} -ClientId ${azurerm_user_assigned_identity.stguai.principal_id} -DomainAdminUserPassword ${var.domain_password} -verbose"
#   })

#   depends_on = [
#     azurerm_virtual_machine_extension.domain_join
#   ]
# }

/*
# Resource block to install Microsoft Antimalware on the MGMT VM
resource "azurerm_virtual_machine_extension" "mal" {
  name                       = "IaaSAntimalware"
  virtual_machine_id         = azurerm_windows_virtual_machine.mgmt_vm.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = "true"

  depends_on = [
    azurerm_virtual_machine_extension.domain_join,
    azurerm_virtual_machine_extension.dsc-stor
  ]
}
*/