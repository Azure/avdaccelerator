locals {

  #These are the parameters that will be passed to the script, without the password
  parametersWithoutPassword = format("-DscPath %s -StorageAccountName %s -StorageAccountRG %s -SubscriptionId %s -ClientId %s -SecurityPrincipalName %s -ShareName %s -DomainName %s -CustomOuPath \"%s\" -IdentityServiceProvider %s -AzureCloudEnvironment %s -OUName %s -AdminUserName %s -StorageAccountFqdn \"%s\" -StoragePurpose %s -TenantId %s",
    var.dsc_storage_path,
    var.storage_account_name,
    var.storage_account_rg,
    var.workloadSubsId,
    azurerm_user_assigned_identity.stguai.client_id,
    var.security_principal_name,
    var.fsshare,
    var.domain_name,
    var.custom_ou_path,
    var.IdentityServiceProvider,
    var.azure_cloud_environment,
    var.ou_name,
    var.domain_user,
    "${var.storage_account_name}.file.core.windows.net",
    "fslogix",
    var.tenant_id
  )

  #This is the parameter that will be passed to the script, with the password
  parameterPassword = format("%s \"%s\" ", "-AdminUserPassword", var.domain_password)

  #This is the full parameter list
  fullParameters    = format("%s %s", local.parametersWithoutPassword, local.parameterPassword)


  #This is the command to execute when the script is downloaded from an url
  commandToExecute_UrlFile = "powershell.exe -ExecutionPolicy Unrestricted -File ${var.vfile} ${local.fullParameters} -verbose"


  #If the script is provided locally, we need to encode it in base64 to be able to pass it to the VM
  powershell_filename        = var.vfile
  powershell_script_rendered = filebase64(var.localpath_powershell_script)
  commandToExecute_LocalFile = "powershell.exe -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${local.powershell_script_rendered}')) | Out-File -filepath ${local.powershell_filename}\" && powershell -ExecutionPolicy Unrestricted -File ${local.powershell_filename} ${local.fullParameters} -verbose"
}