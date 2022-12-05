terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.33.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.25.0"
    }
  }
}
provider "azurerm" {
  features {}
}

# generate a random string (consisting of four characters)
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string
resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

provider "azurerm" {
  features {}
  alias           = "hub"
  subscription_id = var.hub_subscription_id
}

provider "azurerm" {
  features {}
  alias           = "spoke"
  subscription_id = var.spoke_subscription_id
}
