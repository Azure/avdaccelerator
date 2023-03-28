# Start VM On Connect

This solution will deploy Start VM On Connect. The feature allows stopped / deallocated VMs to be started on demand when an end user requests a session host from their assigned application group using the AVD client. For more details, see the Microsoft Learn page for this feature: [Start VM On Connect](https://learn.microsoft.com/azure/virtual-desktop/start-virtual-machine-connect?tabs=azure-portal).

## Requirements

- Permissions: below are the minimum required permissions to deploy this solution.
  - User Access Administrator on the target Subscription
  - Desktop Virtualization Host Pool Contributor on the resource group containing the target host pool
- Resources: this solution assumes a host pool already exists in the target subscription.

## Deployment Options

### Azure portal UI

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployStartVmOnConnect.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiStartVmOnConnect.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployStartVmOnConnect.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiStartVmOnConnect.json)

### PowerShell

```powershell
New-AzDeployment `
    -Location '<Azure location>' `
    -TemplateFile 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/brownfield/startVmOnConnect/solution.json' `
    -AvdObjectId '<Object ID for the AVD / WVD application in Azure AD>' `
    -HostPoolResourceId '<Resource ID for the target host pool>' `
    -Verbose
```

### Azure CLI

```azurecli
az deployment sub create \
    --location '<Azure location>' \
    --template-uri 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/brownfield/startVmOnConnect/solution.json' \
    --parameters \
        AvdObjectId '<Object ID for the AVD / WVD application in Azure AD>' \
        HostPoolResourceId '<Resource ID for the target host pool>'
```
