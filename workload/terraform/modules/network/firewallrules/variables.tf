variable "avdLocation" {
  description = "The Azure region."
}
variable "prefix" {
  type        = string
  description = "Prefix of the name of the AVD resources"
}

variable "fw_policy" {
  type        = string
  description = "Name of the firewall policy"
}

variable "hub_connectivity_rg" {
  type        = string
  description = "The resource group for the hub connectivity resources"
}

variable "hub_subscription_id" {
  type        = string
  description = "Hub Subscription id"
}

variable "hub_vnet" {
  type        = string
  description = "Hub VNet name"
}

variable "tags" {
  type = map(any)
  default = {
    environment = "poc"
    source      = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/network"
  }
}