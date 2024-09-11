param location string
param name string
param tags object

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
  tags: tags[?'Microsoft.ManagedIdentity/userAssignedIdentities'] ?? {}
}

output PrincipalId string = userAssignedIdentity.properties.principalId
output ResourceId string = userAssignedIdentity.id
