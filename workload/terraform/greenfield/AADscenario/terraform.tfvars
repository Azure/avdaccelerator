/*tested on
Terraform v1.3.3
on windows_amd64
+ provider registry.terraform.io/azure/azapi v1.0.0
+ provider registry.terraform.io/hashicorp/azuread v2.25.0
+ provider registry.terraform.io/hashicorp/azurerm v3.22.0
+ provider registry.terraform.io/hashicorp/local v2.2.3
+ provider registry.terraform.io/hashicorp/random v3.3.2
+ provider registry.terraform.io/hashicorp/time v0.8.0
*/

avdLocation = "eastus"

rg_shared_name = "shared-resources"  #rg-avd-<location>-<prefix>-shared-resources
rg_network     = "network"           #rg-avd-<location>-<prefix>-network
rg_stor        = "storage"           #rg-avd-<location>-<prefix>-storage
rg_pool        = "pool-compute"      #rg-avd-<location>-<prefix>-pool-compute
rg_personal    = "personal-compute"  #rg-avd-<location>-<prefix>-pool-compute
rg_remoteapp   = "remoteapp-compute" #rg-avd-<location>-<prefix>-pool-compute
rg_so          = "service-objects"   #rg-avd-<azure Region>-<prefix>-service-objects
rg_image_name  = "image-resources"

hostpool     = "vdpool" #vdpool-<azure region>-<prefix>
personalpool = "vdpool"
raghostpool  = "vdpool"
workspace    = "vdws" #vdws-<azure region>-<prefix>-<nnn>
pworkspace   = "vdws"
ragworkspace = "vdws"
pag          = "vpag"
dag          = "vdag"         #vdag-desktop-<azure region>-<prefix>-<nnn>
rag          = "vrag"         #vdag-rapp-<azure region>-<prefix>-<nnn>
scplan       = "scaling-plan" #avd-<location>-<prefix>-scaling-plan

host_pool_log_categories = ["Checkpoint", "Management", "Connection", "HostRegistration", "AgentHealthStatus", "NetworkData", "SessionHostManagement", "ConnectionGraphicsData", "Error"]
dag_log_categories       = ["Checkpoint", "Management", "Error"]
ws_log_categories        = ["Checkpoint", "Management", "Error", "Feed"]

rt            = "route-avd" #route-avd-<azure region>-<prefix>-<nnn>
nsg           = "nsg-avd"   #nsg-avd-<azure region>-<prefix>-<nnn>
vnet          = "vnet-avd"  #vnet-avd-<azure region>-<prefix>-<nnn>
snet          = "snet-avd"  #snet-avd-<azure region>-<prefix>-<nnn>
vnet_range    = ["10.18.0.0/23"]
subnet_range  = ["10.18.0.0/23"]
allow_list_ip = ["10.18.0.0/23"]
dns_servers   = ["10.0.1.6", "168.63.129.16"]
ad_vnet       = "infra-network"
ad_rg         = "infra-rg"

//object_name              = ["Logical Disk"] //, "Memory", "Physical Disk", "Processor", "System"]
//counter_name             = ["% Free Space"] //, "Avg. Disk Queue Length", "Avg. Disk sec/Transfe", "Current Disk Queue Length", "Available Mbytes", "Page Faults/sec", "Page/sec"]
//interval_seconds         = ["60"]           //, "30", "60", "30", "30", "30", "30", "30", "30"]

prefix               = "aadj"
local_admin_username = "localadmin"   # Your AVD VM login id to manage username
local_admin_password = "ChangeMe123!" # Your AVD VM login id to manage password
vm_size              = "Standard_D8s_v5"
rdsh_count           = 2
image_name           = "avdImage-microsoftwindowsdesktop-office-365-win11-21h2-avd-m365"
image_rg             = "rg-eastus-avd-AIBdemoAVD-shared-resources"
gallery_name         = "avdgallery_eastus_AIBdemoAVD"

aad_group_name = "avdusersgrp" #user group must pre-created on your AD server and sync to Azure AD

spoke_subscription_id = "b0aeeba8-4430-4cf1-acbc-6e24cadf86c9"
hub_subscription_id   = "b0aeeba8-4430-4cf1-acbc-6e24cadf86c9"




