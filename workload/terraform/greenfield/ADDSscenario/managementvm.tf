module "management_vm" {
  source = "../../modules/mgmtvm"

  location       = var.avdLocation
  workloadSubsId = var.spoke_subscription_id
  tenant_id      = data.azurerm_client_config.current.tenant_id


  domain_name            = var.domain_name
  domain_user            = var.domain_user
  domain_password        = var.domain_password
  domainJoinUserPassword = var.domain_password


  local_admin_username = var.local_admin_username
  local_admin_password = azurerm_key_vault_secret.localpassword_mgmtvm.value

  avdLocation = var.avdLocation
  rg_so       = var.rg_so
  rg_stor     = var.rg_stor
  rg_network  = module.network.rg_name

  prefix = var.prefix

  vnet_name   = module.network.vnet_name
  subnet_name = module.network.subnet_name


  spoke_subscription_id   = var.spoke_subscription_id
  fsshare                 = azurerm_storage_share.FSShare.name
  storage_account_name    = azurerm_storage_account.storage.name
  storage_account_rg      = azurerm_resource_group.rg_storage.name
  IdentityServiceProvider = "ADDS"



  # url_powershell_script   = "https://raw.githubusercontent.com/sihbher/avdaccelerator/main/workload/scripts/Manual-DSC-Storage-Scripts.ps1"
  # vfile = "Manual-DSC-Storage-Scripts.ps1"

  localpath_powershell_script = "../../../scripts/Manual-DSC-Storage-Scripts.ps1"
  dsc_storage_path            = "https://github.com/sihbher/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts-02.zip"

  security_principal_name = var.aad_group_name
  ou_name                 = "AvdComputers"
  custom_ou_path          = var.ou_path


  vm_size = "Standard_B2ms"
  vm_source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk-g2"
    vm_size   = "Standard_B2ms"
    version   = "latest"
  }

  log_analytics_workspace = {
    workspace_id  = data.azurerm_log_analytics_workspace.lawksp.id
    workspace_key = data.azurerm_log_analytics_workspace.lawksp.primary_shared_key
  }



  depends_on = [
    module.network,
    azurerm_resource_group.rg,
    azurerm_resource_group.shrg,
    azurerm_storage_account.storage
  ]

}
