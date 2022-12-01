variable "avdLocation" {
  description = "Location of the resource group."
}
variable "rg_network" {
  type        = string
  description = "Name of the Resource group in which to deploy network resources"
}

variable "vnet" {
  type        = string
  description = "Name of avd vnet"
}

variable "snet" {
  type        = string
  description = "Name of subnet"
}

variable "prefix" {
  type        = string
  description = "Prefix of the name of the AVD machine(s)"
}