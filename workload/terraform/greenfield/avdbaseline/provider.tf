terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.22.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
    azapi = {
      source = "Azure/azapi"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.8.0"
    }
  }
}

provider "azurerm" {
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
