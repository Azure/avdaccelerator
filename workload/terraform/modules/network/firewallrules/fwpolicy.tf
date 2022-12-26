resource "azurerm_firewall_policy" "fw_policy" {
  name                = "AVD-FW-Policy"
  resource_group_name = var.rg_network
  location            = var.avdLocation
  tags                = var.tags
  sku                 = "Premium"

}
resource "azurerm_firewall_policy_rule_collection_group" "fw_policy_rule_collection_group" {
  name               = "AVD-FW-RCG"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 100

  ### Required Network Rules for AVD
  network_rule_collection {
    name     = "AVD-Network-Rule-Collection"
    priority = 100
    action   = "Allow"
    rule {
      name                  = "Service Traffic"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["WindowsVirtualDesktop"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "Agent Traffic"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureMonitor"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "Azure Marketplace"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["AzureFrontDoor.Frontend"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "Windows Activation"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["kms.core.windows.net"]
      destination_ports     = ["1688"]
    }
    rule {
      name                  = "Auth to Msft Online Services"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["login.microsoftonline.com	"]
      destination_ports     = ["443"]
    }

    rule {
      name                  = "Azure Windows Activation"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["azkms.core.windows.net"]
      destination_ports     = ["1688"]
    }
    rule {
      name                  = "Agent and SxS Stack Updates"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["mrsglobalsteus2prod.blob.core.windows.net"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "Azure Portal Support"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["wvdportalstorageblob.blob.core.windows.net"]
      destination_ports     = ["443"]
    }
    rule {
      name                  = "Azure Instance Metadata Service Endpoint"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["169.254.169.254"]
      destination_ports     = ["80"]
    }
    rule {
      name                  = "Session Host Health Monitoring"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["168.63.129.16"]
      destination_ports     = ["80"]
    }
    rule {
      name                  = "Cert CRL OneOCSP"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["oneocsp.microsoft.com"]
      destination_ports     = ["80"]
    }
    rule {
      name                  = "Cert CRL MicrosoftDotCom"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["www.microsoft.com"]
      destination_ports     = ["80"]
    }
  }

  ### Required Application Rules for AVD
  application_rule_collection {
    name     = "AVD-Application-Rule-Collection"
    priority = 200
    action   = "Allow"

    rule {
      name = "TelemetryService"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.events.data.microsoft.com"]
    }
    rule {
      name = "Windows Update"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.sfx.ms"]
    }
    rule {
      name = "UpdatesforOneDrive"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses      = ["*"]
      destination_fqdn_tags = ["WindowsUpdate"]
    }
    rule {
      name = "DigitcertCRL"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.digicert.com"]
    }
    rule {
      name = "AzureDNSResolution"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.azure-dns.com"]
    }
    rule {
      name = "AzureDNSresolution2"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["*"]
      destination_fqdns = ["*.azure-dns.net"]
    }
  }
}