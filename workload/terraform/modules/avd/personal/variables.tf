variable "rg_personal" {
  type        = string
  description = "Name of the Resource group in which to deploy service objects"
}

variable "rg_avdi" {
  type        = string
  description = "Name of the Resource group in which to deploy avd service objects"
}

variable "prefix" {
  type        = string
  description = "Prefix of the name of the AVD machine(s)"
}

variable "pworkspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop Personal workspace"
}

variable "personalpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop host pool"
}

variable "pag" {
  type        = string
  description = "Name of the Azure Virtual Desktop desktop application group"
}

variable "avdLocation" {
  description = "Location of the resource group."
}

variable "aad_group_name" {
  type        = string
  description = "Microsoft Entra ID Group for AVD users"
}
