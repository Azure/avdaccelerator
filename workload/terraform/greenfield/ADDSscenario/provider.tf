terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=3.11.0, <4.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
    random = {
      source = "hashicorp/random"
    }
    local = {
      source = "hashicorp/local"
    }
    azapi = {
      source = "Azure/azapi"
      version = "=1.8.0"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

provider "azuread" {
  tenant_id = "b7b812fe-be8c-4adc-883f-2a3c36d753d7"
}

provider "azurerm" {
  partner_id = "89c34160-547d-11ed-baa8-6fad1bf031a2"
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy      = false
      purge_soft_deleted_certificates_on_destroy = false
      purge_soft_deleted_keys_on_destroy         = false
      recover_soft_deleted_key_vaults            = true
      recover_soft_deleted_secrets               = true
      recover_soft_deleted_certificates          = true
      recover_soft_deleted_keys                  = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
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

provider "azurerm" {
  features {}
  alias           = "avdshared"
  subscription_id = var.avdshared_subscription_id
}

provider "azurerm" {
  features {}
  alias           = "identity"
  subscription_id = var.identity_subscription_id
}
