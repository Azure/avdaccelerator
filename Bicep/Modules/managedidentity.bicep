param identityName string
param location string = resourceGroup().location
param tags object = {}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: location
  tags: tags
}

output identityResourceId string = identity.id
output identityPrincipalId string = identity.properties.principalId
