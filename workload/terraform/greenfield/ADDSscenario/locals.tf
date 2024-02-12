locals {
  keyvault_name      = lower("kv-avd-${substr(var.avdLocation, 0, 5)}-${var.prefix}-${random_string.random.id}")
  storage_name       = lower(replace("stavd${var.prefix}${random_string.random.id}", "-", ""))
  allow_list_ip      = var.allow_list_ip
  white_list_ip      = ["0.0.0.0"]
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
  tags = {
    environment        = var.prefix
    source             = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
    cm-resource-parent = azurerm_virtual_desktop_host_pool.hostpool.id
  }

  #Variables for the script that configures FSLogix on the Session Hosts
  storage_fqdn                   = "${local.storage_name}.file.core.windows.net"
  fslogix_fileshare              = "\\\\${local.storage_fqdn}\\fslogix"
  setSessionHostConfigurationUrl = "https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Set-SessionHostConfiguration.ps1"

  #These are the parameters that will be passed to the script, without the password
  parameters = format("-IdentityDomainName %s -AmdVmSize %s -IdentityServiceProvider %s -Fslogix %s -FslogixFileShare %s -fslogixStorageFqdn %s -HostPoolRegistrationToken %s -NvidiaVmSize %s",
    var.domain_name,
    "false",
    "ADDS",
    "true",
    local.fslogix_fileshare,
    local.storage_fqdn,
    local.registration_token,
    "false"
  )

  setSessionHost_fileName  = "Set-SessionHostConfiguration.ps1"
  commandToExecute_UrlFile = "powershell.exe -ExecutionPolicy Unrestricted -File ${local.setSessionHost_fileName} ${local.parameters} -verbose"
}
