variable "dsc_storage_path" {
  type        = string
  description = "Path to the DSC script"
  default     = "https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts.zip"
}

variable "workloadSubsId" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "deployment_environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}

variable "azure_cloud_environment" {
  type        = string
  description = "Azure Cloud Environment"
  default     = "AzureCloud"

  validation {
    condition     = contains(["AzureCloud", "AzureChinaCloud", "AzureGermanCloud", "AzureUSGovernment"], var.azure_cloud_environment)
    error_message = "value must be one of AzureCloud, AzureChinaCloud, AzureGermanCloud, AzureUSGovernment"
  }
}

variable "vm_source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "VM Source Image Reference"
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk-g2"
    version   = "latest"
  }
}

variable "domain_name" {
  type        = string
  description = "Name of the domain to join"
}

variable "domain_user" {
  type        = string
  description = "Username for domain join (do not include domain name as this is appended)"
}

variable "domain_password" {
  type        = string
  description = "Password of the user to authenticate with the domain"
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the machine to deploy"
}

variable "ou_name" {
  description = "Distinguished name of the organizational unit for the session host. OU where computer account objects for Azure storage accounts will be created. Example: 'AvdComputers'"
  default     = "Computers"
}

variable "custom_ou_path" {
  description = "Distinguished name of the CUSTOM organizational unit for the session host"
}

variable "local_admin_username" {
  type        = string
  description = "local admin username"
}

variable "avdLocation" {
  type        = string
  description = "Location of the AVD deployment"
}
variable "rg_so" {
  type        = string
  description = "Name of the Resource group in which to deploy service objects"
}

variable "rg_stor" {
  type        = string
  description = "Name of the Resource group in which to deploy storage"
}

variable "prefix" {
  type        = string
  description = "Prefix for all resources"
}


variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet"
}

variable "rg_network" {
  type        = string
  description = "Name of the network resource group"
}

variable "localpassword" {
  type        = string
  description = "Local admin password"
  sensitive   = true
}

variable "spoke_subscription_id" {
  type        = string
  description = "Subscription ID of the spoke"
}

variable "fsshare" {
  type        = string
  description = "Name of the FSLogix share"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the storage account"
}

variable "storage_account_rg" {
  type        = string
  description = "Name of the storage account resource group"
}

variable "IdentityServiceProvider" {
  type        = string
  description = "Identity Service Provider"
}

variable "location" {
  type        = string
  description = "Location where to deploy compute services."
}

#Url where the script to be ran is located
variable "url_powershell_script" {
  type        = string
  description = "Location of the powershell script for configuring fslogix."
  default = ""
}

variable "localpath_powershell_script" {
  type        = string
  description = "Content of the Powershell script for configuring fslogix. Only one of url_powershell_script/content_powershell_script is required."
  default = "../../../scripts/Manual-DSC-Storage-Scripts.ps1"
}

#Name of the file to be downloaded from the url. Defualt value is: Manual-DSC-Storage-Scripts.ps1. It is required if url_powershell_script is provided
#It is also used as the name of the local file if localpath_powershell_script is provided, but is not required
variable "vfile" {
  type = string
  description = "Name of the file to be downloaded from the url. Defualt value is: Manual-DSC-Storage-Scripts.ps1. It is required if url_powershell_script is provided. It is also used as the name of the local file if localpath_powershell_script is provided, but is not required"
  default = "Manual-DSC-Storage-Scripts.ps1"
}


variable "domainJoinUserPassword" {
  type        = string
  description = "Domain join user password."
}

variable "security_principal_name" {
  type        = string
  description = "Name of the security principal"
}

variable "log_analytics_workspace" {
  type = object({
    workspace_id       = string
    workspace_key = string

  })
  description = "Log Analytics Workspace Details"
  default     = null
}
