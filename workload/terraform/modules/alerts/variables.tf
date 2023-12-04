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

variable "spoke_subscription_id" {
  type        = string
  description = "Spoke Subscription id"
}

variable "prefix" {
  type        = string
  description = "Prefix of the name under 5 characters"
  validation {
    condition     = length(var.prefix) < 5 && lower(var.prefix) == var.prefix
    error_message = "The prefix value must be lowercase and < 4 chars."
  }
}

variable "rg_avdi" {
  type        = string
  description = "Name of the Resource group in which to deploy avd service objects"
}

variable "email_address" {
  type        = string
  description = "Email address to send alerts to"
}