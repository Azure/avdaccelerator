// Called from deploy-baseline.bicep as storage needs to be created first.

targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@sys.description('Name of storage account.')
param storageAccountName string

@sys.description('Location where to deploy compute services.')
param location string = resourceGroup().location

@sys.description('Key Vault URI associated with Storage Account.')
param keyVaultUri string

// @sys.description('Key Vault Resource ID associated with Storage Acccount.')
// param keyVaultResId string

@sys.description('Managed Identity Resource ID associated with Storage Account and used for Zero Trust.')
param managedIdentityStorageResourceId string

@sys.description('Specifies the SKU for the Storage Account.')
param storageSkuName string

// =========== //
// Variable declaration //
// =========== //

var keyName = 'key-${storageAccountName}'

// =========== //
// Deployments //
// =========== //

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

// Using AVM - the key rotation is not enabled on the Storage Account.
/* module storageAccountAVM '../../../../../avm/1.0.0/res/storage/storage-account/main.bicep' = {
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
} */
