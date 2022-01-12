@description('Name of the secret to store in Key Vault')
param secretName string

@secure()
@description('Value of the secret to store in Key Vault')
param secretValue string

param keyVaultName string

resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: kv
  name: secretName
  properties: {
    value: secretValue
  }
}
