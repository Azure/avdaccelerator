# Deploy New Session Hosts

This solution will deploy new session hosts to an existing host pool.

## Requirements

- Permissions: below are the minimum required permissions to deploy this solution
  - User Access Administrator on the target Subscription
  - Desktop Virtualization Host Pool Contributor on the resource group containing the target host pool
- Resources: this solution assumes the following items already exists:
  - Resource group where session hosts will be deployed (created by AVD LZA baseline)
  - Host pool with an active registration token (created by AVD LZA baseline)
  - Key vault with the following secrets (created by AVD LZA baseline):
    - VM local admin user password
    - Domain join account password
    - Disk encrpyption key (when enabling zero trust for session hosts)
  - Virtual network for session hosts (created by AVD LZA baseline)
  - Optional: application security group for session hosts (created by AVD LZA baseline)
  - Storage account and file share configured for fslogix (created by AVD LZA baseline)
  - Optional: log analytics workspace configured with Azure Virtual Desktop insights settings (created by AVD LZA baseline)
  - Optional: VMSS flex for the session hosts (created by AVD LZA baseline)

## Deployment Options

### Azure portal UI

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployNewSessionHostsToHostPools.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiNewSessionHosts.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployNewSessionHostsToHostPools.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiNewSessionHosts.json)

### PowerShell

```powershell
New-AzDeployment `
    -Location '<Azure location>' `
    -TemplateFile 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/brownfield/deployNewSessionHostsToHostPools.json' `
    -computeSubscriptionId '<Subscription ID>' `
    -computeRgResourceGroupName '<AVD pool compute resource group>' `
    -countIndex '<Current count of session hosts in the host pool>' `
    -count '<Number of new session hosts to deploy>' `
    -hostPoolResourceId '<Existing host pool resource ID>' `
    -subnetResourceId '<Resource ID of subnet to use for the new session hosts>' `
    -location '<Azure region to deploy new session hosts to>' `
    -vmLocalUserName '<Local admin user name>' `
    -keyVaultResourceId '<Resource ID of the key vault that contains the local admin password secret>' `
    -Verbose


```

### Azure CLI

```azurecli
az deployment sub create \
    --location '<Azure location>' \
    --template-uri 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/brownfield/deployNewSessionHostsToHostPools.json' \
    --parameters \
        computeSubscriptionId '<Subscription ID>' \
        computeRgResourceGroupName '<AVD pool compute resource group>' \
        countIndex '<Current count of session hosts in the host pool>' \
        count '<Number of new session hosts to deploy>' \
        hostPoolResourceId '<Existing host pool resource ID>' \
        subnetResourceId '<Resource ID of subnet to use for the new session hosts>' \
        location '<Azure region to deploy new session hosts to>' \
        vmLocalUserName '<Local admin user name>' \
        keyVaultResourceId '<Resource ID of the key vault that contains the local admin password secret>' \
        HostPoolResourceId '<Resource ID for the target host pool>'
```
