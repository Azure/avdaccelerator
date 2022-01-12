@description('Name of the secret to store in Key Vault')
param secretName string
param location string = resourceGroup().location
param storageName string
param keyVaultName string
param time string = utcNow('yyyy-MM-ddTHH:mm:ssZ')

var add1Hour = dateTimeAdd(time, 'PT1H')
var add1Year = dateTimeAdd(time, 'PT1Y')

var sasReadProperties = {
  canonicalizedResource: '/blob/${storageName}/aibscripts'
  signedProtocol: 'https'
  signedServices: 'b'
  signedPermission: 'rl'
  signedExpiry: add1Year
  signedResourceTypes: 'co'
}

var sasWriteProperties = {
  canonicalizedResource: '/blob/${storageName}/aibscripts'
  signedProtocol: 'https'
  signedServices: 'b'
  signedPermission: 'rlw'
  signedExpiry: add1Hour
  signedResourceTypes: 'co'
}

resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
}

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${storageName}/default/aibscripts'
}

resource secretSas 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: kv
  name: secretName
  properties: {
    value: listAccountSas(storageName, '2018-07-01', sasReadProperties).accountSasToken
  }
}
