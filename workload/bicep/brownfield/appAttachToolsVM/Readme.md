# Deploy Azure VM with App Attach Tools
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

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployAppAttachToolsVM.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiAppAttachToolsVM.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/?feature.deployapiver=2022-12-01#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployAppAttachToolsVM.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiAppAttachToolsVM.json)

### PowerShell

```powershell
# Set Variables
$TemplateUri = "https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/arm/brownfield/deployAppAttachToolsVM.json"
$Vnet = @{
    "name"             = '<Virtual NetworkName>'
    "id"               = '<Virtual Network Id>'
    "location"         = '<Azure location>'
    "subscriptionName" = '<Subscription Name>'
}
$TemplateParameterObject = @{
    "Location"        = '<Azure location>'
    "adminUsername"   = '<Local Admin User Name>'
    "adminPassUseKv"  = $false
    "adminPassword"   = <Clear Text Password>
    "publicIPAllowed" = '<$true or $false (Determines if NIC will have a Public IP Address)>'
    "OSoffer"         = 'Windows-11'
    "OSVersion"       = 'win11-23h2-ent'
    "SubnetName"      = '<Name of Subnet where VM will be attached.>'
    "vmDiskType"      = '<Standard_LRS, StandardSSD_LRS or Premium_LRS>'
    "vmName"          = '<Name for VM>'
    "VNet"            = $VNet
}
# Deploy Resources
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateUri -TemplateParameterObject $TemplateParameterObject -Verbose
```

### Azure CLI
```bash
# Set variables
templateUri="https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/arm/brownfield/deployAppAttachToolsVM.json"
resourceGroupName="<YourResourceGroupName>"
location="<AzureLocation>"
adminUsername="<LocalAdminUserName>"
adminPassword="<ClearTextPassword>"
publicIPAllowed="<true_or_false>"
osOffer="Windows-11"
osVersion="win11-23h2-ent"
subnetName="<SubnetName>"
vmDiskType="<Standard_LRS_StandardSSD_LRS_or_Premium_LRS>"
vmName="<VMName>"
vnetName="<VirtualNetworkName>"
vnetId="<VirtualNetworkId>"
subscriptionName="<SubscriptionName>"

# Deploy resources
az group deployment create \
    --resource-group $resourceGroupName \
    --template-uri $templateUri \
    --parameters \
        Location=$location \
        adminUsername=$adminUsername \
        adminPassword=$adminPassword \
        publicIPAllowed=$publicIPAllowed \
        OSoffer=$osOffer \
        OSVersion=$osVersion \
        SubnetName=$subnetName \
        vmDiskType=$vmDiskType \
        vmName=$vmName \
        VNet="{\"name\": \"$vnetName\", \"id\": \"$vnetId\", \"location\": \"$location\", \"subscriptionName\": \"$subscriptionName\"}"
```

