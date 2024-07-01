# Scaling Tool

This solution fully deploys the AVD Scaling Tool provided in the [Microsoft Learn documentation](https://docs.microsoft.com/azure/virtual-desktop/set-up-scaling-script). While AVD AutoScale (aka Scaling Plans) has replaced this solution, AutoScale is not available in every Azure cloud yet. In the Microsoft Learn documentation, the AVD Scaling Tool solution makes use of a webhook and a logic app. To ease the burden of the administrator, we have opted for Automation schedules and job schedules instead. Webhooks expire over time and have to be managed.

## Requirements

- Permissions: below are the minimum required roles on the target subscription to deploy this solution.
  - Automation Contributor
  - Log Analytics Contributor
  - User Access Administrator
- Resources: this solution assumes an AVD stamp, host pool and session hosts, already exist in your Azure environment.

## Deploy to Azure

### Azure Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%avm-migration%2Fworkload%2Farm%2Fbrownfield%2FdeployScalingTool.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%avm-migration%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiScalingTool.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%avm-migration%2Fworkload%2Farm%2Fbrownfield%2FdeployScalingTool.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%avm-migration%2Fworkload%2Fportal-ui%2Fbrownfield%2FportalUiScalingTool.json)

### PowerShell

````powershell
New-AzResourceGroupDeployment `
    -ResourceGroupName '<Resource Group Name>' `
    -TemplateFile 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/arm/brownfield/deployScalingTool.json' `
    -ActionGroupCustomName '<Custom name for action group>' `
    -ApplicationNameTag '<Tag for application name>' `
    -AutomationAccountCustomName '<Custom name for automation account>' `
    -BeginPeakTime '<Time when peak usage begins>' `
    -CostCenterTag '<Tag for cost center>' `
    -CriticalityCustomTag '<Tag for custom criticality>' `
    -CriticalityTag '<Tag for criticality>' `
    -CustomNaming '<Boolean to enable custom naming>' `
    -DataClassificationTag '<Tag for data classification>' `
    -DepartmentTag '<Tag for department>' `
    -DeploymentLocation '<Location for deployment>' `
    -DistributionGroup '<Email address>' `
    -EnableMonitoringAlerts '<Boolean to enable monitoring and alerts>' `
    -EnableResourceTags '<Boolean to enable resource tags>' `
    -EndPeakTime '<Time when peak usage ends>' `
    -EnvironmentTag '<Tag for environment>' `
    -ExistingAutomationAccountResourceId '<Resource ID for existing automation account>' `
    -ExistingHostPoolResourceId '<Resource ID for existing host pool>' `
    -ExistingLogAnalyticsWorkspaceResourceId '<Resource ID for existing log analytics workspace>' `
    -LimitSecondsToForceLogOffUser '<Number of seconds before users are force logged off>' `
    -LogAnalyticsWorkspaceCustomName '<Custom name for log analytics workspace>' `
    -MinimumNumberOfRdsh '<Minimum number of session hosts to scale down to during off peak time>' `
    -OperationsTeamTag '<Tag for operations team>' `
    -OwnerTag '<Tag for owner>' `
    -ResourceGroupCustomName '<Custom name for resource group>' `
    -SessionHostsResourceGroupName '<Name for session hosts resource group>' `
    -SessionThresholdPerCPU '<Number of sessions per CPU>' `
    -SharedServicesSubscriptionId '<Subscription ID for shared services subscription>' `
    -WorkloadNameTag '<Tag for workload name>' `
    -Verbose
````

### Azure CLI

````cli
az deployment group create \
    --resource-group '<Resource Group Name>' \
    --template-uri 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/arm/brownfield/deployScalingTool.json' \
    --parameters \
        ActionGroupCustomName='<Custom name for action group>' \
        ApplicationNameTag='<Tag for application name>' \
        AutomationAccountCustomName='<Custom name for automation account>' \
        BeginPeakTime='<Time when peak usage begins>' \
        CostCenterTag='<Tag for cost center>' \
        CriticalityCustomTag='<Tag for custom criticality>' \
        CriticalityTag='<Tag for criticality>' \
        CustomNaming='<Boolean to enable custom naming>' \
        DataClassificationTag='<Tag for data classification>' \
        DepartmentTag='<Tag for department>' \
        DeploymentLocation='<Location for deployment>' \
        DistributionGroup='<Email address>' \
        EnableMonitoringAlerts='<Boolean to enable monitoring and alerts>' \
        EnableResourceTags='<Boolean to enable resource tags>' \
        EndPeakTime='<Time when peak usage ends>' \
        EnvironmentTag='<Tag for environment>' \
        ExistingAutomationAccountResourceId='<Resource ID for existing automation account>' \
        ExistingHostPoolResourceId='<Resource ID for existing host pool>' \
        ExistingLogAnalyticsWorkspaceResourceId='<Resource ID for existing log analytics workspace>' \
        LimitSecondsToForceLogOffUser='<Number of seconds before users are force logged off>' \
        LogAnalyticsWorkspaceCustomName='<Custom name for the log analytics workspace>' \
        MinimumNumberOfRdsh='<Minimum number of session hosts to scale down to during off peak time>' \
        OperationsTeamTag='<Tag for operations team>' \
        OwnerTag='<Tag for owner>' \
        ResourceGroupCustomName='<Custom name for resource group>' \
        SessionHostsResourceGroupName='<Name for session hosts resource group>' \
        SessionThresholdPerCPU='<Number of sessions per CPU>' \
        SharedServicesSubscriptionId='<Subscription ID for shared services subscription>' \
        WorkloadNameTag='<Tag for workload name>'
````
