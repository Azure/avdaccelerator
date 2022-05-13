@description('Required. Name of the App Service Environment')
@minLength(1)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Kind of resource.')
param kind string = 'ASEV2'

@description('Required. ResourceId for the sub net')
param subnetResourceId string

@description('Optional. Specifies which endpoints to serve internally in the Virtual Network for the App Service Environment. - None, Web, Publishing, Web,Publishing')
@allowed([
  'None'
  'Web'
  'Publishing'
])
param internalLoadBalancingMode string = 'None'

@description('Optional. Frontend VM size, e.g. Medium, Large')
@allowed([
  'Medium'
  'Large'
  'ExtraLarge'
  'Standard_D2'
  'Standard_D3'
  'Standard_D4'
  'Standard_D1_V2'
  'Standard_D2_V2'
  'Standard_D3_V2'
  'Standard_D4_V2'
])
param multiSize string = 'Standard_D1_V2'

@description('Optional. Number of frontend instances.')
param multiRoleCount int = 2

@description('Optional. Number of IP SSL addresses reserved for the App Service Environment.')
param ipsslAddressCount int = 2

@description('Optional. Description of worker pools with worker size IDs, VM sizes, and number of workers in each pool..')
param workerPools array = []

@description('Optional. DNS suffix of the App Service Environment.')
param dnsSuffix string = ''

@description('Optional. Access control list for controlling traffic to the App Service Environment..')
param networkAccessControlList array = []

@description('Optional. Scale factor for frontends.')
param frontEndScaleFactor int = 15

@description('Optional. API Management Account associated with the App Service Environment.')
param apiManagementAccountId string = ''

@description('Optional. true if the App Service Environment is suspended; otherwise, false. The environment can be suspended, e.g. when the management endpoint is no longer available (most likely because NSG blocked the incoming traffic).')
param suspended bool = false

@description('Optional. True/false indicating whether the App Service Environment is suspended. The environment can be suspended e.g. when the management endpoint is no longer available(most likely because NSG blocked the incoming traffic).')
param dynamicCacheEnabled bool = false

@description('Optional. User added ip ranges to whitelist on ASE db - string')
param userWhitelistedIpRanges array = []

@description('Optional. Flag that displays whether an ASE has linux workers or not')
param hasLinuxWorkers bool = false

@description('Optional. Custom settings for changing the behavior of the App Service Environment')
param clusterSettings array = []

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@description('Optional. Resource tags.')
param tags object = {}

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'AppServiceEnvironmentPlatformLogs'
])
param diagnosticLogCategoriesToEnable array = [
  'AppServiceEnvironmentPlatformLogs'
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

var vnetResourceId = split(subnetResourceId, '/')

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

resource appServiceEnvironment 'Microsoft.Web/hostingEnvironments@2021-02-01' = {
  name: name
  kind: kind
  location: location
  tags: tags
  properties: {
    name: name
    location: location
    virtualNetwork: {
      id: subnetResourceId
      subnet: last(vnetResourceId)
    }
    internalLoadBalancingMode: internalLoadBalancingMode
    multiSize: multiSize
    multiRoleCount: multiRoleCount
    workerPools: workerPools
    ipsslAddressCount: ipsslAddressCount
    dnsSuffix: dnsSuffix
    networkAccessControlList: networkAccessControlList
    frontEndScaleFactor: frontEndScaleFactor
    apiManagementAccountId: apiManagementAccountId
    suspended: suspended
    dynamicCacheEnabled: dynamicCacheEnabled
    clusterSettings: clusterSettings
    userWhitelistedIpRanges: userWhitelistedIpRanges
    hasLinuxWorkers: hasLinuxWorkers
  }
}

resource appServiceEnvironment_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${appServiceEnvironment.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: appServiceEnvironment
}

resource appServiceEnvironment_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(diagnosticWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    logs: diagnosticsLogs
  }
  scope: appServiceEnvironment
}

module appServiceEnvironment_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-AppServiceEnv-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: appServiceEnvironment.id
  }
}]

@description('The resource ID of the app service environment')
output resourceId string = appServiceEnvironment.id

@description('The resource group the app service environment was deployed into')
output resourceGroupName string = resourceGroup().name

@description('The name of the app service environment')
output name string = appServiceEnvironment.name
