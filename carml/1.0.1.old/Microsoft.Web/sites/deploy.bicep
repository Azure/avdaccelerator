@description('Required. Name of the site.')
param name string

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Required. Type of site to deploy.')
@allowed([
  'functionapp'
  'app'
])
param kind string

@description('Optional. Configures a site to accept only HTTPS requests. Issues redirect for HTTP requests.')
param httpsOnly bool = true

@description('Optional. If client affinity is enabled.')
param clientAffinityEnabled bool = true

@description('Optional. Configuration of the app.')
param siteConfig object = {}

@description('Optional. Required if functionapp kind. The resource ID of the storage account to manage triggers and logging function executions.')
param storageAccountId string = ''

@description('Optional. Runtime of the function worker.')
@allowed([
  'dotnet'
  'node'
  'python'
  'java'
  'powershell'
  ''
])
param functionsWorkerRuntime string = ''

@description('Optional. Version if the function extension.')
param functionsExtensionVersion string = '~3'

@description('Optional. The resource ID of the app service plan to use for the site.')
param serverFarmResourceId string = ''

@description('Optional. The resource ID of the existing app insight to leverage for the app. If the resource ID is not provided, the appInsightObject can be used to create a new app insight.')
param appInsightId string = ''

@description('Optional. Used to deploy a new app insight if no appInsightId is provided.')
param appInsightObject object = {}

@description('Optional. The resource ID of the app service environment to use for this resource.')
param appServiceEnvironmentId string = ''

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Configuration details for private endpoints.')
param privateEndpoints array = []

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServiceIPSecAuditLogs'
  'AppServicePlatformLogs'
  'FunctionAppLogs'
])
param diagnosticLogCategoriesToEnable array = kind == 'functionapp' ? [
  'FunctionAppLogs'
] : [
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServiceIPSecAuditLogs'
  'AppServicePlatformLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

module appInsight '.bicep/nested_components.bicep' = if (!empty(appInsightObject)) {
  name: '${uniqueString(deployment().name, location)}-Site-AppInsight'
  params: {
    name: contains(appInsightObject, 'name') ? !empty(appInsightObject.name) ? appInsightObject.name : '${name}-appi' : '${name}-appi'
    workspaceResourceId: appInsightObject.workspaceResourceId
    tags: tags
    lock: lock
    location: location
  }
}

resource app 'Microsoft.Web/sites@2020-12-01' = {
  name: name
  location: location
  kind: kind
  tags: tags
  identity: identity
  properties: {
    serverFarmId: serverFarmResourceId
    httpsOnly: httpsOnly
    hostingEnvironmentProfile: !empty(appServiceEnvironmentId) ? {
      id: appServiceEnvironmentId
    } : null
    clientAffinityEnabled: clientAffinityEnabled
    siteConfig: siteConfig
  }
}

module app_appsettings 'config/deploy.bicep' = {
  name: '${uniqueString(deployment().name, location)}-Site-Config'
  params: {
    name: 'appsettings'
    appName: app.name
    storageAccountId: !empty(storageAccountId) ? storageAccountId : ''
    appInsightId: !empty(appInsightId) ? appInsightId : !empty(appInsightObject) ? appInsight.outputs.resourceId : ''
    functionsWorkerRuntime: !empty(functionsWorkerRuntime) ? functionsWorkerRuntime : ''
    functionsExtensionVersion: !empty(functionsExtensionVersion) ? functionsExtensionVersion : '~3'
  }
}

resource app_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${app.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: app
}

resource app_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(diagnosticWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: app
}

module app_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-Site-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: app.id
  }
}]

module app_privateEndpoint '.bicep/nested_privateEndpoint.bicep' = [for (privateEndpoint, index) in privateEndpoints: {
  name: '${uniqueString(deployment().name, location)}-Site-PrivateEndpoints-${index}'
  params: {
    privateEndpointResourceId: app.id
    privateEndpointVnetLocation: reference(split(privateEndpoint.subnetResourceId, '/subnets/')[0], '2020-06-01', 'Full').location
    privateEndpointObj: privateEndpoint
    tags: tags
  }
}]

@description('The name of the site.')
output name string = app.name

@description('The resource ID of the site.')
output resourceId string = app.id

@description('The resource group the site was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(app.identity, 'principalId') ? app.identity.principalId : ''
