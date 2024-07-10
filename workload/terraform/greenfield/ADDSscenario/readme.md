<!-- BEGIN_TF_DOCS -->
# Azure Virtual Desktop Accelerator for Terraform Guide for Active Directory Domain Services joined session host

This guide is designed to help you get started with deploying Azure Virtual Desktop using the provided Terraform template(s) within this repository. Before you deploy, it is recommended to review the template(s) to understand the resources that will be deployed and the associated costs.

This accelerator is to be used as starter kit and you can expand its functionality by developing your own deployments. This scenario deploys a new Azure Virtual Desktop workload, so it cannot be used to maintain, modify or add resources to an existing or already deployed Azure Virtual Desktop workload from this accelerator.

***Note*** This terraform accelerator requires the Custom Image Build before deploying the Baseline. If you prefer to use the marketplace image with no customization [see](https://docs.microsoft.com/en-us/azure/developer/terraform/create-avd-session-host)

## Table of Contents

- [Prerequisites](#prerequisites)  
- [Planning](#planning)
- [AVD Spoke Network](#avd-network)
- [AVD Baseline](#avd-baseline)
- [Implementation](#implementation)
- [Backend Setup](#backends)  
- [Terraform file Structure](#files)
- [Estimated Cost](#estimated-cost)  

This guide describes how to deploy Azure Virtual Desktop Accelerator using the [Terraform](https://www.terraform.io/).
To get started with Terraform on Azure check out their [tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/).

## Prerequisites

- Meet the prerequisites listed [here](https://github.com/Azure/avdaccelerator/blob/main/workload/docs/getting-started-baseline.md#prerequisites)
- Current version of the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Current version of the Terraform CLI
- An Azure Subscription(s) where you or an identity you manage has `Owner` [RBAC permissions](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)
- Ensure Encryption at Host feature is already enabled on the subscription. To enable: az feature register --name EncryptionAtHost  --namespace Microsoft.Compute. To validate: az feature show --name EncryptionAtHost --namespace Microsoft.Compute

## Planning

### Decide on a Prefix

The deployments will require a "Prefix" which will be included in all the deployed resources name.
Resource Groups and resource names are derived from the `Prefix` parameter. Pick a unique resource prefix that is 3-5 alphanumeric characters in length without whitespaces.

## AVD-Network

Azure Virtual Desktop resources and dependent services for establishing the Azure Virtual Desktop spoke network:

- Network Security group
- New VNet and subnet
- Peering to the hub virtual network
- Baseline NSG
- Route table

## Files

The Azure Virtual Desktop Network Terraform files are all written as individual files each having a specific function. Variables have been created in all files for consistency, all changes to defaults are to be changed from the terraform.tfvars.sample file. The structure is as follows:
| file Name                  | Description                                                  |
| ---------------------------| ------------------------------------------------------------ |
| data.tf                    | This file has data lookup |
| dns\_zones.tf               | This file creates the private DNS zone and links |
| output.tf                  | This will contains the outputs post deployment |
| rg.tf                      | Creates the resource groups |
| routetable.tf              | Creates a routetable |
| locals.tf                  | This file is for locals |
| main.tf                    | This file contains the Terraform provider settings and version |
| nsg.tf                     | Creates the network security group with required URLs |
| variables.tf               | Variables have been created in all files for various properties and names |
| networking.tf              | Creates the AVD spoke virtual network, subnet and peering to the hub network |
| terraform.tfvars.sample    | This file contains the values for the variables change per your requirements |

Validated on provider versions:

- hashicorp/azurerm v3.22.0

![AVD Network Spoke Image diagram](../../../docs/diagrams/avd-accelerator-terraform-spoke-network.png)

## AVD-Baseline  

Azure Virtual Desktop resources and dependent services for establishing the baseline.

- Azure Virtual Desktop resources:
  - 1 Host Pools – pooled
  - 1 Desktop application group
  - 1 Workspaces – 1 pooled
  - Options to add personal and remote app host pools, workspaces, desktop application groups
  - 2 Session host VMs domain join (options to use custom image or marketplace image)
  - AVD Monitoring, log analytics workspace and diagnostic logs enabled
  - AVD Scaling plan
  - Associated Desktop Application Group for personal
  - Associated Desktop Application Group and Remote Application Group for pooled
- Azure Files Storage with FSLogix share, RBAC role assignment and private endpoint
- Application Security group
- Key Vault and private endpoint

The Azure Virtual Desktop Baseline Terraform files are all written as individual files each having a specific function. Variables have been created in all files for consistency, all changes to defaults are to be changed from the terraform.tfvars.sample file. The structure is as follows:

| file Name                  | Description                                                  |
| ---------------------------| ------------------------------------------------------------ |
| main.tf                    | This file deploys Azure Virtual Desktop |
| data.tf                    | This file has data lookup |
| locals.tf                  | This file is for locals |
| host.tf                    | This file deploys session host using the custom image in the Azure Compute Gallery |
| provider.tf                | This file contains the Terraform provider settings and version |
| afstorage.tf               | This file creates the Storage account and Azure files shares with RBAC |
| keyvault.tf                | This file creates the Key Vault to be used     |
| appsecgrp.tf               | This file creates the Application security group to be used     |
| avd.tf                     | This file creates the a Azure Virtual Desktop service objects     |
| rbac.tf                    | This will creates the rbac permissions |
| output.tf                  | This will contains the outputs post deployment |
| variables.tf               | Variables have been created in all files for various properties and names |
| rg.tf                      | Creates the resources group for the deployment |
| terraform.tfvars.sample    | This file contains the values for the variables change per your requirements |

Validated on provider versions:

- hashicorp/random v3.3.2
- hashicorp/azuread v2.26.1
- hashicorp/azurerm v3.22.0

![AVD Baseline diagram](../../../docs/diagrams/avd-accelerator-terraform-baseline-image.png)

## Implementation

1. Clone your repo with the following git command:

```bash
  git clone <https://github.com/Azure/avdaccelerator.git>
```  

2. Change your terminal into that new subdirectory:

```bash
  cd avdaccelerator/workload/terraform/greenfield/ADDSscenario
  az account list --output table
  az account set --subscription 'Your AVD workload subscription ID'
```

3. Rename `terraform.tfvars.sample` to `terraform.tfvars`
4. Edit the `terraform.tfvars` configuration variables in the section `Modify the following variables to match your environment` to your preferences  
5. Run terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Backends

The default templates write a state file directly to disk locally to where you are executing terraform from. If you wish to AzureRM backend please see [AzureRM Backend](https://www.terraform.io/docs/language/settings/backends/azurerm.html). This deployment highlights using Azure Blog Storage to store state file and Key Vault

### Backends using Azure Blob Storage

<details>
<summary>Click to expand</summary>
#### Using Azure CLI

[Store state in Azure Storage](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)

```cli
RESOURCE_GROUP_NAME=tstate
STORAGE_ACCOUNT_NAME=tstate$RANDOM
CONTAINER_NAME=tstate
```

### Create resource group

```cli
az group create --name $RESOURCE_GROUP_NAME --location <eastus>
```

### Create storage account

```cli
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob
```

#### Get storage account key

```cli
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
```

#### Create blob container

```cli
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"
```

### Create a key vault

[Create Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/secrets/quick-create-cli)

```cli
az keyvault create --name "<Azure Virtual Desktopkeyvaultdemo>" --resource-group $RESOURCE_GROUP_NAME --location "<East US>"
```

#### Add storage account access key to key vault

```cli
az keyvault secret set --vault-name "<Azure Virtual Desktopkeyvaultdemo>" --name terraform-backend-key --value "<W.........................................>"
```

## Estimated Cost

A breakdown of estimated cost for this deployment. Adjust to sku will change the estimates.
![Cost Estimate](../../../docs/diagrams/cost-estimate.png)

58 were free:

- 20 x azurerm\_log\_analytics\_datasource\_windows\_performance\_counter
- 9 x azurerm\_log\_analytics\_datasource\_windows\_event
- 5 x azurerm\_resource\_group
- 4 x azurerm\_role\_assignment
- 2 x azurerm\_network\_interface
- 2 x azurerm\_private\_dns\_zone\_virtual\_network\_link
- 2 x azurerm\_subnet
- 1 x azurerm\_application\_security\_group
- 1 x azurerm\_firewall\_policy\_rule\_collection\_group
- 1 x azurerm\_key\_vault
- 1 x azurerm\_key\_vault\_access\_policy
- 1 x azurerm\_key\_vault\_secret
- 1 x azurerm\_network\_security\_group
- 1 x azurerm\_storage\_account\_network\_rules
- 1 x azurerm\_subnet\_network\_security\_group\_association
- 1 x azurerm\_user\_assigned\_identity
- 1 x azurerm\_virtual\_desktop\_application\_group
- 1 x azurerm\_virtual\_desktop\_host\_pool
- 1 x azurerm\_virtual\_desktop\_workspace
- 1 x azurerm\_virtual\_desktop\_workspace\_application\_group\_association
- 1 x azurerm\_virtual\_network

Generated by: [Infracost](https://www.infracost.io/)
</details>

```hcl
# Creates the Azure Virtual Desktop Spoke Network resources
module "network" {
  source                   = "../../modules/network"
  avdLocation              = var.avdLocation
  rg_network               = var.rg_network
  vnet                     = var.vnet
  snet                     = var.snet
  pesnet                   = var.pesnet
  vnet_range               = var.vnet_range
  nsg                      = "${var.nsg}-${var.prefix}-${var.environment}-${var.avdLocation}"
  prefix                   = var.prefix
  rt                       = "${var.rt}-${var.prefix}-${var.environment}-${var.avdLocation}"
  hub_connectivity_rg      = var.hub_connectivity_rg
  hub_vnet                 = var.hub_vnet
  subnet_range             = var.subnet_range
  pesubnet_range           = var.pesubnet_range
  next_hop_ip              = var.next_hop_ip
  fw_policy                = var.fw_policy
  hub_subscription_id      = var.hub_subscription_id
  spoke_subscription_id    = var.spoke_subscription_id
  identity_subscription_id = var.identity_subscription_id
  identity_rg              = var.identity_rg
  identity_vnet            = var.identity_vnet
}

# Create Azure Log Analytics workspace for Azure Virtual Desktop
module "avm_res_operationalinsights_workspace" {
  source              = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version             = "0.1.3"
  enable_telemetry    = var.enable_telemetry
  resource_group_name = azurerm_resource_group.mon.name
  location            = var.avdLocation
  name                = lower(replace("log-avd-${var.environment}-${var.avdLocation}", "-", ""))
  tags                = local.tags
}

module "avm_res_desktopvirtualization_hostpool" {
  source  = "Azure/avm-res-desktopvirtualization-hostpool/azurerm"
  version = "0.1.4"

  virtual_desktop_host_pool_location                 = azurerm_resource_group.this.location
  virtual_desktop_host_pool_name                     = "${var.hostpool}-${var.prefix}-${var.environment}-${var.avdLocation}"
  virtual_desktop_host_pool_type                     = "Pooled" // "Personal" or "Pooled"
  virtual_desktop_host_pool_resource_group_name      = azurerm_resource_group.this.name
  virtual_desktop_host_pool_load_balancer_type       = "BreadthFirst" // "DepthFirst" or "BreadthFirst"
  virtual_desktop_host_pool_custom_rdp_properties    = "drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;use multimon:i:0"
  virtual_desktop_host_pool_maximum_sessions_allowed = 16
  virtual_desktop_host_pool_start_vm_on_connect      = true
  resource_group_name                                = azurerm_resource_group.this.name
  virtual_desktop_host_pool_scheduled_agent_updates = {
    enabled = "true"
    schedule = tolist([{
      day_of_week = "Sunday"
      hour_of_day = 0
    }])
  }
  diagnostic_settings = {
    to_law = {
      name                  = "to-law"
      workspace_resource_id = module.avm_res_operationalinsights_workspace.resource.id
    }
  }
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  expiration_date = timeadd(timestamp(), "48h")
  hostpool_id     = module.avm_res_desktopvirtualization_hostpool.resource.id
}

# Get an existing built-in role definition
data "azurerm_role_definition" "this" {
  name = "Desktop Virtualization User"
}

# Get an existing Azure AD group that will be assigned to the application group
data "azuread_group" "existing" {
  display_name     = var.user_group_name
  security_enabled = true
}

# Assign the Azure AD group to the application group
resource "azurerm_role_assignment" "this" {
  principal_id                     = data.azuread_group.existing.object_id
  scope                            = module.avm_res_desktopvirtualization_applicationgroup.resource.id
  role_definition_id               = data.azurerm_role_definition.this.id
  skip_service_principal_aad_check = false
}

# Create Azure Virtual Desktop application group
module "avm_res_desktopvirtualization_applicationgroup" {
  source                                                = "Azure/avm-res-desktopvirtualization-applicationgroup/azurerm"
  enable_telemetry                                      = var.enable_telemetry
  version                                               = "0.1.2"
  virtual_desktop_application_group_name                = "${var.dag}-${var.prefix}-${var.environment}-${var.avdLocation}-01"
  virtual_desktop_application_group_type                = "Desktop"
  virtual_desktop_application_group_host_pool_id        = module.avm_res_desktopvirtualization_hostpool.resource.id
  virtual_desktop_application_group_resource_group_name = azurerm_resource_group.this.name
  virtual_desktop_application_group_location            = azurerm_resource_group.this.location
  user_group_name                                       = var.user_group_name
  virtual_desktop_application_group_tags                = local.tags
}

# Create Azure Virtual Desktop workspace
module "avm_res_desktopvirtualization_workspace" {
  source              = "Azure/avm-res-desktopvirtualization-workspace/azurerm"
  version             = "0.1.2"
  enable_telemetry    = var.enable_telemetry
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  description         = "${var.prefix} Workspace"
  name                = "${var.workspace}-${var.prefix}-${var.environment}-${var.avdLocation}-01"
  tags                = local.tags
  diagnostic_settings = {
    to_law = {
      name                  = "to-law"
      workspace_resource_id = module.avm_res_operationalinsights_workspace.resource.id
    }
  }
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workappgrassoc" {
  application_group_id = module.avm_res_desktopvirtualization_applicationgroup.resource.id
  workspace_id         = module.avm_res_desktopvirtualization_workspace.resource.id
}

# Get the service principal for Azure Vitual Desktop
data "azuread_service_principal" "spn" {
  client_id = "9cdead84-a844-4324-93f2-b2e6bb768d07"
}

resource "random_uuid" "example" {}

data "azurerm_role_definition" "power_role" {
  name = "Desktop Virtualization Power On Off Contributor"
}

resource "azurerm_role_assignment" "new" {
  principal_id         = data.azuread_service_principal.spn.object_id
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Desktop Virtualization Power On Off Contributor"
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# This is the storage account for the diagnostic settings
resource "azurerm_storage_account" "this" {
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this.location
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.this.name
}

# Create Azure Virtual Desktop scaling plan
module "avm_res_desktopvirtualization_scaling_plan" {
  source                                           = "Azure/avm-res-desktopvirtualization-scalingplan/azurerm"
  enable_telemetry                                 = var.enable_telemetry
  version                                          = "0.1.2"
  virtual_desktop_scaling_plan_name                = "${var.scplan}-${var.prefix}-${var.environment}-${var.avdLocation}-01"
  virtual_desktop_scaling_plan_location            = azurerm_resource_group.this.location
  virtual_desktop_scaling_plan_resource_group_name = azurerm_resource_group.this.name
  virtual_desktop_scaling_plan_time_zone           = "Eastern Standard Time"
  virtual_desktop_scaling_plan_description         = "${var.prefix} Scaling Plan"
  virtual_desktop_scaling_plan_tags                = local.tags
  virtual_desktop_scaling_plan_host_pool = toset(
    [
      {
        hostpool_id          = module.avm_res_desktopvirtualization_hostpool.resource.id
        scaling_plan_enabled = true
      }
    ]
  )
  virtual_desktop_scaling_plan_schedule = toset(
    [
      {
        name                                 = "Weekday"
        days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        ramp_up_start_time                   = "09:00"
        ramp_up_load_balancing_algorithm     = "BreadthFirst"
        ramp_up_minimum_hosts_percent        = 50
        ramp_up_capacity_threshold_percent   = 80
        peak_start_time                      = "10:00"
        peak_load_balancing_algorithm        = "DepthFirst"
        ramp_down_start_time                 = "17:00"
        ramp_down_load_balancing_algorithm   = "BreadthFirst"
        ramp_down_minimum_hosts_percent      = 50
        ramp_down_force_logoff_users         = true
        ramp_down_wait_time_minutes          = 15
        ramp_down_notification_message       = "The session will end in 15 minutes."
        ramp_down_capacity_threshold_percent = 50
        ramp_down_stop_hosts_when            = "ZeroActiveSessions"
        off_peak_start_time                  = "18:00"
        off_peak_load_balancing_algorithm    = "BreadthFirst"
      },
      {
        name                                 = "Weekend"
        days_of_week                         = ["Saturday", "Sunday"]
        ramp_up_start_time                   = "09:00"
        ramp_up_load_balancing_algorithm     = "BreadthFirst"
        ramp_up_minimum_hosts_percent        = 50
        ramp_up_capacity_threshold_percent   = 80
        peak_start_time                      = "10:00"
        peak_load_balancing_algorithm        = "DepthFirst"
        ramp_down_start_time                 = "17:00"
        ramp_down_load_balancing_algorithm   = "BreadthFirst"
        ramp_down_minimum_hosts_percent      = 50
        ramp_down_force_logoff_users         = true
        ramp_down_wait_time_minutes          = 15
        ramp_down_notification_message       = "The session will end in 15 minutes."
        ramp_down_capacity_threshold_percent = 50
        ramp_down_stop_hosts_when            = "ZeroActiveSessions"
        off_peak_start_time                  = "18:00"
        off_peak_load_balancing_algorithm    = "BreadthFirst"
      }
    ]
  )
  diagnostic_settings = {
    to_law = {
      name                        = "to-storage-account"
      storage_account_resource_id = azurerm_storage_account.this.id
    }
  }
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

No requirements.

## Providers

The following providers are used by this module:

- <a name="provider_azuread"></a> [azuread](#provider\_azuread)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)

- <a name="provider_azurerm.hub"></a> [azurerm.hub](#provider\_azurerm.hub)

- <a name="provider_azurerm.spoke"></a> [azurerm.spoke](#provider\_azurerm.spoke)

- <a name="provider_random"></a> [random](#provider\_random)

- <a name="provider_time"></a> [time](#provider\_time)

## Resources

The following resources are used by this module:

- [azurerm_application_security_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_security_group) (resource)
- [azurerm_availability_set.aset](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) (resource)
- [azurerm_key_vault.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_key_vault_key.stcmky](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_key_vault_key.stkek](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_key_vault_secret.localpassword](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_network_interface.avd_vm_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_private_dns_zone_virtual_network_link.filelink](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_private_dns_zone_virtual_network_link.vaultlink](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_private_endpoint.afpe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_private_endpoint.kvpe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_resource_group.mon](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_resource_group.shrg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_role_assignment.af_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.keystor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.new](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_storage_account.azfile](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) (resource)
- [azurerm_storage_account_customer_managed_key.cmky](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_customer_managed_key) (resource)
- [azurerm_storage_account_network_rules.stfw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) (resource)
- [azurerm_storage_share.FSShare](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) (resource)
- [azurerm_user_assigned_identity.mi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) (resource)
- [azurerm_virtual_desktop_host_pool_registration_info.registrationinfo](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_host_pool_registration_info) (resource)
- [azurerm_virtual_desktop_workspace_application_group_association.workappgrassoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_desktop_workspace_application_group_association) (resource)
- [azurerm_virtual_machine_extension.ama](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.domain_join](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.mal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_machine_extension.vmext_dsc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) (resource)
- [azurerm_virtual_network_dns_servers.customdns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers) (resource)
- [azurerm_windows_virtual_machine.avd_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) (resource)
- [random_password.vmpass](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
- [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [random_uuid.example](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [time_rotating.avd_token](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) (resource)
- [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [azuread_group.existing](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) (data source)
- [azuread_service_principal.spn](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) (data source)
- [azurerm_client_config.cfg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_private_dns_zone.pe-filedns-zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) (data source)
- [azurerm_private_dns_zone.pe-vaultdns-zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) (data source)
- [azurerm_role_definition.power_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) (data source)
- [azurerm_role_definition.storage_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) (data source)
- [azurerm_role_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) (data source)
- [azurerm_subnet.pesubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_subscription.primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) (data source)
- [azurerm_virtual_network.remote](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) (data source)
- [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_allow_list_ip"></a> [allow\_list\_ip](#input\_allow\_list\_ip)

Description: List of allowed IP Addresses

Type: `list(string)`

### <a name="input_avdLocation"></a> [avdLocation](#input\_avdLocation)

Description: Location of the resource group.

Type: `any`

### <a name="input_avdshared_subscription_id"></a> [avdshared\_subscription\_id](#input\_avdshared\_subscription\_id)

Description: Spoke Subscription id

Type: `string`

### <a name="input_dag"></a> [dag](#input\_dag)

Description: Name of the Azure Virtual Desktop desktop application group

Type: `string`

### <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers)

Description: Custom DNS configuration

Type: `list(string)`

### <a name="input_domain_guid"></a> [domain\_guid](#input\_domain\_guid)

Description: Domain GUID

Type: `string`

### <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name)

Description: Name of the domain to join

Type: `string`

### <a name="input_domain_sid"></a> [domain\_sid](#input\_domain\_sid)

Description: Domain SID

Type: `string`

### <a name="input_domain_user"></a> [domain\_user](#input\_domain\_user)

Description: Username for domain join (do not include domain name as this is appended)

Type: `string`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: Environment name sets the type of environment (Development (dev), Test (test), Production (prod)) that will be deployed, this information will be use as part of the resources naming.

Type: `string`

### <a name="input_fw_policy"></a> [fw\_policy](#input\_fw\_policy)

Description: Name of the firewall policy

Type: `string`

### <a name="input_hostpool"></a> [hostpool](#input\_hostpool)

Description: Name of the Azure Virtual Desktop host pool

Type: `string`

### <a name="input_hub_connectivity_rg"></a> [hub\_connectivity\_rg](#input\_hub\_connectivity\_rg)

Description: The resource group for hub connectivity resources

Type: `string`

### <a name="input_hub_dns_zone_rg"></a> [hub\_dns\_zone\_rg](#input\_hub\_dns\_zone\_rg)

Description: The resource group for the hub DNS zone

Type: `any`

### <a name="input_hub_subscription_id"></a> [hub\_subscription\_id](#input\_hub\_subscription\_id)

Description: Hub Subscription id

Type: `string`

### <a name="input_hub_vnet"></a> [hub\_vnet](#input\_hub\_vnet)

Description: Name of domain controller vnet

Type: `string`

### <a name="input_identity_rg"></a> [identity\_rg](#input\_identity\_rg)

Description: Name of the Resource group in which to identity resources are deployed

Type: `string`

### <a name="input_identity_subscription_id"></a> [identity\_subscription\_id](#input\_identity\_subscription\_id)

Description: identity Subscription id

Type: `string`

### <a name="input_identity_vnet"></a> [identity\_vnet](#input\_identity\_vnet)

Description: Name of the vnet in which to identity resources are deployed

Type: `string`

### <a name="input_local_admin_username"></a> [local\_admin\_username](#input\_local\_admin\_username)

Description: local admin username

Type: `string`

### <a name="input_netbios_domain_name"></a> [netbios\_domain\_name](#input\_netbios\_domain\_name)

Description: Netbios domain name

Type: `string`

### <a name="input_next_hop_ip"></a> [next\_hop\_ip](#input\_next\_hop\_ip)

Description: Next hop IP address

Type: `string`

### <a name="input_nsg"></a> [nsg](#input\_nsg)

Description: Name of the nsg

Type: `string`

### <a name="input_offer"></a> [offer](#input\_offer)

Description: Offer of the image

Type: `string`

### <a name="input_ou_path"></a> [ou\_path](#input\_ou\_path)

Description: Distinguished name of the organizational unit for the session host

Type: `any`

### <a name="input_pag"></a> [pag](#input\_pag)

Description: Name of the Azure Virtual Desktop remote application group

Type: `string`

### <a name="input_personalpool"></a> [personalpool](#input\_personalpool)

Description: Name of the Azure Virtual Desktop host pool

Type: `string`

### <a name="input_pesnet"></a> [pesnet](#input\_pesnet)

Description: Name of subnet

Type: `string`

### <a name="input_pesubnet_range"></a> [pesubnet\_range](#input\_pesubnet\_range)

Description: Address range for private endpoints subnet

Type: `list(string)`

### <a name="input_prefix"></a> [prefix](#input\_prefix)

Description: Prefix of the name under 5 characters

Type: `string`

### <a name="input_publisher"></a> [publisher](#input\_publisher)

Description: Publisher of the image

Type: `string`

### <a name="input_pworkspace"></a> [pworkspace](#input\_pworkspace)

Description: Name of the Azure Virtual Desktop Personal workspace

Type: `string`

### <a name="input_rag"></a> [rag](#input\_rag)

Description: Name of the Azure Virtual Desktop remote application group

Type: `string`

### <a name="input_raghostpool"></a> [raghostpool](#input\_raghostpool)

Description: Name of the Azure Virtual Desktop remote app group

Type: `string`

### <a name="input_ragworkspace"></a> [ragworkspace](#input\_ragworkspace)

Description: Name of the Azure Virtual Desktop workspace

Type: `string`

### <a name="input_rdsh_count"></a> [rdsh\_count](#input\_rdsh\_count)

Description: Number of AVD machines to deploy

Type: `any`

### <a name="input_rg_avdi"></a> [rg\_avdi](#input\_rg\_avdi)

Description: Name of the Resource group in which to deploy avd service objects

Type: `string`

### <a name="input_rg_network"></a> [rg\_network](#input\_rg\_network)

Description: Name of the Resource group in which to deploy network resources

Type: `string`

### <a name="input_rg_pool"></a> [rg\_pool](#input\_rg\_pool)

Description: Resource group AVD machines will be deployed to

Type: `any`

### <a name="input_rg_shared_name"></a> [rg\_shared\_name](#input\_rg\_shared\_name)

Description: Name of the Resource group in which to deploy shared resources

Type: `string`

### <a name="input_rg_so"></a> [rg\_so](#input\_rg\_so)

Description: Name of the Resource group in which to deploy service objects

Type: `string`

### <a name="input_rg_stor"></a> [rg\_stor](#input\_rg\_stor)

Description: Name of the Resource group in which to deploy storage

Type: `string`

### <a name="input_rt"></a> [rt](#input\_rt)

Description: Name of the route table

Type: `string`

### <a name="input_scplan"></a> [scplan](#input\_scplan)

Description: Name of the session host scaling plan

Type: `string`

### <a name="input_sku"></a> [sku](#input\_sku)

Description: SKU of the image

Type: `string`

### <a name="input_snet"></a> [snet](#input\_snet)

Description: Name of subnet

Type: `string`

### <a name="input_spoke_subscription_id"></a> [spoke\_subscription\_id](#input\_spoke\_subscription\_id)

Description: Spoke Subscription id

Type: `string`

### <a name="input_subnet_range"></a> [subnet\_range](#input\_subnet\_range)

Description: Address range for session host subnet

Type: `list(string)`

### <a name="input_user_group_name"></a> [user\_group\_name](#input\_user\_group\_name)

Description: Microsoft Entra ID Group for AVD users

Type: `string`

### <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size)

Description: Size of the machine to deploy

Type: `any`

### <a name="input_vnet"></a> [vnet](#input\_vnet)

Description: Name of avd vnet

Type: `string`

### <a name="input_vnet_range"></a> [vnet\_range](#input\_vnet\_range)

Description: Address range for deployment VNet

Type: `list(string)`

### <a name="input_workspace"></a> [workspace](#input\_workspace)

Description: Name of the Azure Virtual Desktop workspace

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_domain_password"></a> [domain\_password](#input\_domain\_password)

Description: Password of the user to authenticate with the domain

Type: `string`

Default: `"ChangeMe123$"`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetry.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_azurerm_virtual_desktop_application_group"></a> [azurerm\_virtual\_desktop\_application\_group](#output\_azurerm\_virtual\_desktop\_application\_group)

Description: Name of the Azure Virtual Desktop DAG

### <a name="output_azurerm_virtual_desktop_host_pool"></a> [azurerm\_virtual\_desktop\_host\_pool](#output\_azurerm\_virtual\_desktop\_host\_pool)

Description: Name of the Azure Virtual Desktop host pool

### <a name="output_azurerm_virtual_desktop_workspace"></a> [azurerm\_virtual\_desktop\_workspace](#output\_azurerm\_virtual\_desktop\_workspace)

Description: Name of the Azure Virtual Desktop workspace

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This output is the full output for the resource to allow flexibility to reference all possible values for the resource. Example usage: module.<modulename>.resource.id

## Modules

The following Modules are called:

### <a name="module_avm_res_desktopvirtualization_applicationgroup"></a> [avm\_res\_desktopvirtualization\_applicationgroup](#module\_avm\_res\_desktopvirtualization\_applicationgroup)

Source: Azure/avm-res-desktopvirtualization-applicationgroup/azurerm

Version: 0.1.2

### <a name="module_avm_res_desktopvirtualization_hostpool"></a> [avm\_res\_desktopvirtualization\_hostpool](#module\_avm\_res\_desktopvirtualization\_hostpool)

Source: Azure/avm-res-desktopvirtualization-hostpool/azurerm

Version: 0.1.4

### <a name="module_avm_res_desktopvirtualization_scaling_plan"></a> [avm\_res\_desktopvirtualization\_scaling\_plan](#module\_avm\_res\_desktopvirtualization\_scaling\_plan)

Source: Azure/avm-res-desktopvirtualization-scalingplan/azurerm

Version: 0.1.2

### <a name="module_avm_res_desktopvirtualization_workspace"></a> [avm\_res\_desktopvirtualization\_workspace](#module\_avm\_res\_desktopvirtualization\_workspace)

Source: Azure/avm-res-desktopvirtualization-workspace/azurerm

Version: 0.1.2

### <a name="module_avm_res_operationalinsights_workspace"></a> [avm\_res\_operationalinsights\_workspace](#module\_avm\_res\_operationalinsights\_workspace)

Source: Azure/avm-res-operationalinsights-workspace/azurerm

Version: 0.1.3

### <a name="module_dcr"></a> [dcr](#module\_dcr)

Source: ../../modules/insights

Version:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.3.0

### <a name="module_network"></a> [network](#module\_network)

Source: ../../modules/network

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Additional References

<details>
<summary>Click to expand</summary>

- [Terraform Download](https://www.terraform.io/downloads.html)
- [Visual Code Download](https://code.visualstudio.com/Download)
- [Powershell VS Code Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
- [HashiCorp Terraform VS Code Extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
- [Azure Terraform VS Code Extension Name](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)
- [Configure the Azure Terraform Visual Studio Code extension](https://docs.microsoft.com/en-us/azure/developer/terraform/configure-vs-code-extension-for-terraform)
- [Setup video](https://youtu.be/YmbmpGdhI6w)

</details>

## Reporting issues

Microsoft Support is not yet handling issues for any published tools in this repository. However, we would like to welcome you to open issues using GitHub [issues](https://github.com/Azure/avdaccelerator/issues) to collaborate and improve these tools.

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->