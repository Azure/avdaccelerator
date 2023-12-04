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

@description('Required. The start time for the peak hours in local Standard time.')
param beginPeakTime string = '8:00'

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

@description('Required. The end time for the peak hours in local Standard time.')
param endPeakTime string = '17:00'

@allowed([
  'Prod'
  'Dev'
  'Staging'
])
@description('Optional. Deployment environment of the application, workload. (Default: Dev)')
param environmentTag string = 'Dev'

@description('Optional. Existing Azure log analytics workspace resource ID to capture runbook execution logs. (Default: )')
param existingAutomationAccountResourceId string = ''

@description('Required. The resource ID of the existing host pool to scale.')
param existingHostPoolResourceId string

@description('Optional. The resource ID for an existing log analytics workspace. This value is required to enable monitoring for the solution.')
param existingLogAnalyticsWorkspaceResourceId string = ''

@description('Required. The number of seconds to wait before automatically signing out users. If set to 0, any session host VM that has user sessions, will be left untouched.')
param limitSecondsToForceLogOffUser string = '0'

@description('Optional. Custom name for the Log Analytics Workspace.')
param logAnalyticsWorkspaceCustomName string = 'log-avd'

@description('Required. The minimum number of session host VMs to keep running during off-peak hours.')
param minimumNumberOfRdsh string = '0'

@description('Optional. Team accountable for day-to-day operations. (Contoso-Ops)')
param operationsTeamTag string = 'workload-admins@Contoso.com'

@description('Optional. Organizational owner of the AVD deployment. (Default: Contoso-Owner)')
param ownerTag string = 'workload-owner@Contoso.com'

@maxLength(90)
@description('Optional. Custom name for Resource Group. (Default: rg-avd-use2-shared-services)')
param resourceGroupCustomName string = 'rg-avd-shared'

@description('Required. The name of the resource group containing the AVD session hosts for the target host pool.')
param sessionHostsResourceGroupName string

@description('Required. The maximum number of sessions per CPU that will be used as a threshold to determine when new session host VMs need to be started during peak hours.')
param sessionThresholdPerCPU string = '.5'

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
      name: 'AVD Scaling Tool - Scaling Failed'
      description: 'Sends an error alert when the runbook fails to execute.'
      severity: 0
      evaluationFrequency: 'PT5M'
      windowSize: 'PT5M'
      criterias: {
          allOf: [
              {
                  query: 'AzureDiagnostics\n| where ResourceProvider == "MICROSOFT.AUTOMATION"\n| where Category  == "JobStreams"\n| where StreamType_s == "Error"'
                  TimeAggregation: 'Count'
                  dimensions: []
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
var varExistingHostPoolName = split(existingHostPoolResourceId, '/')[8]
var varExistingHostPoolResourceGroupName = split(existingHostPoolResourceId, '/')[4]
var varJobScheduleParameters = {
  TenantId: subscription().tenantId
  SubscriptionId: subscription().subscriptionId
  EnvironmentName: environment().name
  ResourceGroupName: varExistingHostPoolResourceGroupName
  HostPoolName: varExistingHostPoolName
  MaintenanceTagName: 'Maintenance'
  TimeDifference: varLocations[varLocation].timeDifference
  BeginPeakTime: beginPeakTime
  EndPeakTime: endPeakTime
  SessionThresholdPerCPU: sessionThresholdPerCPU
  MinimumNumberOfRDSH: minimumNumberOfRdsh
  LimitSecondsToForceLogOffUser: limitSecondsToForceLogOffUser
  LogOffMessageTitle: 'Machine is about to shutdown.'
  LogOffMessageBody: 'Your session will be logged off. Please save and close everything.'
}
var varLocationAcronym = varLocations[varLocation].acronym
var varLocation = toLower(replace(deploymentLocation, ' ', ''))
var varLocations = loadJsonContent('../../../variables/locations.json')
var varLogAnalyticsWorkspaceName = customNaming ? logAnalyticsWorkspaceCustomName : 'log-avd-${varNamingStandard}'
var varNamingStandard = '${varLocationAcronym}'
var varResourceGroupName = customNaming ? resourceGroupCustomName : 'rg-avd-${varNamingStandard}-shared-services'
var varRoleAssignments = varExistingHostPoolResourceGroupName == sessionHostsResourceGroupName ? [
  varExistingHostPoolResourceGroupName
] : [
  varExistingHostPoolResourceGroupName
  sessionHostsResourceGroupName
]
var varRunbookName = 'Azure-Virtual-Desktop-Scaling-Tool'
var varScheduleName = '${varExistingHostPoolName}_'
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
module automationAccount_Existing '../autoIncreasePremiumFileShareQuota/modules/existingAutomationAccount.bicep' = if(!(empty(existingAutomationAccountResourceId))) {
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
        description: 'When this runbook is triggered, the AVD session hosts will be either turned on or off depending upon the peak hours and active sessions.'
        type: 'PowerShell'
        uri: 'https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Set-AvdScalingTool.ps1'
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

// Role assignments
module roleAssignments'../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for i in range(0, length(varRoleAssignments)): {
  name: 'Role-Assignment-${i}-${time}'
  scope: resourceGroup(varRoleAssignments[i])
  params: {
    principalId: automationAccount_New.outputs.systemAssignedPrincipalId
    roleDefinitionIdOrName: 'Desktop Virtualization Power On Off Contributor'
  }
}]

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
