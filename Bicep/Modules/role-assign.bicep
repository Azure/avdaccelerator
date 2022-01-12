param principalId string
param roleDefinitionId string
@allowed([
  'User'
  'ServicePrincipal'
  'Group'
  'MSI'
])
param principalType string = 'ServicePrincipal'
param resourceGroupName string = resourceGroup().name

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(principalId, roleDefinitionId, resourceGroupName)
  properties: {
    principalId: principalId
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${roleDefinitionId}'
    principalType: principalType
  }
}

