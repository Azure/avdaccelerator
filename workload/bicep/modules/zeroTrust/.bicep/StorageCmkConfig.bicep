// Called from deploy-baseline.bicep as storage needs to be created first.

param storageAccountName string
param location string = resourceGroup().location
param keyVaultUri string
param managedIdentityStorageResourceId string
param storageSkuName string

var keyName = 'key-${storageAccountName}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: ((storageSkuName == 'Premium_LRS') || (storageSkuName == 'Premium_ZRS')) ? 'FileStorage' : 'StorageV2'
  identity: {
    type: 'userAssigned'
    userAssignedIdentities: {
      '${managedIdentityStorageResourceId}': {}
    }
  }
  sku: {
    name: storageSkuName
  }
  properties: {
    encryption: {
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyname: keyName
        keyvaulturi: keyVaultUri
        keyversion: ''
      }
      services: {
        file: {
          enabled: true
        }
      }
    }
  }
}
