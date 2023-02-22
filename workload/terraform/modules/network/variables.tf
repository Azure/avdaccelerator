variable "avdLocation" {
  description = "Location of the resource group."
}
variable "rg_network" {
  type        = string
  description = "Name of the Resource group in which to deploy network resources"
}

variable "identity_rg" {
  type        = string
  description = "Name of the Resource group in which to identity resources are deployed"
}

variable "identity_vnet" {
  type        = string
  description = "Name of the vnet in which to identity resources are deployed"

}

variable "vnet" {
  type        = string
  description = "Name of avd vnet"
}

variable "snet" {
  type        = string
  description = "Name of subnet"
}

variable "pesnet" {
  type        = string
  description = "Name of subnet"
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
variable "subnet_range" {
  type        = list(string)
  description = "Address range for session host subnet"
}

variable "pesubnet_range" {
  type        = list(string)
  description = "Address range for private endpoints subnet"
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

variable "tags" {
  type = map(any)
  default = {
    environment = "poc"
    source      = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/network"
  }
}

variable "hub_connectivity_rg" {
  type        = string
  description = "The resource group for AD VM"
}
variable "hub_vnet" {
  type        = string
  description = "Name of domain controller vnet"
}
variable "hub_subscription_id" {
  type        = string
  description = "Hub Subscription id"
}
variable "spoke_subscription_id" {
  type        = string
  description = "Spoke Subscription id"
}

variable "identity_subscription_id" {
  type        = string
  description = "Identity Subscription id"
} 