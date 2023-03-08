variable "rg_avdi" {
  type        = string
  description = "Name of the Resource group in which to deploy avd insights objects"
}

variable "prefix" {
  type        = string
  description = "Prefix which will be included in all the deployed resources name"
}

variable "avdLocation" {
  description = "Azure Region location of the resources."
}
