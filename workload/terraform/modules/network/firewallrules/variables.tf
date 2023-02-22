variable "avdLocation" {
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the Resource group in which to deploy network resources"
}
variable "prefix" {
  type        = string
  description = "Prefix of the name of the AVD resources"
}

variable "next_hop_ip" {
  type        = string
  description = "Next hop IP address"
}

variable "fw_policy" {
  type        = string
  description = "Name of the firewall policy"
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