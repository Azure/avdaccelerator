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

[![Deploy to Azure (under construction)]()

### PowerShell

```powershell
New-AzSubscriptionDeployment `
    -Location '<Azure location>' `
    -TemplateFile 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/brownfield/addAvdAgents/deploy.bicep' `
    -computeSubscriptionId '<ID of the subscription where the VM was created>' `
    -computeRgResourceGroupName '<Resource group name where the VM was created>' `
    -vmLocation '<VM location>' `
    -vmName '<VM name>' `
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
        computeSubscriptionId '<ID of the subscription where the VM was created>' \
        computeRgResourceGroupName '<Resource group name where the VM was created>' \
        vmLocation '<VM location>' \
        vmName '<VM name>' \
        hostPoolResourceId '<resource ID of the host pool to which the VM will be registered>' \
        keyVaultResourceId '<resource ID of the key vault where the host pool registration token will be stored>'
```
