variable "rg_name" {
  type        = string
  description = "Name of the Resource group in which to deploy these resources"
}
variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
}

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "signame" {
  type = string
  description = "The Azure Compute Gallery name"
}