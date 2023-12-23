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

# Resource block to create a network interface for the Management VM
resource "azurerm_network_interface" "avd_vm_nic" {
  name                          = "${var.prefix}-nic"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "nic_config"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    data.azurerm_resource_group.rg
  ]
}

# Resource block to create the Management VM
resource "azurerm_windows_virtual_machine" "mgmt_vm" {
  name                       = "vm-mgmt-${var.prefix}"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = data.azurerm_resource_group.rg.location
  size                       = var.vm_size
  license_type               = "Windows_Client"
  network_interface_ids      = ["${azurerm_network_interface.avd_vm_nic.id}"]
  provision_vm_agent         = true
  admin_username             = var.local_admin_username
  admin_password             = var.local_admin_password
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
    publisher = var.vm_source_image_reference.publisher
    offer     = var.vm_source_image_reference.offer
    sku       = var.vm_source_image_reference.sku
    version   = var.vm_source_image_reference.version
  }
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.stguai.id
    ]
  }
}

# Resource block to join the Management VM to a domain
resource "azurerm_virtual_machine_extension" "mngmvm_domain_join" {
  name                       = "${var.prefix}-domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.mgmt_vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "${var.domain_name}",
      "OUPath": "${var.custom_ou_path}",
      "User": "${var.domain_name}\\${var.domain_user}",
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

  depends_on = [azurerm_windows_virtual_machine.mgmt_vm]
}


# Resource block to run Custom Script Extension on the Management VM for FSLogix configuration if an url is provided
resource "azurerm_virtual_machine_extension" "dscStorageScript_urlfile" {
  count                = var.url_powershell_script != "" ? 1 : 0
  name                 = "${var.prefix}-AzureFilesDomainJoin-Url"
  virtual_machine_id   = azurerm_windows_virtual_machine.mgmt_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"


  settings = jsonencode({
    fileUris         = [var.url_powershell_script]
    commandToExecute = local.commandToExecute_UrlFile
  })

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [
    azurerm_user_assigned_identity.stguai
    , azurerm_virtual_machine_extension.mngmvm_domain_join
  ]
}

# Resource block to run Custom Script Extension on the Management VM for FSLogix configuration if the local file is provided
resource "azurerm_virtual_machine_extension" "dscStorageScript_localfile" {
  count                = var.url_powershell_script == "" && var.localpath_powershell_script != "" ? 1 : 0
  name                 = "${var.prefix}-AzureFilesDomainJoin-Local"
  virtual_machine_id   = azurerm_windows_virtual_machine.mgmt_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = jsonencode({
    commandToExecute = local.commandToExecute_LocalFile
  })

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [
    azurerm_user_assigned_identity.stguai
    , azurerm_virtual_machine_extension.mngmvm_domain_join
  ]
}

# Resource block to intall Extension for MMA agent on the Management VM
resource "azurerm_virtual_machine_extension" "mma" {
  count                       = var.log_analytics_workspace == null ? 0 : 1
  name                        = "MicrosoftMonitoringAgent"
  virtual_machine_id          = azurerm_windows_virtual_machine.mgmt_vm.id
  publisher                   = "Microsoft.EnterpriseCloud.Monitoring"
  type                        = "MicrosoftMonitoringAgent"
  type_handler_version        = "1.0"
  auto_upgrade_minor_version  = true
  failure_suppression_enabled = true
  settings                    = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_workspace.workspace_id}"
    }
      SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
   "workspaceKey": "${var.log_analytics_workspace.workspace_key}"
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.mngmvm_domain_join
  ]
  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

# Virtual Machine Extension for Microsoft Antimalware
resource "azurerm_virtual_machine_extension" "mal" {
  name                        = "IaaSAntimalware"
  virtual_machine_id          = azurerm_windows_virtual_machine.mgmt_vm.id
  publisher                   = "Microsoft.Azure.Security"
  type                        = "IaaSAntimalware"
  type_handler_version        = "1.3"
  auto_upgrade_minor_version  = "true"
  failure_suppression_enabled = true


  depends_on = [
    azurerm_virtual_machine_extension.mngmvm_domain_join
  ]
  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}
