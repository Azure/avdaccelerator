locals {
  parametersWithoutPassword = format("%s %s %s '%s' %s '%s' %s '%s' %s '%s' %s '%s' %s '%s' %s %s %s '%s' %s '%s' %s '%s' %s '%s' %s %s %s '%s' %s %s", 
  "-DscPath", var.dsc_storage_path, 
  "-StorageAccountName", var.storage_account_name, 
  "-StorageAccountRG", var.storage_account_rg,
  "-SubscriptionId", var.workloadSubsId,
  "-ClientId", azurerm_user_assigned_identity.stguai.client_id,
  "-SecurityPrincipalName", var.security_principal_name,
  "-ShareName", var.fsshare,
  "-DomainName", var.domain_name,
  "-CustomOuPath", var.custom_ou_path,
  "-IdentityServiceProvider", var.IdentityServiceProvider,
  "-AzureCloudEnvironment", var.azure_cloud_environment,
  "-OUName", var.ou_name,
  "-AdminUserName", var.domain_user,
  "-StorageAccountFqdn", "${var.storage_account_name}.file.core.windows.net",
  "-StoragePurpose", "fslogix",
  "-TenantId", var.tenant_id
  )

  parameterPassword = format("%s \"%s\" ","-AdminUserPassword", var.domain_password)
  fullParameters = format("%s %s",local.parametersWithoutPassword,local.parameterPassword)
}

#15



output "scriptUrl" {
  value = var.baseScriptUri
}

output "file" {
  value = var.vfile
}

output "parametersWithoutPassword" {
    value = local.parametersWithoutPassword
}



#  commandToExecute="powershell.exe -ExecutionPolicy Unrestricted -File ${var.vfile} 
# -DscPath '${var.dsc_storage_path}' 
# -StorageAccountName '${var.storage_account_name}' 
# -StorageAccountRG '${var.storage_account_rg}' 
# -SubscriptionId '${var.workloadSubsId}' 
# -ClientId '${azurerm_user_assigned_identity.stguai.principal_id}' 
# -SecurityPrincipalName '${var.security_principal_name}' 
# -ShareName '${var.fsshare}' 
# -DomainName '${var.domain_name}' 
# -CustomOuPath '${var.custom_ou_path}' 
# -IdentityServiceProvider '${var.IdentityServiceProvider}' 
# -AzureCloudEnvironment '${var.azure_cloud_environment}' 
# -OUName '${var.ou_name}' 
# -AdminUserName '${var.domain_user}' 
# -AdminUserPassword '${var.domain_password}' 
# -StorageAccountFqdn '${var.storage_account_name}.file.core.windows.net' 
# -StoragePurpose 'fslogix' 
# -verbose"
#  