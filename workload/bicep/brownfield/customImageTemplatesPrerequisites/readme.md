# Custom Image Templates (CIT) Prerequisites

This solution will deploy the prerequisites for AVD Custom Image Templates as described in the following article:

[Use custom image templates to create custom images in Azure Virtual Desktop | Microsoft Learn](https://learn.microsoft.com/en-us/azure/virtual-desktop/create-custom-image-templates)

## Requirements

- Permissions: below are the minimum required roles on the target subscription to deploy this solution.
  - Owner

## Deployment Options

### Azure Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployCustomImageTemplatesPrerequisites.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiCustomImageTemplatesPrerequisites.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/?feature.deployapiver=2022-12-01#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployCustomImageTemplatesPrerequisites.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjamasten%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiCustomImageTemplatesPrerequisites.json)

### PowerShell

````powershell
New-AzDeployment `
    -Location '<Azure location>' `
    -TemplateFile 'https://raw.githubusercontent.com/jamasten/avdaccelerator/main/workload/arm/brownfield/deployCustomImageTemplatesPrerequisites.json' `
    -Verbose
````

### Azure CLI

````cli
az deployment sub create \
    --location '<Azure location>' \
    --template-uri 'https://raw.githubusercontent.com/jamasten/avdaccelerator/main/workload/arm/brownfield/deployCustomImageTemplatesPrerequisites.json'
````
