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
| dns_zones.tf               | This file creates the private DNS zone and links |
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

- 20 x azurerm_log_analytics_datasource_windows_performance_counter
- 9 x azurerm_log_analytics_datasource_windows_event
- 5 x azurerm_resource_group
- 4 x azurerm_role_assignment
- 2 x azurerm_network_interface
- 2 x azurerm_private_dns_zone_virtual_network_link
- 2 x azurerm_subnet
- 1 x azurerm_application_security_group
- 1 x azurerm_firewall_policy_rule_collection_group
- 1 x azurerm_key_vault
- 1 x azurerm_key_vault_access_policy
- 1 x azurerm_key_vault_secret
- 1 x azurerm_network_security_group
- 1 x azurerm_storage_account_network_rules
- 1 x azurerm_subnet_network_security_group_association
- 1 x azurerm_user_assigned_identity
- 1 x azurerm_virtual_desktop_application_group
- 1 x azurerm_virtual_desktop_host_pool
- 1 x azurerm_virtual_desktop_workspace
- 1 x azurerm_virtual_desktop_workspace_application_group_association
- 1 x azurerm_virtual_network

Generated by: [Infracost](https://www.infracost.io/)
</details>
