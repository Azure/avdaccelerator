@description('Optional. Alternative parameter values.')
param alternativeParameterValues object = {}

@description('Optional. Specific values for some API connections.')
param connectionApi object = {}

@description('Required. Connection Kind. Example: \'V1\' when using blobs. It can change depending on the resource.')
param connectionKind string

@description('Required. Connection name for connection. Example: \'azureblob\' when using blobs.  It can change depending on the resource.')
param name string

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@description('Optional. Customized parameter values for specific connections.')
param customParameterValues object = {}

@description('Required. Display name connection. Example: \'blobconnection\' when using blobs. It can change depending on the resource.')
param displayName string

@description('Optional. Location of the deployment.')
param location string = resourceGroup().location

@description('Optional. Dictionary of nonsecret parameter values.')
param nonSecretParameterValues object = {}

@description('Optional. Connection strings or access keys for connection. Example: \'accountName\' and \'accessKey\' when using blobs.  It can change depending on the resource.')
@secure()
param parameterValues object = {}

@description('Optional. Value Type of parameter, in case alternativeParameterValues is used.')
param parameterValueType string = ''

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

@description('Optional. Status of the connection.')
param statuses array = []

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Links to test the API connection.')
param testLinks array = []

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

resource connection 'Microsoft.Web/connections@2016-06-01' = {
  name: name
  location: location
  kind: connectionKind
  tags: tags
  properties: {
    displayName: displayName
    customParameterValues: customParameterValues
    parameterValueType: !empty(parameterValueType) ? parameterValueType : null
    alternativeParameterValues: !empty(alternativeParameterValues) ? alternativeParameterValues : null
    api: connectionApi
    parameterValues: empty(alternativeParameterValues) ? parameterValues : null
    nonSecretParameterValues: !empty(nonSecretParameterValues) ? nonSecretParameterValues : null
    testLinks: !empty(testLinks) ? testLinks : null
    statuses: !empty(statuses) ? statuses : null
  }
}

resource connection_lock 'Microsoft.Authorization/locks@2017-04-01' = if (lock != 'NotSpecified') {
  name: '${connection.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: connection
}

module connection_rbac '.bicep/nested_rbac.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-Connection-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: connection.id
  }
}]

@description('The resource ID of the connection')
output resourceId string = connection.id

@description('The resource group the connection was deployed into')
output resourceGroupName string = resourceGroup().name

@description('The name of the connection')
output name string = connection.name
