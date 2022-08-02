variable "avdLocation" {
  description = "Location of the resource group."
}

variable "rg" {
  type        = string
  description = "Name of the Resource group in which to deploy session host"
}

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

variable "ad_vnet" {
  type        = string
  description = "Name of domain controller vnet"
}

variable "rfc3339" {
  type        = string
  description = "Registration token expiration"
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
  description = "Prefix of the name of the AVD machine(s)"
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
  
variable "gallery_name"{
  type       = string
  description = "Name of the shared image gallery name"
}

variable "image_rg" {
  type        = string
  description = "Image Gallery resource group"
}
  