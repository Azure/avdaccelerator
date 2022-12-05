variable "avdLocation" {
  description = "Location of the resource group."
}

variable "rg_stor" {
  type        = string
  description = "Name of the Resource group in which to deploy storage"
}

variable "rg_network" {
  type        = string
  description = "Name of the Resource group in which to deploy network resources"
}

variable "rg_fslogix" {
  type        = string
  description = "Name of the Resource group in which to deploy fslogix resources"
}


variable "vnet" {
  type        = string
  description = "Name of avd vnet"
}

variable "snet" {
  type        = string
  description = "Name of avd snet"
}

variable "pesnet" {
  type        = string
  description = "Name of subnet"
}

variable "aad_group_name" {
  type        = string
  description = "Name of the AAD group to be used for the storage account"
}
variable "prefix" {
  type        = string
  description = "Prefix of the name under 5 characters"
}

variable "hub_subscription_id" {
  type        = string
  description = "Hub Subscription id"
}
variable "spoke_subscription_id" {
  type        = string
  description = "Spoke Subscription id"
}
variable "subnet_range" {
  type        = list(string)
  description = "Address range for session host subnet"
}

variable "pesubnet_range" {
  type        = list(string)
  description = "Address range for private endpoints subnet"
}

variable "nsg" {
  type        = string
  description = "Name of the nsg"
}
variable "rt" {
  type        = string
  description = "Name of the route table"
}
variable "vnet_range" {
  type        = list(string)
  description = "Address range for deployment VNet"
}
variable "ad_rg" {
  type        = string
  description = "The resource group for AD VM"
}
variable "ad_vnet" {
  type        = string
  description = "Name of domain controller vnet"
}