resource "azurerm_user_assigned_identity" "mi" {
  name                = "id-avd-fslogix-eus-${var.prefix}"
  resource_group_name = azurerm_resource_group.rg_storage.name
  location            = azurerm_resource_group.rg_storage.location
}


resource "azurerm_network_interface" "fslogixvm_nic" {
  name                = "${var.prefix}-nic1"
  location            = var.avdLocation
  resource_group_name = azurerm_resource_group.rg_fslogix.name

  ip_configuration {
    name                          = "${var.prefix}-config1"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_windows_virtual_machine" "fslogixvm" {
  name                  = "${var.prefix}-vm"
  location              = var.avdLocation
  resource_group_name   = azurerm_resource_group.rg_fslogix.name
  network_interface_ids = [azurerm_network_interface.fslogixvm_nic.id]
  size                  = var.vm_size
  #admin_username = "${var.prefix}-admin"
  #admin_password = random_password.password.result
  admin_username = var.local_admin_username
  admin_password = var.local_admin_password
  computer_name  = "${var.prefix}-fslogixvm"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = "/subscriptions/${var.hub_subscription_id}/resourceGroups/${var.image_rg}/providers/Microsoft.Compute/galleries/${var.gallery_name}/images/${var.image_name}/versions/latest"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mi.id]
  }

  tags = {
    label = var.prefix
  }

  depends_on = [
    azurerm_network_interface.fslogixvm_nic
  ]
}

resource "azurerm_virtual_machine_extension" "domjoin" {
  name                 = "domainjoin"
  virtual_machine_id   = azurerm_windows_virtual_machine.fslogixvm.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  # What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain
  settings           = <<SETTINGS
    {
     "Name": "${var.domain_name}",
     "OUPath": "${var.ou_path}",
     "User": "${var.domain_name}\\${var.domain_admin_user}",
     "Restart": "true",
     "Options": "3"
    }
   SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
     {
     "Password": "${var.domain_admin_password}"
     }
   PROTECTED_SETTINGS
  depends_on = [
    azurerm_windows_virtual_machine.fslogixvm
  ]
}

resource "time_sleep" "sleep" {
  # Add sleep to wait for GPOs to apply after domain join
  depends_on = [
    azurerm_virtual_machine_extension.domjoin
  ]
  create_duration = "120s"
}

resource "azurerm_virtual_machine_extension" "this" {
  name                       = "${var.prefix}-fslogix_ad_join"
  virtual_machine_id         = azurerm_windows_virtual_machine.fslogixvm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
      {
        "fileUris": ["${var.file_url}"],
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ${var.file_name} -verbose -DscPath ${var.dsc_path} -StorageAccountName ${local.storage_name} -StorageAccountRG ${azurerm_resource_group.rg_storage.name} -DomainName ${var.domain_name} -IdentityServiceProvider ${var.id_provider} -AzureCloudEnvironment ${var.azure_cloud_environment} -SubscriptionId ${var.spoke_subscription_id} -DomainAdminUserName ${var.domain_admin_user}@${var.domain_name} -DomainAdminUserPassword ${var.domain_admin_password} -CustomOuPath ${var.custom_ou} -OUName ${var.ou_path} -CreateNewOU ${var.create_new_ou} -ShareName ${var.fslogix_sharename} -ClientId ${azurerm_user_assigned_identity.mi.id}" 
      }

    SETTINGS
  depends_on = [
    time_sleep.sleep,
    azurerm_virtual_machine_extension.domjoin
  ]
}