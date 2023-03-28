# Auto Increase Premium File Share Quota

This solution will deploy the Auto Increase Premium File Share Quota tool. This tool is an adaptation of the tool in the [Azure Files Samples repo](https://github.com/Azure-Samples/azure-files-samples/tree/master/autogrow-PFS-quota) created by Adam Groves.

Azure Files Premium is charged based on the size of the file share quota, not the amount of consumed storage like Azure Files Standard. This tool uses an Automation schedule to execute a runbook (PowerShell script) every 15 mins to check the file share quota. Once consumption reaches the specified threshold of the quota, the quota will be increased in the specified per GB increments. The threshold and scaling increments in GB can be customized. By default, the threshold is set to 50GB and the increment is 100 GB.

## Requirements

- Permissions: below are the minimum required roles on the target subscription to deploy this solution.
  - Automation Contributor
  - Log Analytics Contributor
  - Storage Contributor
  - User Access Administrator
- Resources: this solution assumes a storage account with a premium file share has already been deployed for FSLogix or MSIX App Attach.

## Deployment Options

### Azure portal UI

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployAutoIncreasePremiumFileShareQuota.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiAutoIncreasePremiumFileShareQuota.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fbrownfield%2FdeployAutoIncreasePremiumFileShareQuota.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiAutoIncreasePremiumFileShareQuota.json)

### PowerShell

```powershell
New-AzDeployment `
    -Location '<Azure location>' `
    -TemplateFile 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/arm/brownfield/deployAutoIncreasePremiumFileShareQuota.json' `
    -ActionGroupCustomName '<Name of the Action Group>' `
    -ApplicationNameTag '<Value for the Application Name tag>' `
    -AutomationAccountCustomName '<Name of the Automation Account>' `
    -CostCenterTag '<Value for the Cost Center tag>' `
    -CriticalityCustomTag '<Value for the custom Criticality tag>' `
    -CriticalityTag '<Value for the Criticality tag>' `
    -CustomNaming '<Bool for using custom naming>' `
    -DataClassificationTag '<Value for the Data Classification tag>' `
    -DepartmentTag '<Value for the Department tag>' `
    -DeploymentLocation '<Location to deploy the Azure resources>' `
    -DistributionGroup '<Email address for the distribution group>' `
    -EnableMonitoringAlerts '<Bool for enabling monitoring and alerts>' `
    -EnableResourceTags '<Bool for enabling tags>' `
    -EnvironmentTag '<Value for the Environment tag>' `
    -ExistingAutomationAccountResourceId '<Resource ID for the existing Automation Account>' `
    -ExistingLogAnalyticsWorkspaceResourceId '<Resource ID for the existing Log Analytics Workspace>' `
    -FileShareResourceId '<Resource ID for the existing Azure Files Premium share>' `
    -LogAnalyticsWorkspaceCustomName '<Name for the Log Analytics Workspace>' `
    -OperationsTeamTag '<Value for the Operations Team tag>' `
    -OwnerTag '<Value for the Owner tag>' `
    -QuotaIncreaseAmountInGb '<Amount to increase the file share quota>' `
    -QuotaIncreaseThresholdInGb '<Threshold to determine when to increase the file share quota>' `
    -ResourceGroupCustomName '<Name for the Resource Group>' `
    -SharedServicesSubscriptionId '<Subscription ID for the Shared Services subscription>' `
    -workloadNameTag '<Value for the Workload Name tag>' `
    -Verbose
```

### Azure CLI

```azurecli
az deployment sub create \
    --location '<Azure location>' \
    --template-uri 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/arm/brownfield/deployAutoIncreasePremiumFileShareQuota.json' \
    --parameters \
      ActionGroupCustomName '<Name of the Action Group>' \
      ApplicationNameTag '<Value for the Application Name tag>' \
      AutomationAccountCustomName '<Name of the Automation Account>' \
      CostCenterTag '<Value for the Cost Center tag>' \
      CriticalityCustomTag '<Value for the custom Criticality tag>' \
      CriticalityTag '<Value for the Criticality tag>' \
      CustomNaming '<Bool for using custom naming>' \
      DataClassificationTag '<Value for the Data Classification tag>' \
      DepartmentTag '<Value for the Department tag>' \
      DeploymentLocation '<Location to deploy the Azure resources>' \
      DistributionGroup '<Email address for the distribution group>' \
      EnableMonitoringAlerts '<Bool for enabling monitoring and alerts>' \
      EnableResourceTags '<Bool for enabling tags>' \
      EnvironmentTag '<Value for the Environment tag>' \
      ExistingAutomationAccountResourceId '<Resource ID for the existing Automation Account>' \
      ExistingLogAnalyticsWorkspaceResourceId '<Resource ID for the existing Log Analytics Workspace>' \
      FileShareResourceId '<Resource ID for the existing Azure Files Premium share>' \
      LogAnalyticsWorkspaceCustomName '<Name for the Log Analytics Workspace>' \
      OperationsTeamTag '<Value for the Operations Team tag>' \
      OwnerTag '<Value for the Owner tag>' \
      QuotaIncreaseAmountInGb '<Amount to increase the file share quota>' \
      QuotaIncreaseThresholdInGb '<Threshold to determine when to increase the file share quota>' \
      ResourceGroupCustomName '<Name for the Resource Group>' \
      SharedServicesSubscriptionId '<Subscription ID for the Shared Services subscription>' \
      workloadNameTag '<Value for the Workload Name tag>'
```
