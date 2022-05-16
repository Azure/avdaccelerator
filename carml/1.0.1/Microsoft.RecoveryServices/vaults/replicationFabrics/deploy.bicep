@description('Required. Name of the Azure Recovery Service Vault')
param recoveryVaultName string

@description('Required. The recovery location the fabric represents')
param location string = resourceGroup().location

@description('Optional. The name of the fabric')
param name string = location

@description('Optional. Replication containers to create.')
param replicationContainers array = []

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name)}-rsvPolicy'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource replicationFabric 'Microsoft.RecoveryServices/vaults/replicationFabrics@2021-12-01' = {
  name: '${recoveryVaultName}/${name}'
  properties: {
    customDetails: {
      instanceType: 'Azure'
      location: location
    }
  }
}

module fabric_replicationContainers 'replicationProtectionContainers/deploy.bicep' = [for (container, index) in replicationContainers: {
  name: '${deployment().name}-RCont-${index}'
  params: {
    name: container.name
    recoveryVaultName: recoveryVaultName
    replicationFabricName: name
    replicationContainerMappings: contains(container, 'replicationContainerMappings') ? container.replicationContainerMappings : []
  }
  dependsOn: [
    replicationFabric
  ]
}]

@description('The name of the replication fabric.')
output name string = replicationFabric.name

@description('The resource ID of the replication fabric.')
output resourceId string = replicationFabric.id

@description('The name of the resource group the replication fabric was created in.')
output resourceGroupName string = resourceGroup().name
