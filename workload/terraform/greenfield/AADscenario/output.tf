output "azurerm_virtual_desktop_application_group" {
  description = "Name of the Azure Virtual Desktop DAG"
  value       = module.avm_res_desktopvirtualization_applicationgroup.resource
}

output "azurerm_virtual_desktop_host_pool" {
  description = "Name of the Azure Virtual Desktop host pool"
  value       = module.avm_res_desktopvirtualization_hostpool.resource
}

output "azurerm_virtual_desktop_workspace" {
  description = "Name of the Azure Virtual Desktop workspace"
  value       = module.avm_res_desktopvirtualization_workspace.resource
}

output "resource" {
  description = "This output is the full output for the resource to allow flexibility to reference all possible values for the resource. Example usage: module.<modulename>.resource.id"
  value       = azurerm_resource_group.this
}

output "session_host_count" {
  description = "The number of VMs created"
  value       = var.rdsh_count
}

output "dnsservers" {
  description = "Custom DNS configuration"
  value       = data.azurerm_virtual_network.vnet.dns_servers
}

output "vnetrange" {
  description = "Address range for deployment vnet"
  value       = data.azurerm_virtual_network.vnet.address_space
}

output "AVD_user_groupname" {
  description = "Microsoft Entra ID Group for AVD users"
  value       = data.azuread_group.adds_group.display_name
}
