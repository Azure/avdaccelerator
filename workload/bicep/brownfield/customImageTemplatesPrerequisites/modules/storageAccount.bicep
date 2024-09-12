

// ========== //
// Parameters //
// ========== //

param location string
param storageAccountName string
param tags object
param userAssignedIdentityPrincipalId string
param userAssignedIdentityResourceId string


// =========== //
// Deployments //
// =========== //

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags[?'Microsoft.Storage/storageAccounts'] ?? {}
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityResourceId}': {}
    }
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Cool'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowedCopyScope: 'AAD'
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    dnsEndpointType: 'Standard'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    publicNetworkAccess: 'Enabled'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'artifacts'
  properties: {
    publicAccess: 'None'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentityPrincipalId, '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1', storageAccount.id)
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1') // Storage Blob Data Reader
    principalId: userAssignedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}
