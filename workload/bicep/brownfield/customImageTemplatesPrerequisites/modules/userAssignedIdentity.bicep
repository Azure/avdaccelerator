

// ========== //
// Parameters //
// ========== //

param location string
param name string
param tags object


// =========== //
// Deployments //
// =========== //

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags[?'Microsoft.ManagedIdentity/userAssignedIdentities'] ?? {}
}


// =========== //
// Outputs //
// =========== //

output PrincipalId string = userAssignedIdentity.properties.principalId
output ResourceId string = userAssignedIdentity.id
