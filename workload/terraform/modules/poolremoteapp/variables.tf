variable "rg_so" {
  type        = string
  description = "Name of the Resource group in which to deploy service objects"
}

variable "rg_shared_name" {
  type        = string
  description = "Name of the Resource group in which to deploy shared resources"
}

variable "prefix" {
  type        = string
  description = "Prefix of the name of the AVD machine(s)"
}

variable "ragworkspace" {
  type        = string
  description = "Name of the Azure Virtual Desktop workspace"
}

variable "rag" {
  type        = string
  description = "Name of the Azure Virtual Desktop remote application group"
}

variable "raghostpool" {
  type        = string
  description = "Name of the Azure Virtual Desktop remote app group"
}

variable "avdLocation" {
  description = "Location of the resource group."
}

variable "rfc3339" {
  type        = string
  description = "Registration token expiration"
}

variable "tags" {
  type = map(any)
  default = {
    environment = "poc"
    source      = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
  }
}