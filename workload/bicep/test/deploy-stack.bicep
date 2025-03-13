targetScope = 'subscription'

param resourceGroupLocation string 
param storageAccountName string
param subscriptionId string
param storageObjectsRgName string

// resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
//   name: storageAccountName
//   location: resourceGroupLocation
//   kind: 'StorageV2'
//   sku: {
//     name: 'Standard_LRS'
//   }
// }

module storage 'modules/storage.bicep' = {
  name: 'test-deployment-stack-storage'
  scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
  params: {
    resourceGroupLocation: resourceGroupLocation
    //subscriptionId: avdWorkloadSubsId
    storageAccountName: storageAccountName
  }
}
