//targetScope = 'subscription'

param resourceGroupLocation string
param storageAccountName string
// param subscriptionId string
// param storageResourceGroup string 

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  //scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  name: storageAccountName
  location: resourceGroupLocation
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
