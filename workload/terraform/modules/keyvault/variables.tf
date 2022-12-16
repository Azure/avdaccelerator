variable "rg_so" {
  type        = string
  description = "Name of the Resource group in which to deploy service objects"
}

variable "rg_network" {
  type        = string
  description = "Name of the Resource group in which to deploy network objects"
}

variable "avdLocation" {
  description = "Location of the resource group."
}
variable "prefix" {
  type        = string
  description = "Prefix of the name of the AVD machine(s)"
}
variable "vnet" {
  type        = string
  description = "Name of avd vnet"
}

variable "pesnet" {
  type        = string
  description = "Name of subnet"
}

variable "domain_password" {
  type        = string
  description = "Password of the user to authenticate with the domain"
  sensitive   = true
}
variable "domain_user" {
  type        = string
  description = "Domain user to authenticate with the domain"
}