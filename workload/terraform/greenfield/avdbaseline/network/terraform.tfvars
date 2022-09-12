//tested last on a hashicorp/azurerm v3.22.0.
avdLocation  = "eastus"
prefix       = "modu"
rg_network   = "rg-avd-eus-modu-network" #rg-avd-<location>-<prefix>-network
vnet_range   = ["10.21.0.0/23"]          # ensure this is not overlapping with other vnet ranges
subnet_range = ["10.21.0.0/23"]
dns_servers  = ["10.0.1.6", "168.63.129.16"] #custom dns server and Azure DNS
rt           = "route-avd-eus-modu-001"      #route-avd-<azure region>-<prefix>-<nnn>
nsg          = "nsg-avd-eus-modu-001"        #nsg-avd-<azure region>-<prefix>-<nnn>
vnet         = "vnet-avd-eus-modu-001"       #vnet-avd-<azure region>-<prefix>-<nnn>
snet         = "snet-avd-eus-modu-001"       #snet-avd-<azure region>-<prefix>-<nnn>
ad_vnet      = "infra-network"               # hub vnet name
ad_rg        = "infra-rg"                    # hub network resource group



