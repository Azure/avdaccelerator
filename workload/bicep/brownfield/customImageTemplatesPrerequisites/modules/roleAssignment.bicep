

// ========== //
// Parameters //
// ========== //

param principalId string
param roleDefinitionId string


// =========== //
// Deployments //
// =========== //

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
