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

variable "vnet" {
  type        = string
  description = "Name of avd vnet"
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