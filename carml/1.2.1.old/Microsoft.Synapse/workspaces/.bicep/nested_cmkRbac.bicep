param keyvaultName string
param workspaceIdentity string
param usesRbacAuthorization bool = false

// Workspace encryption - Assign Workspace System Identity Keyvault Crypto Reader at Encryption Keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyvaultName
}

// Assign RBAC role Key Vault Crypto User
resource workspace_cmk_rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (usesRbacAuthorization) {
  name: '${workspaceIdentity}-cmk-rbac'
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424')
    principalId: workspaceIdentity
    principalType: 'ServicePrincipal'
  }
  scope: keyVault
}

// Assign Acess Policy for Keys
resource workspace_cmk_accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = if (!usesRbacAuthorization) {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        permissions: {
          keys: [
            'wrapKey'
            'unwrapKey'
            'get'
          ]
        }
        objectId: workspaceIdentity
        tenantId: tenant().tenantId
      }
    ]
  }
}
