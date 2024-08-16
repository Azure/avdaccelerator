@sys.description('Required. Name of the Application Group to create this application in.')
@minLength(1)
param name string

@sys.description('Optional. Location for all resources.')
param location string = resourceGroup().location

@sys.description('Required. The type of the Application Group to be created. Allowed values: RemoteApp or Desktop')
@allowed([
  'RemoteApp'
  'Desktop'
])
param applicationGroupType string

@sys.description('Required. Name of the Host Pool to be linked to this Application Group.')
param hostpoolName string

@sys.description('Optional. The friendly name of the Application Group to be created.')
param friendlyName string = ''

@sys.description('Optional. The description of the Application Group to be created.')
param description string = ''

@sys.description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalIds\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleAssignments array = []

@sys.description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@sys.description('Optional. Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@sys.description('Optional. Resource ID of log analytics.')
param diagnosticWorkspaceId string = ''

@sys.description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@sys.description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@sys.description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@sys.description('Optional. Tags of the resource.')
param tags object = {}

@sys.description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@sys.description('Optional. The name of logs that will be streamed.')
@allowed([
  'Checkpoint'
  'Error'
  'Management'
])
param diagnosticLogCategoriesToEnable array = [
  'Checkpoint'
  'Error'
  'Management'
]

@sys.description('Optional. List of applications to be created in the Application Group.')
param applications array = []

@sys.description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

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

resource appGroup_hostpool 'Microsoft.DesktopVirtualization/hostpools@2021-07-12' existing = {
  name: hostpoolName
}

resource appGroup 'Microsoft.DesktopVirtualization/applicationgroups@2021-07-12' = {
  name: name
  location: location
  tags: tags
  properties: {
    hostPoolArmPath: appGroup_hostpool.id
    friendlyName: friendlyName
    description: description
    applicationGroupType: applicationGroupType
  }
}

resource appGroup_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${appGroup.name}-${lock}-lock'
  properties: {
    level: lock
    notes: (lock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: appGroup
}

resource appGroup_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(diagnosticWorkspaceId)) || (!empty(diagnosticEventHubAuthorizationRuleId)) || (!empty(diagnosticEventHubName))) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    logs: diagnosticsLogs
  }
  scope: appGroup
}

module appGroup_applications 'applications/deploy.bicep' = [for (application, index) in applications: {
  name: '${uniqueString(deployment().name, location)}-AppGroup-App-${index}'
  params: {
    name: application.name
    appGroupName: appGroup.name
    description: contains(application, 'description') ? application.description : ''
    friendlyName: contains(application, 'friendlyName') ? application.friendlyName : appGroup.name
    filePath: application.filePath
    commandLineSetting: contains(application, 'commandLineSetting') ? application.commandLineSetting : 'DoNotAllow'
    commandLineArguments: contains(application, 'commandLineArguments') ? application.commandLineArguments : ''
    showInPortal: contains(application, 'showInPortal') ? application.showInPortal : false
    iconPath: contains(application, 'iconPath') ? application.iconPath : application.filePath
    iconIndex: contains(application, 'iconIndex') ? application.iconIndex : 0
  }
}]

module appGroup_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-AppGroup-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: appGroup.id
  }
}]

@sys.description('The resource ID  of the AVD application group')
output resourceId string = appGroup.id

@sys.description('The resource group the AVD application group was deployed into')
output resourceGroupName string = resourceGroup().name

@sys.description('The name of the AVD application group')
output name string = appGroup.name
