
# Creates Session Host 
# data "azurerm_shared_image" "avd" {
#   name                = var.image_name
#   gallery_name        = var.gallery_name
#   resource_group_name = var.image_rg
# }

resource "time_rotating" "avd_token" {
  rotation_days = 1
}
resource "azurerm_network_interface" "avd_vm_nic" {
  count = var.rdsh_count

  location                       = azurerm_resource_group.shrg.location
  name                           = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name            = azurerm_resource_group.shrg.name
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.subnet.id
  }

  depends_on = [
    azurerm_resource_group.shrg, module.network
  ]
}

# Availability Set
resource "azurerm_availability_set" "aset" {
  location                     = azurerm_resource_group.shrg.location
  name                         = "avail-avd-${var.avdLocation}-${var.prefix}"
  resource_group_name          = azurerm_resource_group.shrg.name
  managed                      = true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  tags                         = local.tags
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count = var.rdsh_count

  admin_password             = azurerm_key_vault_secret.localpassword.value
  admin_username             = var.local_admin_username
  location                   = azurerm_resource_group.shrg.location
  name                       = "avd-vm-${var.prefix}-${count.index + 1}"
  network_interface_ids      = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  resource_group_name        = azurerm_resource_group.shrg.name
  size                       = var.vm_size
  availability_set_id        = azurerm_availability_set.aset.id
  encryption_at_host_enabled = true //'Microsoft.Compute/EncryptionAtHost' feature is must be enabled in the subscription for this setting to work https://learn.microsoft.com/en-us/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-powershell
  license_type               = "Windows_Client"
  provision_vm_agent         = true
  secure_boot_enabled        = true
  tags                       = local.tags
  vtpm_enabled               = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_ZRS"
    name                 = "${lower(var.prefix)}-${count.index + 1}"
  }
  identity {
    type = "SystemAssigned"
  }
  # To use marketplace image, uncomment the following lines and comment the source_image_id line
  source_image_reference {
    offer     = var.offer
    publisher = var.publisher
    sku       = var.sku
    version   = "latest"
  }
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

  identity {
    type = "SystemAssigned"
  }
}
*/

# Virtual Machine Extension for Domain Join
resource "azurerm_virtual_machine_extension" "domain_join" {
  count = var.rdsh_count

  name                       = "${var.prefix}-${count.index + 1}-domainJoin"
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  auto_upgrade_minor_version = true
  protected_settings         = <<PROTECTED_SETTINGS
    {
      "Password": "${var.domain_password}"
    }
PROTECTED_SETTINGS
  settings                   = <<SETTINGS
    {
      "Name": "${var.domain_name}",
      "OUPath": "${var.ou_path}",
      "User": "${var.domain_user}@${var.domain_name}",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

# Virtual Machine Extension for AVD Agent
resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count = var.rdsh_count

  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  auto_upgrade_minor_version = true
  protected_settings         = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS
  settings                   = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02714.342.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${module.avm_res_desktopvirtualization_hostpool.resource.name}"
      }
    }
SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.domain_join,
    module.avm_res_desktopvirtualization_hostpool
  ]
}

# Virtual Machine Extension for AMA agent
resource "azurerm_virtual_machine_extension" "ama" {
  count = var.rdsh_count

  name                      = "AzureMonitorWindowsAgent"
  publisher                 = "Microsoft.Azure.Monitor"
  type                      = "AzureMonitorWindowsAgent"
  type_handler_version      = "1.22"
  virtual_machine_id        = azurerm_windows_virtual_machine.avd_vm[count.index].id
  automatic_upgrade_enabled = true
}

# Virtual Machine Extension for Microsoft Antimalware
resource "azurerm_virtual_machine_extension" "mal" {
  count = var.rdsh_count

  name                       = "IaaSAntimalware"
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.3"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm[count.index].id
  auto_upgrade_minor_version = "true"

  depends_on = [
    azurerm_virtual_machine_extension.domain_join,
    azurerm_virtual_machine_extension.vmext_dsc,
    azurerm_virtual_machine_extension.ama
  ]
}
