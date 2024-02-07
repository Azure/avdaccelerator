# Azure Virtual Desktop Accelerator for Terraform Guide

This guide is designed to help you get started with deploying Azure Virtual Desktop using the provided Terraform template(s) within this repository. Before you deploy, it is recommended to review the template(s) to understand the resources that will be deployed and the associated costs.

This accelerator is to be used as starter kit and you can expand its functionality by developing your own deployments. This scenario deploys a new Azure Virtual Desktop workload, so it cannot be used to maintain, modify or add resources to an existing or already deployed Azure Virtual Desktop workload from this accelerator.

***Note*** This terraform accelerator requires the Custom Image Build before deploying the Baseline. If you prefer to use the marketplace image with no customization [see](https://learn.microsoft.com/azure/developer/terraform/create-avd-session-host)

## Table of Contents

- [Prerequisites](#prerequisites)  
- [Planning](#planning)
- [Terraform Implementation](#terraform-implementation)
- [Backend Setup](#backends)  
- [Deployment Steps](#deployment-steps)  

This guide describes how to deploy Azure Virtual Desktop Accelerator using the [Terraform](https://www.terraform.io/).
To get started with Terraform on Azure check out their [tutorial](https://learn.hashicorp.com/collections/terraform/azure-get-started/).

## Prerequisites

- Meet the prerequisites listed [here](../../docs/getting-started-baseline.md)
- Current version of the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Current version of the Terraform CLI
- An Azure Subscription(s) where you or an identity you manage has `Owner` [RBAC permissions](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#owner)
- Ensure Encryption at Host feature is already enabled on the subscription. To enable: az feature register --name EncryptionAtHost  --namespace Microsoft.Compute. To validate: az feature show --name EncryptionAtHost --namespace Microsoft.Compute

## Planning

### Decide on a Prefix

The deployments will require a "Prefix" which will be included in all the deployed resources name.
Resource Groups and resource names are derived from the `Prefix` parameter. Pick a unique resource prefix that is 3-5 alphanumeric characters in length without whitespaces.

## Terraform Implementation

This folder contains Terraform modules for deploying AVD Landing Zone. It is expected that users will have a strong understanding of Terraform concepts and will make any necessary modifications to fit their environment when using these modules.

## Terraform Folder Structure

This folder is laid out hierarchically so that different levels of modules may be used as needed for your purpose.  A summary of each level of the folder structure follows.

| Folder Name         | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| [modules](../modules)            | This folder contains re-usable modules that create infrastructure components that are used to compose more complex scenarios |
| [ADDS scenarios (ADDSscenario)](./ADDSscenario/readme.md)  | This folder contains scenario root modules that deploy AVD with ADDS join session host. |
| [Microsoft Entra Domain Services (AADDSscenario)](./AADDSscenario/readme.md)  | This folder contains scenario root modules that deploy AVD with ADDS join session host. |
| [Microsoft Entra ID scenarios (AADscenario)](./AADscenario/readme.md)  | This folder contains scenario root modules that deploy AVD with Microsoft Entra ID join session host. |
| [EntraID Zero Trust scenarios (zerotrust)](./zerotrust/readme.md)  | This folder contains scenario root modules that deploy AVD with Microsoft Entra ID join session host following zero trust principles. |

<details>
<summary>Click to expand</summary>

## Backends

The default templates write a state file directly to disk locally to where you are executing terraform from. If you wish to AzureRM backend please see [AzureRM Backend](https://www.terraform.io/docs/language/settings/backends/azurerm.html). This deployment highlights using Azure Blog Storage to store state file and Key Vault.

### Backends using Azure Blob Storage

#### Using Azure CLI

[Store state in Azure Storage](https://learn.microsoft.com/azure/developer/terraform/store-state-in-azure-storage)

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

[Create Key Vault](https://learn.microsoft.com/azure/key-vault/secrets/quick-create-cli)

```cli
az keyvault create --name "<Azure Virtual Desktopkeyvaultdemo>" --resource-group $RESOURCE_GROUP_NAME --location "<East US>"
```

#### Add storage account access key to key vault

```cli
az keyvault secret set --vault-name "<Azure Virtual Desktopkeyvaultdemo>" --name terraform-backend-key --value "<W.........................................>"
```

</details>

## Deployment Steps

1. Modify the `terraform.tfvars` file to define the desired names, location, networking, and other variables
2. Before deploying, confirm the correct subscription
3. Change directory to the Terraform folder
4. Run `terraform init` to initialize this directory
5. Run `terraform plan` to view the planned deployment
5. Run `terraform apply` to confirm the deployment

## Additional References

<details>
<summary>Click to expand</summary>

- [Terraform Download](https://www.terraform.io/downloads.html)
- [Visual Code Download](https://code.visualstudio.com/Download)
- [Powershell VS Code Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
- [HashiCorp Terraform VS Code Extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
- [Azure Terraform VS Code Extension Name](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureterraform)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli-windows?tabs=azure-cli
- [Configure the Azure Terraform Visual Studio Code extension](https://learn.microsoft.com/azure/developer/terraform/configure-vs-code-extension-for-terraform?tabs=azure-cli)
- [Setup video](https://youtu.be/YmbmpGdhI6w)

</details>

## Reporting issues

Microsoft Support is not yet handling issues for any published tools in this repository. We would welcome you to open issues using GitHub [issues](https://github.com/Azure/avdaccelerator/issues) to collaborate and improve these tools.