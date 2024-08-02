targetScope = 'subscription'

@description('Required. The name of the Resource Group.')
param name string

@description('Optional. Location of the Resource Group. It uses the deployment\'s location when not provided.')
param location string = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: name
  properties: {}
}

@description('The name of the resource group.')
output name string = resourceGroup.name

@description('The resource ID of the resource group.')
output resourceId string = resourceGroup.id

@description('The location the resource was deployed into.')
output location string = resourceGroup.location
