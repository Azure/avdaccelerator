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

variable "identity_rg" {
  type        = string
  description = "Name of the Resource group in which to identity resources are deployed"
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

variable "identity_vnet" {
  type        = string
  description = "Name of the vnet in which to identity resources are deployed"
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

variable "hub_vnet" {
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

variable "hub_connectivity_rg" {
  type        = string
  description = "The resource group for hub connectivity resources"
}

variable "aad_group_name" {
  type        = string
  description = "Microsoft Entra ID Group for AVD users"
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

variable "vm_size" {
  description = "Size of the machine to deploy"
}

variable "local_admin_username" {
  type        = string
  description = "local admin username"
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

variable "identity_subscription_id" {
  type        = string
  description = "identity Subscription id"
}

variable "enable_disk_encryption" {
  type        = bool
  description = "Enable disk encryption"
  default     = true
}
variable "avdshared_subscription_id" {
  type        = string
  description = "Spoke Subscription id"
}

variable "host_pool_log_categories" {
  description = "value of the log categories to be enabled for the host pool"
}

variable "dag_log_categories" {
  description = "value of the log categories to be enabled for the host pool"
}

variable "ws_log_categories" {
  description = "value of the log categories to be enabled for the host pool"
}


variable "hub_dns_zone_rg" {
  description = "The resource group for the hub DNS zone"
}

variable "next_hop_ip" {
  type        = string
  description = "Next hop IP address"
}

variable "fw_policy" {
  type        = string
  description = "Name of the firewall policy"
}

variable "disk_encryption_key_set_id" {
  type    = string
  default = null
}

variable "publisher" {
  type        = string
  description = "Publisher of the image"
}
variable "offer" {
  type        = string
  description = "Offer of the image"
}

variable "sku" {
  type        = string
  description = "SKU of the image"
}
