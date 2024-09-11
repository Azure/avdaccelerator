# Custom Image Templates (CIT) Prerequisites

This solution will deploy the prerequisites for AVD Custom Image Templates as described in the following article:

[Use custom image templates to create custom images in Azure Virtual Desktop | Microsoft Learn](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-custom-image-templates)

## Requirements

- Permissions: below are the minimum required roles on the target subscription to deploy this solution.
  - 
  - 
  - 

## Deployment Options

To deploy this solution, the principal must have Owner privileges on the Azure subscription.

### Azure Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAVD-CIT-Prereqs%2Fmain%2Fsolution.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAVD-CIT-Prereqs%2Fmain%2FuiDefinition.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAVD-CIT-Prereqs%2Fmain%2Fsolution.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2FAVD-CIT-Prereqs%2Fmain%2FuiDefinition.json)

### PowerShell

````powershell
New-AzDeployment `
    -Location '<Azure location>' `
    -TemplateFile 'https://raw.githubusercontent.com/jamasten/AVD-CIT-Prereqs/main/solution.json' `
    -Verbose
````

### Azure CLI

````cli
az deployment sub create \
    --location '<Azure location>' \
    --template-uri 'https://raw.githubusercontent.com/jamasten/AVD-CIT-Prereqs/main/solution.json'
````
