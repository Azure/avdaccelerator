# Deploy AVD agents to VM

This solution will deploy the AVD agents to a VM.

## Requirements

- Permissions: below are the minimum required permissions to deploy this solution
  - Virtual machine contributor
  - Desktop Virtualization Host Pool Contributor
  - Key Vault Contributor
- Resources: this solution assumes the following items already exists:
  - Virtual Machine
  - Key Vault
  - Host pool

## Deployment Options

### Azure portal UI

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployAddAvdAgents.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiAddAvdAgents.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/?feature.deployapiver=2022-12-01#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployAddAvdAgents.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiAddAvdAgents.json)

### PowerShell

```powershell
New-AzSubscriptionDeployment `
    -Location '<Azure location>' `
    -TemplateFile 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/brownfield/addAvdAgents/deploy.bicep' `
    -vmLocation '<VM location>' `
    -vmResourceId '<resource ID of the VM where the AVD agents will be installed>' `
    -hostPoolResourceId '<resource ID of the host pool to which the VM will be registered>' `
    -keyVaultResourceId '<resource ID of the key vault where the host pool registration token will be stored>' `
    -Verbose


```

### Azure CLI

```azurecli
az deployment sub create \
    --location '<Azure location>' \
    --template-uri 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/brownfield/addAvdAgents/deploy.bicep' \
    --parameters \
        vmLocation '<VM location>' \
        vmResourceId '<resource ID of the VM where the AVD agents will be installed>' \
        hostPoolResourceId '<resource ID of the host pool to which the VM will be registered>' \
        keyVaultResourceId '<resource ID of the key vault where the host pool registration token will be stored>'
```
