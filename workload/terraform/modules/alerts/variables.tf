variable "hub_subscription_id" {
  type        = string
  description = "Hub Subscription id"
}

variable "rg_shared_name" {
  type        = string
  description = "Resource Group to share alerts with"
}

variable "avdLocation" {
  description = "Location of the resource group."
}