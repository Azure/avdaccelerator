resource "azurerm_resource_group" "res-0" {
  location = var.region
  name     = "rg-avd-${substr(var.region, 0, 5)}-gm"
}

resource "azurerm_virtual_machine_extension" "res-2" {
  auto_upgrade_minor_version = true
  name                       = "MDE.Windows"
  publisher                  = "Microsoft.Azure.AzureDefenderForServers"
  settings                   = "{\"azureResourceId\":\"/subscriptions/${var.spoke_subscription_id}/resourceGroups/RG-AVD-GM/providers/Microsoft.Compute/virtualMachines/vm-gmdev\",\"forceReOnboarding\":false,\"vNextEnabled\":false}"
  type                       = "MDE.Windows"
  type_handler_version       = "1.0"
  virtual_machine_id         = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/azurerm_resource_group.res-0.name/providers/Microsoft.Compute/virtualMachines/vm-gmdev"
  depends_on = [
    azurerm_windows_virtual_machine.res-5,
  ]
}
resource "azurerm_virtual_machine_extension" "res-1" {
  auto_upgrade_minor_version = true
  name                       = "MicrosoftMonitoringAgent"
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  settings                   = "{\"workspaceId\":\"964921b9-94c7-4d0c-8274-00f2708aca36\"}"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  virtual_machine_id         = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/azurerm_resource_group.res-0.name/providers/Microsoft.Compute/virtualMachines/vm-gmdev"
  depends_on = [
    azurerm_windows_virtual_machine.res-5,
  ]
}


resource "azurerm_managed_disk" "res-4" {
  create_option        = "FromImage"
  image_reference_id   = "/Subscriptions/${var.spoke_subscription_id}/Providers/Microsoft.Compute/Locations/southcentralus/Publishers/microsoft-azure-gaming/ArtifactTypes/VMImage/Offers/game-dev-vm/Skus/win11_unreal_5_0/Versions/1.0.62"
  location             = var.region
  name                 = "vm-gmdev_lun_0_2_afed48d7a46d4d2287ae25ead2e6ff98"
  resource_group_name  = azurerm_resource_group.res-0.name
  storage_account_type = "Premium_LRS"
  tags = {
    engine         = "ue_5_0"
    ostype         = "win11"
    remotesoftware = "RDP"
    solution       = "Game Development Virtual Machine"
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_windows_virtual_machine" "res-5" {
  admin_password        = "ChangeMe123!"
  admin_username        = "localadmin"
  location              = var.region
  name                  = "vm-gmdev"
  network_interface_ids = ["/subscriptions/${var.spoke_subscription_id}/resourceGroups/azurerm_resource_group.res-0.name/providers/Microsoft.Network/networkInterfaces/vm-gmdev-nic"]
  resource_group_name   = azurerm_resource_group.res-0.name
  size                  = "Standard_NC4as_T4_v3"
  tags = {
    engine         = "ue_5_0"
    ostype         = "win11"
    remotesoftware = "RDP"
    solution       = "Game Development Virtual Machine"
  }
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  plan {
    name      = "win11_unreal_5_0"
    product   = "game-dev-vm"
    publisher = "microsoft-azure-gaming"
  }
  source_image_reference {
    offer     = "game-dev-vm"
    publisher = "microsoft-azure-gaming"
    sku       = "win11_unreal_5_0"
    version   = "1.0.62"
  }
  depends_on = [
    azurerm_network_interface.res-14,
  ]
}
resource "azurerm_virtual_machine_data_disk_attachment" "res-6" {
  caching            = "ReadOnly"
  create_option      = "Attach"
  lun                = 0
  managed_disk_id    = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.Compute/disks/vm-gmdev_lun_0_2_afed48d7a46d4d2287ae25ead2e6ff98"
  virtual_machine_id = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.Compute/virtualMachines/vm-gmdev"
  depends_on = [
    azurerm_managed_disk.res-4,
    azurerm_windows_virtual_machine.res-5,
  ]
}
resource "azurerm_virtual_machine_extension" "res-7" {
  auto_upgrade_minor_version = true
  name                       = "AADLoginForWindows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  virtual_machine_id         = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.Compute/virtualMachines/vm-gmdev"
  depends_on = [
    azurerm_windows_virtual_machine.res-5,
  ]
}
resource "azurerm_virtual_machine_extension" "res-8" {
  auto_upgrade_minor_version = true
  name                       = "GDVMCustomization"
  publisher                  = "Microsoft.Compute"
  settings                   = "{\"fileUris\":[\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Controller-Initialization.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Task-CompleteUESetup.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Task-ConfigureLoginScripts.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Task-CreateDataDisk.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Task-MountFileShare.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Task-SyncP4Depot.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Task-SetupIncredibuild.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Task-AvdRegistration.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Task-RegisterTeradici.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/Task-SetupParsec.ps1\",\"https://catalogartifact.azureedge.net/publicartifacts/microsoft-azure-gaming.azure-gamedev-vm-22e9a75e-a70c-4cdb-a26e-d477a9e73c71-gamedev-vm/Artifacts/PreInstall.zip\"]}"
  type                       = "CustomScriptExtension"
  type_handler_version       = "2.0"
  virtual_machine_id         = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.Compute/virtualMachines/vm-gmdev"
  depends_on = [
    azurerm_windows_virtual_machine.res-5,
  ]
}
resource "azurerm_virtual_desktop_application_group" "res-9" {
  default_desktop_display_name = "SessionDesktop"
  description                  = "Desktop Application Group created through the Hostpool Wizard"
  friendly_name                = "Default Desktop"
  host_pool_id                 = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.DesktopVirtualization/hostPools/vdpool-gm"
  location                     = var.region
  name                         = "vdpool-gm-DAG"
  resource_group_name          = azurerm_resource_group.res-0.name
  tags = {
    cm-resource-parent = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.DesktopVirtualization/vdpool-gm"
  }
  type = "Desktop"
  depends_on = [
    azurerm_virtual_desktop_host_pool.res-10,
  ]
}
resource "azurerm_virtual_desktop_host_pool" "res-10" {
  custom_rdp_properties    = "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:0;enablerdsaadauth:i:1;autoreconnection enabled:i:1;targetisaadjoined:i:1;"
  description              = "Created through the Azure Virtual Desktop extension"
  load_balancer_type       = "BreadthFirst"
  location                 = var.region
  maximum_sessions_allowed = 5
  name                     = "vdpool-gm"
  resource_group_name      = azurerm_resource_group.res-0.name
  type                     = "Pooled"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_virtual_desktop_workspace" "res-11" {
  friendly_name       = "GPU"
  location            = "northcentralus"
  name                = "ws-gmd"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = {
    cm-resource-parent = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.DesktopVirtualization/vdpool-gm"
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_virtual_desktop_workspace_application_group_association" "res-12" {
  application_group_id = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.DesktopVirtualization/applicationGroups/vdpool-gm-DAG"
  workspace_id         = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.DesktopVirtualization/workspaces/ws-gmd"
  depends_on = [
    azurerm_virtual_desktop_application_group.res-9,
    azurerm_virtual_desktop_workspace.res-11,
  ]
}

resource "azurerm_network_interface" "res-14" {
  enable_accelerated_networking = true
  location                      = var.region
  name                          = "vm-gmdev-nic"
  resource_group_name           = azurerm_resource_group.res-0.name
  ip_configuration {
    name                          = "vm-gmdev-ipconf"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.Network/virtualNetworks/vm-gmdev-vnet/subnets/gamedevvms"
  }
  depends_on = [
    azurerm_subnet.res-22,
  ]
}
resource "azurerm_network_interface_security_group_association" "res-15" {
  network_interface_id      = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.Network/networkInterfaces/vm-gmdev-nic"
  network_security_group_id = "/subscriptions/${var.spoke_subscription_id}/resourceGroups/rg-avd-gm/providers/Microsoft.Network/networkSecurityGroups/vm-gmdev-nsg"
  depends_on = [
    azurerm_network_interface.res-14,
    azurerm_network_security_group.res-16,
  ]
}
resource "azurerm_network_security_group" "res-16" {
  location            = var.region
  name                = "vm-gmdev-nsg"
  resource_group_name = azurerm_resource_group.res-0.name
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_network_security_rule" "res-17" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "80"
  direction                   = "Inbound"
  name                        = "PixelStream"
  network_security_group_name = "vm-gmdev-nsg"
  priority                    = 1020
  protocol                    = "*"
  resource_group_name         = azurerm_resource_group.res-0.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-16,
  ]
}
resource "azurerm_network_security_rule" "res-18" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  direction                   = "Inbound"
  name                        = "RDP"
  network_security_group_name = "vm-gmdev-nsg"
  priority                    = 1010
  protocol                    = "*"
  resource_group_name         = azurerm_resource_group.res-0.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-16,
  ]
}
resource "azurerm_public_ip" "res-19" {
  allocation_method   = "Static"
  location            = var.region
  name                = "vm-gmdev-vnet-ip"
  resource_group_name = azurerm_resource_group.res-0.name
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_virtual_network" "res-20" {
  address_space       = ["10.1.0.0/24"]
  location            = var.region
  name                = "vm-gmdev-vnet"
  resource_group_name = azurerm_resource_group.res-0.name
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

resource "azurerm_subnet" "res-22" {
  address_prefixes     = ["10.1.0.0/26"]
  name                 = "gamedevvms"
  resource_group_name  = azurerm_resource_group.res-0.name
  virtual_network_name = "vm-gmdev-vnet"
  depends_on = [
    azurerm_virtual_network.res-20,
  ]
}
