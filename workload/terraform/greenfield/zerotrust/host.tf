
resource "time_rotating" "avd_token" {
  rotation_days = 1
}

resource "random_string" "AVD_local_password" {
  count            = var.rdsh_count
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}


resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.rdsh_count
  name                = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.shrg.name
  location            = azurerm_resource_group.shrg.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_resource_group.shrg
  ]
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                      = var.rdsh_count
  name                       = "avd-vm-${var.prefix}-${count.index + 1}"
  resource_group_name        = azurerm_resource_group.shrg.name
  location                   = azurerm_resource_group.shrg.location
  availability_set_id        = var.rdsh_count == 0 ? "" : azurerm_availability_set.avdset.*.id[count.index]
  size                       = var.vm_size
  network_interface_ids      = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent         = true
  admin_username             = var.local_admin_username
  admin_password             = azurerm_key_vault_secret.localpassword.value
  //encryption_at_host_enabled = true //'Microsoft.Compute/EncryptionAtHost' feature is must be enabled in the subscription for this setting to work https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-powershell

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }


  //source_image_id = data.azurerm_shared_image.avd.id
  source_image_id = "/subscriptions/${var.avdshared_subscription_id}/resourceGroups/${var.image_rg}/providers/Microsoft.Compute/galleries/${var.gallery_name}/images/${var.image_name}/versions/latest"
  depends_on = [
    azurerm_resource_group.shrg,
    azurerm_network_interface.avd_vm_nic,
    azurerm_resource_group.rg,
    azurerm_virtual_desktop_host_pool.hostpool
  ]

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "aadjoin" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}-${count.index + 1}-aadJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  /*
# Uncomment out settings for Intune
  settings = <<SETTINGS

     {
        "mdmId" : "0000000a-0000-0000-c000-000000000000"
      }
SETTINGS
*/
}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.aadjoin,
    azurerm_virtual_desktop_host_pool.hostpool,
    data.azurerm_log_analytics_workspace.lawksp
  ]
}

# MMA agent
resource "azurerm_virtual_machine_extension" "mma" {
  name                       = "MicrosoftMonitoringAgent"
  count                      = var.rdsh_count
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
      "workspaceId": "${data.azurerm_log_analytics_workspace.lawksp.workspace_id}"
    }
      SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
   "workspaceKey": "${data.azurerm_log_analytics_workspace.lawksp.primary_shared_key}"
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.aadjoin,
    azurerm_virtual_machine_extension.vmext_dsc,
    data.azurerm_log_analytics_workspace.lawksp
  ]
}

# Microsoft Antimalware
resource "azurerm_virtual_machine_extension" "mal" {
  name                       = "IaaSAntimalware"
  count                      = var.rdsh_count
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = "true"

  depends_on = [
    azurerm_virtual_machine_extension.aadjoin,
    azurerm_virtual_machine_extension.vmext_dsc,
    azurerm_virtual_machine_extension.mma,
    azurerm_virtual_machine_extension.cmkde
  ]
}

# Disk Encryption Set
resource "azurerm_disk_encryption_set" "en-set" {
  provider            = azurerm.spoke
  name                = "des-${var.prefix}-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  key_vault_key_id    = azurerm_key_vault_key.stcmky.id

  identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_key_vault.kv, azurerm_role_assignment.keystor, azurerm_key_vault_key.stcmky]

}

resource "azurerm_role_assignment" "ensetusr" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.en-set.identity[0].principal_id
  depends_on = [
    time_sleep.wait
  ]
}

# # Virtual Machine Extension for Disk Encryption set
resource "azurerm_virtual_machine_extension" "cmkde" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}-${count.index + 1}-cmkde"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryption"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "EncryptionOperation": "EnableEncryption",
        "KeyVaultURL": "${azurerm_key_vault.kv.vault_uri}",
        "KeyVaultResourceId": "${azurerm_key_vault.kv.id}",                  
        "KeyEncryptionKeyURL": "${azurerm_key_vault_key.stcmky.id}",         
        "KekVaultResourceId": "${azurerm_key_vault.kv.id}",  
        "KeyEncryptionAlgorithm": "RSA-OAEP",
        "VolumeType": "All"
    }
SETTINGS
}

# Aveailability Set for VMs
resource "azurerm_availability_set" "avdset" {
  name                         = "avail-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-001"
  resource_group_name          = azurerm_resource_group.shrg.name
  location                     = azurerm_resource_group.shrg.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
  tags                         = local.tags
}