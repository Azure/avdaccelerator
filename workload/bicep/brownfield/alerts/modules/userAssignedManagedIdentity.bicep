param Location string
param ManagedIdentityName string
param RoleDefinitionId string

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: ManagedIdentityName
  location: Location
}

// Role Assignment for Deployment Script Contributor
// Allows least privilege for deploying deployment script resources
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(ManagedIdentityName, RoleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: RoleDefinitionId
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output principalId string = userAssignedIdentity.properties.principalId
output resourceIdentifier string = userAssignedIdentity.id
