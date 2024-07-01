# Deploy Azure VM with MSIX App Attach Tools
This deployment will create a VM from the Microsoft Gallery and configure and install software for use when creating MSIX App attach images.
- MSIX App Attach Store App
- MSIX Manager command line tool
- PSFTooling App
- Disables Plug and Play service (prevents new disk pop-up when mounting VHDs)
- Creates C:\MSIX directory with apps and script to convert MSIX to VHD
- Creates a self-signed certificate and places it within the "Trusted People Store" for signing packages
  (Consider a Certificate from a Certificate Authority for Production Use)

## Pre-requisites

- Azure Tenant and Subscription
- Resource Group
- VNet and Subnet

## Deployment

The easiest method is to configure the deployment via the provided blue buttons as they include the custom UI for configuring the options.  However, you can also utilize PowerShell and the Azure CLI.

### Azure Portal UI

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%avm-migration%2Fworkload%2Farm%2Fbrownfield%2FdeployAppAttachToolsVM.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%avm-migration%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiAppAttachToolsVM.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%avm-migration%2Fworkload%2Farm%2Fbrownfield%2FdeployAppAttachToolsVM.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%avm-migration%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiAppAttachToolsVM.json)

### PowerShell

```powershell
New-AzDeployment `
    -Location '<Azure location>' `
    -TemplateFile 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/arm/brownfield/deployAppAttachToolsVM.json' `
    -adminUsername '<Local Admin User Name>' `
    -adminPassUseKv false `
    -adminPassword '<Password for Local Admin Account>' `
    -publicIPAllowed '<true or false (Determines if NIC will have a Public IP Address)>' `
    -OSoffer 'WindowsDesktop' `
    -SubnetName '<Name of Subnet where VM will be attached.>' `
    -vmDiskType '<Standard_LRS, StandardSSD_LRS or Premium_LRS>' `
    -vmName '<Name for VM>' `
    -VNet '<Object value surrounded by {} with comma seperated key pairs for desired VNet name, id, location and subscriptionName>' `
    -Verbose
```

### Azure CLI

```azurecli
az deployment sub create \
    --location '<Azure location>' \
    --template-uri 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/arm/brownfield/deployAppAttachToolsVM.json' \
    --parameters \
    -adminUsername '<Local Admin User Name>' \
    -adminPassUseKv false \
    -adminPassword '<Password for Local Admin Account>' \
    -publicIPAllowed '<true or false (Determines if NIC will have a Public IP Address)>' \
    -OSoffer 'WindowsDesktop' \
    -SubnetName '<Name of Subnet where VM will be attached.>' \
    -vmDiskType '<Standard_LRS, StandardSSD_LRS or Premium_LRS>' \
    -vmName '<Name for VM>' \
    -VNet '<Object value surrounded by {} with comma seperated key pairs for desired VNet name, id, location and subscriptionName>'
```