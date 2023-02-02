variable "avdLocation" {
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource group in which to deploy network resources"
}

variable "hub_connectivity_rg" {
  type        = string
  description = "The resource group for the hub connectivity resources"
}

variable "tags" {
  type = map(any)
  default = {
    environment = "poc"
    source      = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/network"
  }
}