# Create a storage allow list of IP Addresses
variable "allow_list_ip" {
  type        = list(string)
  description = "List of allowed IP Addresses"
}

variable "avdLocation" {
  description = "Location of the resource group."
}

variable "avdshared_subscription_id" {
  type        = string
  description = "Spoke Subscription id"
}

variable "dag" {
  type        = string
  description = "Name of the Azure Virtual Desktop desktop application group"
}

variable "dns_servers" {
  type        = list(string)
  description = "Custom DNS configuration"
}

variable "domain_guid" {
  type        = string
  description = "Domain GUID"
}

variable "domain_name" {
  type        = string
  description = "Name of the domain to join"
}

variable "domain_sid" {
  type        = string
  description = "Domain SID"
}

variable "domain_user" {
  type        = string
  description = "Username for domain join (do not include domain name as this is appended)"
}

variable "environment" {
  type        = string
  description = "Environment name sets the type of environment (Development (dev), Test (test), Production (prod)) that will be deployed, this information will be use as part of the resources naming."
}

variable "fw_policy" {
  type        = string
  description = "Name of the firewall policy"
}

variable "hostpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop host pool"
}

variable "hub_connectivity_rg" {
  type        = string
  description = "The resource group for hub connectivity resources"
}

variable "hub_dns_zone_rg" {
  description = "The resource group for the hub DNS zone"
}

variable "hub_subscription_id" {
  type        = string
  description = "Hub Subscription id"
}

variable "hub_vnet" {
  type        = string
  description = "Name of domain controller vnet"
}

variable "identity_rg" {
  type        = string
  description = "Name of the Resource group in which to identity resources are deployed"
}

variable "identity_subscription_id" {
  type        = string
  description = "identity Subscription id"
}

variable "identity_vnet" {
  type        = string
  description = "Name of the vnet in which to identity resources are deployed"
}

variable "local_admin_username" {
  type        = string
  description = "local admin username"
}

variable "netbios_domain_name" {
  type        = string
  description = "Netbios domain name"
}

# variables for firewall policy 
variable "next_hop_ip" {
  type        = string
  description = "Next hop IP address"
}

variable "nsg" {
  type        = string
  description = "Name of the nsg"
}

variable "offer" {
  type        = string
  description = "Offer of the image"
}

variable "ou_path" {
  description = "Distinguished name of the organizational unit for the session host"
}

variable "pag" {
  type        = string
  description = "Name of the Azure Virtual Desktop remote application group"
}

variable "personalpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop host pool"
}

variable "pesnet" {
  type        = string
  description = "Name of subnet"
}

variable "pesubnet_range" {
  type        = list(string)
  description = "Address range for private endpoints subnet"
}

variable "prefix" {
  type        = string
  description = "Prefix of the name under 5 characters"

  validation {
    condition     = length(var.prefix) < 5 && lower(var.prefix) == var.prefix
    error_message = "The prefix value must be lowercase and < 4 chars."
  }
}

variable "publisher" {
  type        = string
  description = "Publisher of the image"
}

variable "pworkspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop Personal workspace"
}

variable "rag" {
  type        = string
  description = "Name of the Azure Virtual Desktop remote application group"
}

variable "raghostpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop remote app group"
}

variable "ragworkspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop workspace"
}

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
}

variable "rg_avdi" {
  type        = string
  description = "Name of the Resource group in which to deploy avd service objects"
}

variable "rg_network" {
  type        = string
  description = "Name of the Resource group in which to deploy network resources"
}

variable "rg_pool" {
  description = "Resource group AVD machines will be deployed to"
}

variable "rg_shared_name" {
  type        = string
  description = "Name of the Resource group in which to deploy shared resources"
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

variable "rt" {
  type        = string
  description = "Name of the route table"
}

variable "scplan" {
  type        = string
  description = "Name of the session host scaling plan"
}

variable "sku" {
  type        = string
  description = "SKU of the image"
}

variable "snet" {
  type        = string
  description = "Name of subnet"
}

variable "spoke_subscription_id" {
  type        = string
  description = "Spoke Subscription id"
}

variable "subnet_range" {
  type        = list(string)
  description = "Address range for session host subnet"
}

variable "user_group_name" {
  type        = string
  description = "Microsoft Entra ID Group for AVD users"
}

variable "vm_size" {
  description = "Size of the machine to deploy"
}

variable "vnet" {
  type        = string
  description = "Name of avd vnet"
}

variable "vnet_range" {
  type        = list(string)
  description = "Address range for deployment VNet"
}

variable "workspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop workspace"
}

variable "domain_password" {
  type        = string
  default     = "ChangeMe123$"
  description = "Password of the user to authenticate with the domain"
  sensitive   = true
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetry.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
