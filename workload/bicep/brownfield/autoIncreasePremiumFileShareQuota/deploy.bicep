targetScope = 'subscription'


// ========== //
// Parameters //
// ========== //

@description('Optional. Custom name for Action Group.')
param actionGroupCustomName string = 'ag-scale'

@description('Optional. Details about the application.')
param applicationNameTag string = 'Contoso-App'

@description('Optional. Custom name for the Automation Account.')
param automationAccountCustomName string = 'aa-avd'

@description('Optional. Cost center of owner team. (Default: Contoso-CC)')
param costCenterTag string = 'Contoso-CC'

@description('Optional. Tag value for custom criticality value. (Default: Contoso-Critical)')
param criticalityCustomTag string = 'Contoso-Critical'

@allowed([
  'Low'
  'Medium'
  'High'
  'Mission-critical'
  'custom'
])
@description('Optional. criticality of each workload. (Default: Low)')
param criticalityTag string = 'Low'

@description('Optional. Determine whether to enable custom naming for the Azure resources. (Default: false)')
param customNaming bool = false

@allowed([
  'Non-business'
  'Public'
  'General'
  'Confidential'
  'Highly confidential'
])
@description('Optional. Sensitivity of data hosted (Default: Non-business)')
param dataClassificationTag string = 'Non-business'

@description('Optional. Department that owns the deployment, (Dafult: Contoso-AVD)')
param departmentTag string = 'Contoso-AVD'

@description('Optional. Location where to deploy the tool.')
param deploymentLocation string = deployment().location

@description('Optional. Input the email distribution list for alert notifications when AIB builds succeed or fail.')
param distributionGroup string = ''

@description('Optional. Set to deploy monitoring and alerts for the auto increase automation (Default: false).')
param enableMonitoringAlerts bool = false

@description('Optional. Apply tags on resources and resource groups. (Default: false)')
param enableResourceTags bool = false

@allowed([
    'Prod'
    'Dev'
    'Staging'
])
@description('Optional. Deployment environment of the application, workload. (Default: Dev)')
param environmentTag string = 'Dev'

@description('Optional. Existing Azure log analytics workspace resource ID to capture runbook execution logs. (Default: )')
param existingAutomationAccountResourceId string = ''

@description('Optional. Existing Azure log analytics workspace resource ID to capture runbook execution logs. (Default: )')
param existingLogAnalyticsWorkspaceResourceId string = ''

@description('Required. The resource ID for the file share on a Premium Storage Account.')
param fileShareResourceId string

@description('Optional. Custom name for the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomName string = 'log-avd'

@description('Optional. Team accountable for day-to-day operations. (Contoso-Ops)')
param operationsTeamTag string = 'workload-admins@Contoso.com'

@description('Optional. Organizational owner of the AVD deployment. (Default: Contoso-Owner)')
param ownerTag string = 'workload-owner@Contoso.com'

@description('Optional. The amount to increase the file share quota by in GB.')
param quotaIncreaseAmountInGb int = 100

@description('Optional. The threshold in GB that determines when to increase the file share quota.')
param quotaIncreaseThresholdInGb int = 50

@maxLength(90)
@description('Optional. Custom name for Resource Group. (Default: rg-avd-use2-shared-services)')
param resourceGroupCustomName string = 'rg-avd-shared'

@description('Required. AVD shared services subscription ID, multiple subscriptions scenario.')
param sharedServicesSubscriptionId string = subscription().subscriptionId

@description('ISO 8601 timestamp used for the deployment names and the Automation runbook schedule.')
param time string = utcNow()

@description('Optional. Reference to the size of the VM for your workloads (Default: Contoso-Workload)')
param workloadNameTag string = 'Contoso-Workload'


// =========== //
// Variables   //
// =========== //

var varActionGroupName = customNaming ? actionGroupCustomName : 'ag-avd-${varNamingStandard}'
var varAlerts = enableMonitoringAlerts ? [
  {
      name: 'Azure Files Premium - Share Quota Scaling Failed'
      description: 'Sends an error alert when the runbook fails to execute.'
      severity: 0
      evaluationFrequency: 'PT5M'
      windowSize: 'PT5M'
      criterias: {
          allOf: [
              {
                  query: 'AzureDiagnostics\n| where ResourceProvider == "MICROSOFT.AUTOMATION"\n| where Category  == "JobStreams"\n| where ResultDescription has "Image Template build failed"'
                  TimeAggregation: 'Count'
                  dimensions: [
                      {
                          name: 'ResultDescription'
                          operator: 'Include'
                          values: [
                              '*'
                          ]
                      }
                  ]
                  operator: 'GreaterThanOrEqual'
                  threshold: 1
                  failingPeriods: {
                      numberOfEvaluationPeriods: 1
                      minFailingPeriodsToAlert: 1
                  }
              }
          ]
      }
  }
  {
    name: 'Azure Files Premium - Share Quota Increased'
      description: 'Sends an informational alert when the file share quota has increased.'
      severity: 3
      evaluationFrequency: 'PT5M'
      windowSize: 'PT5M'
      criterias: {
          allOf: [
              {
                  query: 'AzureDiagnostics\n| where ResourceProvider == "MICROSOFT.AUTOMATION"\n| where Category  == "JobStreams"\n| where ResultDescription has "New Capacity"'
                  TimeAggregation: 'Count'
                  dimensions: [
                      {
                          name: 'ResultDescription'
                          operator: 'Include'
                          values: [
                              '*'
                          ]
                      }
                  ]
                  operator: 'GreaterThanOrEqual'
                  threshold: 1
                  failingPeriods: {
                      numberOfEvaluationPeriods: 1
                      minFailingPeriodsToAlert: 1
                  }
              }
          ]
      }
  }
] : []
var varAutomationAccountName = customNaming ? automationAccountCustomName : 'aa-avd-${varNamingStandard}'
var varAutomationAccountScope = empty(existingAutomationAccountResourceId) ? varResourceGroupName : varExistingAutomationAccountResourceGroupName
var varCommonResourceTags = enableResourceTags ? {
  WorkloadName: workloadNameTag
  DataClassification: dataClassificationTag
  Department: departmentTag
  Criticality: (criticalityTag == 'Custom') ? criticalityCustomTag : criticalityTag
  ApplicationName: applicationNameTag
  OpsTeam: operationsTeamTag
  Owner: ownerTag
  CostCenter: costCenterTag
  Environment: environmentTag
} : {}
var varExistingAutomationAccountName = empty(existingAutomationAccountResourceId) ? '' : split(existingAutomationAccountResourceId, '/')[8]
var varExistingAutomationAccountResourceGroupName = empty(existingAutomationAccountResourceId) ? '' :  split(existingAutomationAccountResourceId, '/')[4]
var varFileShareName = split(fileShareResourceId, '/')[12]
var varJobScheduleParameters = {
  EnvironmentName: environment().name
  FileShareName: varFileShareName
  QuotaIncreaseAmountInGb: quotaIncreaseAmountInGb
  QuotaIncreaseThresholdInGb: quotaIncreaseThresholdInGb
  StorageAccountName: varStorageAccountName
  StorageAccountResourceGroupName: varStorageAccountResourceGroupName
  StorageAccountSubscriptionId: varStorageAccountSubscriptionId
  TenantId: subscription().tenantId
}
var varLocationAcronym = varLocations[varLocation].acronym
var varLocations = loadJsonContent('../../../variables/locations.json')
var varLocation = toLower(replace(deploymentLocation, ' ', ''))
var varLogAnalyticsWorkspaceName = customNaming ? logAnalyticsWorkspaceCustomName : 'log-avd-${varNamingStandard}'
var varNamingStandard = '${varLocationAcronym}'
var varResourceGroupName = customNaming ? resourceGroupCustomName : 'rg-avd-${varNamingStandard}-shared-services'
var varRunbookName = 'Auto-Increase-Premium-File-Share-Quota'
var varScheduleName = '${varStorageAccountName}_${varFileShareName}_'
var varStorageAccountName = split(fileShareResourceId, '/')[8]
var varStorageAccountResourceGroupName = split(fileShareResourceId, '/')[4]
var varStorageAccountSubscriptionId = split(fileShareResourceId, '/')[2]
var varTimeZone = varLocations[varLocation].timeZone


// =========== //
// Deployments //
// =========== //

// AVD Shared Services Resource Group
module avdSharedResourcesRg '../../../../carml/1.3.0/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  scope: subscription(sharedServicesSubscriptionId)
  name: 'RG-${time}'
  params: {
      name: varResourceGroupName
      location: deploymentLocation
      tags: enableResourceTags ? varCommonResourceTags : {}
  }
}

// Log Analytics Workspace
module workspace '../../../../carml/1.3.0/Microsoft.OperationalInsights/workspaces/deploy.bicep' = if (enableMonitoringAlerts && empty(existingLogAnalyticsWorkspaceResourceId)) {
  scope: resourceGroup(sharedServicesSubscriptionId, varResourceGroupName)
  name: 'LA-Workspace-${time}'
  params: {
      location: deploymentLocation
      name: varLogAnalyticsWorkspaceName
      dataRetention: 30
      useResourcePermissions: true
      tags: enableResourceTags ? varCommonResourceTags : {}
  }
  dependsOn: [
      avdSharedResourcesRg
  ]
}

// Get existing automation account
module automationAccount_Existing 'modules/existingAutomationAccount.bicep' = if(!(empty(existingAutomationAccountResourceId))) {
  name: 'Existing-AA-${time}'
  scope: resourceGroup(sharedServicesSubscriptionId, varAutomationAccountScope)
  params:{
    automationAccountName: varExistingAutomationAccountName
  }
}

// Deploy new automation account
module automationAccount_New '../../../../carml/1.3.0/Microsoft.Automation/automationAccounts/deploy.bicep' = {
  scope: resourceGroup(sharedServicesSubscriptionId, varAutomationAccountScope)
  name: 'AA-${time}'
  params: {
    diagnosticLogCategoriesToEnable: [
      'JobLogs'
      'JobStreams'
    ]
    diagnosticLogsRetentionInDays: 30
    diagnosticWorkspaceId: empty(existingLogAnalyticsWorkspaceResourceId) ? workspace.outputs.resourceId : existingLogAnalyticsWorkspaceResourceId
    name: empty(existingAutomationAccountResourceId) ? varAutomationAccountName : automationAccount_Existing.outputs.name
    jobSchedules: [
      {
        parameters: varJobScheduleParameters
        runbookName: varRunbookName
        scheduleName: '${varScheduleName}0'
      }
      {
        parameters: varJobScheduleParameters
        runbookName: varRunbookName
        scheduleName: '${varScheduleName}1'
      }
      {
        parameters: varJobScheduleParameters
        runbookName: varRunbookName
        scheduleName: '${varScheduleName}2'
      }
      {
        parameters: varJobScheduleParameters
        runbookName: varRunbookName
        scheduleName: '${varScheduleName}3'
      }
    ]
    location: deploymentLocation
    runbooks: [
      {
        name: varRunbookName
        description: 'When this runbook is triggered, the quota on the Azure Files Premium is checked. If the quota is within the defined threshold, the quota is increased based on the defined increment.'
        type: 'PowerShell'
        // To Do: Update URL to Azure repo
        uri: 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Set-AzureFilesPremiumShareQuota.ps1'
        version: '1.0.0.0'
      }
    ]
    schedules: [
      {
        name: '${varScheduleName}0'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT15M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}1'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT30M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}2'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT45M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
      {
        name: '${varScheduleName}3'
        frequency: 'Hour'
        interval: 1
        startTime: dateTimeAdd(time, 'PT60M')
        TimeZone: varTimeZone
        advancedSchedule: {}
      }
    ]
    skuName: empty(existingAutomationAccountResourceId) ? 'Free' : automationAccount_Existing.outputs.properties.sku.name
    tags: !(empty(existingAutomationAccountResourceId)) ? automationAccount_Existing.outputs.tags : enableResourceTags ? varCommonResourceTags : {}
    systemAssignedIdentity: true
  }
}

// Role assignment
module roleAssignments '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = {
  name: 'Role-Assignment-${time}'
  scope: resourceGroup(varStorageAccountSubscriptionId, varStorageAccountResourceGroupName)
  params: {
      roleDefinitionIdOrName: 'Storage Account Contributor'
      principalId: automationAccount_New.outputs.systemAssignedPrincipalId
      principalType: 'ServicePrincipal'
  }
}

// Alerts action group
module actionGroup '../../../../carml/1.3.0/Microsoft.Insights/actionGroups/deploy.bicep' = if (enableMonitoringAlerts) {
  scope: resourceGroup(sharedServicesSubscriptionId, varResourceGroupName)
  name: 'Action-Group-${time}'
  params: {
      location: 'global'
      groupShortName: 'aib-email'
      name: varActionGroupName
      enabled: true
      emailReceivers: [
          {
              name: distributionGroup
              emailAddress: distributionGroup
              useCommonAlertSchema: true
          }
      ]
      tags: enableResourceTags ? varCommonResourceTags : {}
  }
  dependsOn: [
      avdSharedResourcesRg
  ]
}

// Scheduled query rules
module scheduledQueryRules '../../../../carml/1.3.0/Microsoft.Insights/scheduledQueryRules/deploy.bicep' = [for i in range(0, length(varAlerts)): if (enableMonitoringAlerts) {
  scope: resourceGroup(sharedServicesSubscriptionId, varResourceGroupName)
  name: 'Sche-Query-Rule-${i}-${time}'
  params: {
      location: deploymentLocation
      name: varAlerts[i].name
      alertDescription: varAlerts[i].description
      enabled: true
      kind: 'LogAlert'
      autoMitigate: false
      skipQueryValidation: false
      targetResourceTypes: []
      roleAssignments: []
      scopes: empty(existingLogAnalyticsWorkspaceResourceId) ? [
        workspace.outputs.resourceId
      ] : [
        existingLogAnalyticsWorkspaceResourceId
      ]
      severity: varAlerts[i].severity
      evaluationFrequency: varAlerts[i].evaluationFrequency
      windowSize: varAlerts[i].windowSize
      actions: !empty(distributionGroup) ? [
          actionGroup.outputs.resourceId
      ] : []
      criterias: varAlerts[i].criterias
      tags: enableResourceTags ? varCommonResourceTags : {}
  }
}]
