provider "azurerm" {
  features {}
}

##Create AVD Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "time_rotating" "avd_token" {
  rotation_days = 30
}

#Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "WS" {
  name                = var.workspace
  resource_group_name = var.rg_name
  location            = var.location
  friendly_name       = "AVD Workspace"
  description         = "AVD Workspace"
}

# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "HP" {
  resource_group_name      = var.rg_name
  location                 = var.location
  name                     = var.host_pool
  friendly_name            = var.host_pool
  validate_environment     = true
  start_vm_on_connect      = true
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
  description              = "AVD-HP Terraform"
  type                     = "Pooled"
  maximum_sessions_allowed = 16
  load_balancer_type       = "DepthFirst" #[BreadthFirst DepthFirst]


  registration_info {
    expiration_date = time_rotating.avd_token.rotation_rfc3339
  }
}

# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "dag" {
  resource_group_name = azurerm_resource_group.rg.name
  host_pool_id        = azurerm_virtual_desktop_host_pool.HP.id
  location            = azurerm_resource_group.rg.location
  type                = "Desktop"
  name                = "DAG"
  friendly_name       = "AppGroup"
  description         = "AVD application group"
  depends_on          = [azurerm_virtual_desktop_host_pool.HP]
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.WS.id
}

#Enable Log Analytics
resource "azurerm_resource_group" "log" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "lawksp" {
  name                = "log${random_string.random.id}"
  location            = azurerm_resource_group.log.location
  resource_group_name = azurerm_resource_group.log.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
resource "azurerm_monitor_diagnostic_setting" "avd-hp" {
  name                       = "AVD-Diag"
  target_resource_id         = azurerm_virtual_desktop_host_pool.HP.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.lawksp.id

  log {
    category = "AgentHealthStatus"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Checkpoint"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Connection"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Error"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "HostRegistration"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }
  log {
    category = "Management"
    enabled  = true

    retention_policy {
      days    = 7
      enabled = true
    }
  }

}

# Session Host
locals {
  registration_token = azurerm_virtual_desktop_host_pool.HP.registration_info[0].token
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
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.rdsh_count
  name                  = "${var.prefix}-${count.index + 1}"
  resource_group_name   = var.rg_name
  location              = var.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.local_admin_username
  admin_password        = var.local_admin_password

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
  }

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_network_interface.avd_vm_nic
  ]
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}-${count.index + 1}-domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "${var.domain_name}",
      "OUPath": "${var.ou_path}",
      "User": "${var.domain_user_upn}@${var.domain_name}",
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

  depends_on = [
    azurerm_virtual_network_peering.peer1,
    azurerm_virtual_network_peering.peer2
  ]
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
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_3-10-2021.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.HP.name}"
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
    azurerm_virtual_machine_extension.domain_join,
    azurerm_virtual_desktop_host_pool.HP
  ]
}