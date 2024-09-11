param principalId string
param roleDefinitionId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(principalId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
