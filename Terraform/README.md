## Terraform for Azure Virtual Desktop 

The purpose of this repository is to demonstrate using Terraform to deploy an Azure Virtual Desktop environment. For Classic Azure Virtual Desktop click [here](https://github.com/Azure/RDS-Templates/tree/master/wvd-sh/terraform-azurerm-windowsvirtualdesktop).

## Requirements and limitations 
* Ensure that you meet the [requirements for Azure Virtual Desktop](https://docs.microsoft.com/en-us/azure/virtual-desktop/overview#requirements) 
* Terraform must be installed and configured as outlined [here](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell)
* Active Directory already in place in this example, we are using AD in it’s own VNet.  
* Users in AAD that will be given access to AVD
* This demo does not support Azure ADDS only deployment
* Destroy could produce errors deleting subnet due to resources associated. Manually delete resources within the subnet before running destroy

## Components

* Azure Virtual Desktop Environment 
* Networking Infrastructure 
* Session Hosts 
* Profile Storage 
* Role Based Access Control
* Azure Compute Gallery
* Log Analytics Workspace 

## Features

This directory contains the various components for building out Azure Virtual Desktop.
* `main.tf` deploys modules: storage, shared image gallery, log analytics and azure virtual desktop
* `provider.tf`Azure RM and Azure AD provider configuration
* `outputs.tf`defines the outputs that will be displayed on deployment
* `variables.tf` Input variables
* `prereq/backendsetup.md` details setting up backend on Azure blob storage
* `modules/avd`
  * `main.tf` 	deploys a new workspace, hostpool, application group with associations
  * `networking.tf` deploys a new vnet, subnet, nsg and peering to AD vnet
  * `host.tf` deploys new session host from the marketplace build and join to domain
  * `rbac.tf` deploys rbac assignment for the users group
  * `variables.tf` Input variables 
* `modules/SIG`
  * `main.tf`  
  * `variables.tf` Input variables 
* `modules/storage`
  * `main.tf` deploys Azure Files storage for profiles and creates file share with RBAC permissions for the users group ([NTFS permissions will need to be configured](https://docs.microsoft.com/en-us/azure/virtual-desktop/create-file-share))
  * `random.tf` Random provider configuration. Random suffix is used to ensure globally unique names
  * `variables.tf` Input variables
* `modules/log-analytics.tf`
  * `main.tf` deploys log anaylytics workspace
  * `random.tf`	Random provider configuration. Random suffix is used to ensure globally unique names
  * `variables.tf` Input variables 	

## Variable Inputs
[Variable Inputs](https://github.com/jensheerin/AVD-Terraform-modules/blob/master/USAGE.md#inputs)
## Deploy
If you’ve not previously setup terraform, check out this article to get it installed [Quickstart - Configure Terraform using Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell) 


Once Terraform is setup and you have created your Terraform templates, the first step is to initialize Terraform. This step ensures that Terraform has all the prerequisites to build your template in Azure. 

```
terraform init
```

The next step is to have Terraform review and validate the template. An execution plan is generated and stored in the file specified by the -out parameter. 

We also need to pass our variable definitions file during the plan.   We can either load it automatically by renaming env.tfvars as terraform.tfvars OR env.auto.tfvars, in which case we will use the following to create the execution plan: 

```bash
terraform plan -out terraform_azure.tfplan
```

When you're ready to build the infrastructure in Azure, apply the execution plan: 

```bash
terraform apply terraform_azure.tfplan
```

## Final Configuration

You’ll notice we didn’t actually configure the session hosts to use our profile storage at any point.  There is an assumption that we are using GPO to manage FSLogix across our host pools as documented here: [Use FSLogix Group Policy Template Files - FSLogix](https://docs.microsoft.com/en-us/fslogix/use-group-policy-templates-ht).  

At a minimum you’ll need to configure the registry keys to enable FSLogix and configure the VHD Location to the NetApp Share URI: [Profile Container registry configuration settings - FSLogix](https://docs.microsoft.com/en-us/fslogix/profile-container-configuration-reference#enabled) 

## Troubleshooting Terraform deployment 
<details>
<summary>Click to expand</summary>
Terraform deployment can fail in two main categories: 

Issues with Terraform code 
1. [Issues with Desired State Configuration (DSC)](#issues-with-desired-state-configuration-dsc)
2. [Issues with Terraform code](#issues-with-desired-state-configuration-dsc)
 
While it is rare to have issues with the Terraform code it is still possible, however most often errors are due to bad input in variables.tf. 

* If there are errors in the Terraform code, please file a GitHub issue. 
* If there are warning in the Terraform code feel free to ignore or address for your own instance of that code. 
* Using Terraform error messages it's a good starting point towards identifying issues with input variables 
 
### Issues with Desired State Configuration (DSC) 

To troubleshoot this type of issue, navigate to the Azure portal and if needed reset the password on the VM that failed DSC. Once you are able to log in to the VM review the log files in the following two folders: 
</details>

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

## License
This project is published under the MIT license. See [LICENSE.md](https://github.com/jensheerin/AVD-Terraform-modules/blob/master/LICENSE) for details.