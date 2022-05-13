@description('Required. The name of the registry.')
param registryName string

@description('Required. The name of the replication.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Specifies whether the replication regional endpoint is enabled. Requests will not be routed to a replication whose regional endpoint is disabled, however its data will continue to be synced with other replications.')
param regionEndpointEnabled bool = true

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Whether or not zone redundancy is enabled for this container registry')
param zoneRedundancy string = 'Disabled'

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource registry 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: registryName
}

resource replication 'Microsoft.ContainerRegistry/registries/replications@2021-12-01-preview' = {
  name: name
  parent: registry
  location: location
  tags: tags
  properties: {
    regionEndpointEnabled: regionEndpointEnabled
    zoneRedundancy: zoneRedundancy
  }
}

@description('The name of the replication.')
output name string = replication.name

@description('The resource ID of the replication.')
output resourceId string = replication.id

@description('The name of the resource group the replication was created in.')
output resourceGroupName string = resourceGroup().name
