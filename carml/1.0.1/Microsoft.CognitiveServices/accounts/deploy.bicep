@description('Required. The name of Cognitive Services account')
param name string

@description('Required. Kind of the Cognitive Services. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'sku\' for your Azure region.')
@allowed([
  'AnomalyDetector'
  'Bing.Autosuggest.v7'
  'Bing.CustomSearch'
  'Bing.EntitySearch'
  'Bing.Search.v7'
  'Bing.SpellCheck.v7'
  'CognitiveServices'
  'ComputerVision'
  'ContentModerator'
  'CustomVision.Prediction'
  'CustomVision.Training'
  'Face'
  'FormRecognizer'
  'ImmersiveReader'
  'Internal.AllInOne'
  'LUIS'
  'LUIS.Authoring'
  'Personalizer'
  'QnAMaker'
  'SpeechServices'
  'TextAnalytics'
  'TextTranslation'
])
param kind string

@description('Optional. SKU of the Cognitive Services resource. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'sku\' for your Azure region.')
@allowed([
  'C2'
  'C3'
  'C4'
  'F0'
  'F1'
  'S'
  'S0'
  'S1'
  'S10'
  'S2'
  'S3'
  'S4'
  'S5'
  'S6'
  'S7'
  'S8'
  'S9'
])
param sku string = 'S0'

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

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

@description('Optional. Subdomain name used for token-based authentication. Required if \'networkAcls\' are set.')
param customSubDomainName string = ''

@description('Optional. Subdomain name used for token-based authentication. Must be set if \'networkAcls\' are set.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional. Service endpoint object information')
param networkAcls object = {}

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

@description('Optional. Configuration Details for private endpoints.')
param privateEndpoints array = []

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. List of allowed FQDN.')
param allowedFqdnList array = []

@description('Optional. The API properties for special APIs.')
param apiProperties object = {}

@description('Optional. Allow only Azure AD authentication.')
param disableLocalAuth bool = false

@description('Optional. Properties to configure encryption')
param encryption object = {}

@description('Optional. Resource migration token.')
param migrationToken string = ''

@description('Optional. Restore a soft-deleted cognitive service at deployment time. Will fail if no such soft-deleted resource exists.')
param restore bool = false

@description('Optional. Restrict outbound network access.')
param restrictOutboundNetworkAccess bool = true

@description('Optional. The storage accounts for this resource.')
param userOwnedStorage array = []

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'Audit'
  'RequestResponse'
])
param diagnosticLogCategoriesToEnable array = [
  'Audit'
  'RequestResponse'
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

var networkAcls_var = {
  defaultAction: !empty(networkAcls) ? networkAcls.defaultAction : null
  virtualNetworkRules: !empty(networkAcls) ? ((length(networkAcls.virtualNetworkRules) == 0) ? [] : networkAcls.virtualNetworkRules) : null
  ipRules: !empty(networkAcls) ? ((length(networkAcls.ipRules) == 0) ? [] : networkAcls.ipRules) : null
}

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

resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: name
  kind: kind
  identity: identity
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    customSubDomainName: !empty(customSubDomainName) ? customSubDomainName : null
    networkAcls: !empty(networkAcls) ? networkAcls_var : null
    publicNetworkAccess: publicNetworkAccess
    allowedFqdnList: allowedFqdnList
    apiProperties: apiProperties
    disableLocalAuth: disableLocalAuth
    encryption: !empty(encryption) ? encryption : null
    migrationToken: !empty(migrationToken) ? migrationToken : null
    restore: restore
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
    userOwnedStorage: !empty(userOwnedStorage) ? userOwnedStorage : null
  }
}

resource cognitiveServices_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${cognitiveServices.name}-${lock}-lock'
  properties: {
    level: lock
    notes: (lock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: cognitiveServices
}

resource cognitiveServices_diagnosticSettingName 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(diagnosticWorkspaceId)) || (!empty(diagnosticEventHubAuthorizationRuleId)) || (!empty(diagnosticEventHubName))) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: cognitiveServices
}

module cognitiveServices_privateEndpoints '.bicep/nested_privateEndpoints.bicep' = [for (privateEndpoint, index) in privateEndpoints: {
  name: '${uniqueString(deployment().name, location)}-CognitiveServices-PrivateEndpoint-${index}'
  params: {
    privateEndpointResourceId: cognitiveServices.id
    privateEndpointVnetLocation: (empty(privateEndpoints) ? 'dummy' : reference(split(privateEndpoint.subnetResourceId, '/subnets/')[0], '2020-06-01', 'Full').location)
    privateEndpoint: privateEndpoint
    tags: tags
  }
}]

module cognitiveServices_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-CognitiveServices-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: cognitiveServices.id
  }
}]

@description('The name of the cognitive services account')
output name string = cognitiveServices.name

@description('The resource ID of the cognitive services account')
output resourceId string = cognitiveServices.id

@description('The resource group the cognitive services account was deployed into')
output resourceGroupName string = resourceGroup().name

@description('The service endpoint of the cognitive services account')
output endpoint string = cognitiveServices.properties.endpoint

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(cognitiveServices.identity, 'principalId') ? cognitiveServices.identity.principalId : ''
