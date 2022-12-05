variable "avdLocation" {
  description = "Location of the resource group."
}
# Resource Groups
variable "rg_so" {
  type        = string
  description = "Name of the Resource group in which to deploy service objects"
}

variable "rg_stor" {
  type        = string
  description = "Name of the Resource group in which to deploy storage"
}

variable "rg_network" {
  type        = string
  description = "Name of the Resource group in which to deploy network resources"
}

variable "rg_pool" {
  description = "Resource group AVD machines will be deployed to"
}

variable "rg_avdi" {
  type        = string
  description = "Name of the Resource group in which to deploy avd service objects"
}


variable "rg_fslogix" {
  description = "Resource group FSLogix VM"
}

variable "vnet" {
  type        = string
  description = "Name of avd vnet"
}

variable "snet" {
  type        = string
  description = "Name of subnet"
}

variable "pesnet" {
  type        = string
  description = "Name of subnet"
}

variable "nsg" {
  type        = string
  description = "Name of the nsg"
}

variable "rt" {
  type        = string
  description = "Name of the route table"
}

variable "dag" {
  type        = string
  description = "Name of the Azure Virtual Desktop desktop application group"
}

variable "rag" {
  type        = string
  description = "Name of the Azure Virtual Desktop remote application group"
}

variable "pag" {
  type        = string
  description = "Name of the Azure Virtual Desktop remote application group"
}

variable "raghostpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop remote app group"
}

variable "scplan" {
  type        = string
  description = "Name of the session host scaling plan"
}

variable "rg_shared_name" {
  type        = string
  description = "Name of the Resource group in which to deploy shared resources"
}

variable "rg_image_name" {
  type        = string
  description = "Name of the Resource group in which to deploy image resources"
}

variable "workspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop workspace"
}

variable "pworkspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop Personal workspace"
}

variable "hostpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop host pool"
}

variable "personalpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop host pool"
}

variable "ragworkspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop workspace"
}

variable "ad_vnet" {
  type        = string
  description = "Name of domain controller vnet"
}

variable "dns_servers" {
  type        = list(string)
  description = "Custom DNS configuration"
}

variable "vnet_range" {
  type        = list(string)
  description = "Address range for deployment VNet"
}
variable "subnet_range" {
  type        = list(string)
  description = "Address range for session host subnet"
}

variable "pesubnet_range" {
  type        = list(string)
  description = "Address range for private endpoints subnet"
}

variable "ad_rg" {
  type        = string
  description = "The resource group for AD VM"
}

variable "avd_users" {
  description = "AVD users"
}

variable "aad_group_name" {
  type        = string
  description = "Azure Active Directory Group for AVD users"
}

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
}

variable "prefix" {
  type        = string
  description = "Prefix of the name under 5 characters"
  validation {
    condition     = length(var.prefix) < 5 && lower(var.prefix) == var.prefix
    error_message = "The prefix value must be lowercase and < 4 chars."
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

variable "ou_path" {
  description = "Distinguished name of the organizational unit for the session host"
}

variable "local_admin_username" {
  type        = string
  description = "local admin username"
}

variable "local_admin_password" {
  type        = string
  description = "local admin password"
  sensitive   = true
}

variable "image_name" {
  type        = string
  description = "Name of the custome image to use"
}

variable "gallery_name" {
  type        = string
  description = "Name of the shared image gallery name"
}

variable "image_rg" {
  type        = string
  description = "Image Gallery resource group"
}

# Create a storage allow list of IP Addresses
variable "allow_list_ip" {
  type        = list(string)
  description = "List of allowed IP Addresses"
}

variable "hub_subscription_id" {
  type        = string
  description = "Hub Subscription id"
}

variable "spoke_subscription_id" {
  type        = string
  description = "Spoke Subscription id"
}


variable "file_name" {
  description = "The name of the PowerShell script that the CustomScriptExtention runs"
}

variable "file_url" {
  description = "The URL for the file_name"
}

variable "dsc_path" {
  description = "Path to download the dsc script from"
}

variable "id_provider" {
  description = "The Identity Provider for FsLogix."
  validation {
    condition     = contains(["ADDS", "AAD, AADDS"], var.id_provider)
    error_message = "Valid values are ADDS, AAD or AADDS."
  }
}

variable "azure_cloud_environment" {
  description = "The Azure Cloud Environment"
  validation {
    condition     = contains(["AzureCloud", "AzureGovCloud"], var.azure_cloud_environment)
    error_message = "Valid values are AzureCloud or AzureGovCloud."
  }
}

variable "domain_admin_user" {
  description = "The name of the user to join the FSLogix Storage Account to the domain. Format: User@domain.TLD"
}

variable "domain_admin_password" {
  description = "The password of the user to join the FsLogix Storage Account to the domain. "
}

variable "custom_ou" {
  description = "If false, the storage account will be joined to the default computer OU"
  default     = "true"
  validation {
    condition     = contains(["true", "false"], var.custom_ou)
    error_message = "Valid values: true or false."

  }
}

variable "create_new_ou" {
  description = "If true, the OU in the OU_name variable will be created"
  default     = "false"
  validation {
    condition     = contains(["true", "false"], var.create_new_ou)
    error_message = "Valid values: true or false."
  }

}

variable "fslogix_sharename" {
  description = "The name of the FsLogix File share name"
}