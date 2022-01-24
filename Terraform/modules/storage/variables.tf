variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "aad_group_name" {
  type        = string
  description = "Azure Active Directory Group for AVD users"
}