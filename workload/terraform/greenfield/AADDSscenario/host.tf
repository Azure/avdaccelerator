
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
  size                       = var.vm_size
  network_interface_ids      = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent         = true
  admin_username             = var.local_admin_username
  admin_password             = azurerm_key_vault_secret.localpassword.value
  encryption_at_host_enabled = true //'Microsoft.Compute/EncryptionAtHost' feature is must be enabled in the subscription for this setting to work https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-powershell

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  /*
  //source_image_id = data.azurerm_shared_image.avd.id
  source_image_id = "/subscriptions/${var.avdshared_subscription_id}/resourceGroups/${var.image_rg}/providers/Microsoft.Compute/galleries/${var.gallery_name}/images/${var.image_name}/versions/latest"
  depends_on = [
    azurerm_resource_group.shrg,
    azurerm_network_interface.avd_vm_nic,
    azurerm_resource_group.rg,
    azurerm_virtual_desktop_host_pool.hostpool
  ]
*/
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "aaddsjoin" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}-${count.index + 1}-aaddsJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtensions"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "Name": "${azurerm_active_directory_domain_service.aadds.domain_name}",
      "OUPath": "${var.ou_path}",
      "User": "${azuread_user.dc_admin.user_principal_name}",
      "Restart": "true",
      "Options": "3"
    }
    SETTINGS

  protected_settings = <<-PROTECTED_SETTINGS
    {
      "Password": "${random_password.dc_admin.result}"
    }
    PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

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
    azurerm_virtual_machine_extension.mma
  ]
}
