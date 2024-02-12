
#Location of the powershell script to be executed for configuring FSLogix. It depends on the source of the script, if local file path or url was provided
output "scriptUrl" {
  value = coalesce(var.url_powershell_script, var.localpath_powershell_script, "Not provided")
}

#Name of the script file that will be downloaded 
output "file" {
  value = var.vfile
}

#Command to execute for Custom Script Extension for configuring FSLogix. It depends on the source of the script, if local file path or url was provided
output "commandToExecute" {
  value = var.url_powershell_script != "" ? local.commandToExecute_UrlFile : local.commandToExecute_LocalFile
}

#Parameters to pass to the script, without the password
output "parametersWithoutPassword" {
  value = local.parametersWithoutPassword
}