// Called from deploy-baseline.bicep as storage needs to be created first.

param storageAccountName string
param location string = resourceGroup().location
param keyVaultUri string
param keyVaultResId string
param managedIdentityStorageResourceId string
param storageSkuName string

var keyName = 'key-${storageAccountName}'

/* resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
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
      identity: {
        userAssignedIdentity: managedIdentityStorageResourceId
      }
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
 */

module storageAccountAVM '../../../../../avm/1.0.0/res/storage/storage-account/main.bicep' = {
  name: 'storageAccountAVM'
  params: {
    name:storageAccountName
    location:location
    kind:((storageSkuName == 'Premium_LRS') || (storageSkuName == 'Premium_ZRS')) ? 'FileStorage' : 'StorageV2'
    skuName:storageSkuName
    managedIdentities: {
      userAssignedResourceIds: [
        managedIdentityStorageResourceId
      ]
    }
    customerManagedKey: {
      userAssignedIdentityResourceId: managedIdentityStorageResourceId
      keyName: keyName
      keyVaultResourceId: keyVaultResId
      keyVersion: ''
    }
  }
}
