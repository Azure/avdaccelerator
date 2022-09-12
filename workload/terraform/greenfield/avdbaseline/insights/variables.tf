variable "rg_so" {
  type        = string
  description = "Name of the Resource group in which to deploy avd service objects"
}

variable "prefix" {
  type        = string
  description = "Prefix of the name of the AVD machine(s)"
}

variable "avdLocation" {
  description = "Location of the resource group."
}

variable "tags" {
  type = map(any)
  default = {
    environment = "poc"
    source      = "https://github.com/Azure/avdaccelerator/tree/main/workload/terraform/avdbaseline"
  }
}