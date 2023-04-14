@description('Required. Name of the Azure Recovery Service Vault')
param recoveryVaultName string

@description('Required. Name of the Replication Fabric')
param replicationFabricName string

@description('Required. Name of the source Replication container')
param sourceProtectionContainerName string

@description('Optional. Resource ID of the target Replication container. Must be specified if targetContainerName is not. If specified, targetContainerFabricName and targetContainerName will be ignored')
param targetProtectionContainerId string = ''

@description('Optional. Name of the fabric containing the target container. If targetProtectionContainerId is specified, this parameter will be ignored')
param targetContainerFabricName string = replicationFabricName

@description('Optional. Name of the target container. Must be specified if targetProtectionContainerId is not. If targetProtectionContainerId is specified, this parameter will be ignored')
param targetContainerName string = ''

@description('Optional. Resource ID of the replication policy. If defined, policyName will be ignored')
param policyId string = ''

@description('Optional. Name of the replication policy. Will be ignored if policyId is also specified')
param policyName string = ''

@description('Optional. The name of the replication container mapping. If not provided, it will be automatically generated as `<source_container_name>-<target_container_name>`.')
param name string = ''

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

var policyResourceId = policyId != '' ? policyId : subscriptionResourceId('Microsoft.RecoveryServices/vaults/replicationPolicies', recoveryVaultName, policyName)
var targetProtectionContainerResourceId = targetProtectionContainerId != '' ? targetProtectionContainerId : subscriptionResourceId('Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers', recoveryVaultName, targetContainerFabricName, targetContainerName)
var mappingName = name != '' ? name : concat(sourceProtectionContainerName, '-', split(targetProtectionContainerResourceId, '/')[10])

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

resource replicationContainer 'Microsoft.RecoveryServices/vaults/replicationFabrics/replicationProtectionContainers/replicationProtectionContainerMappings@2021-12-01' = {
  name: '${recoveryVaultName}/${replicationFabricName}/${sourceProtectionContainerName}/${mappingName}'
  properties: {
    targetProtectionContainerId: targetProtectionContainerResourceId
    policyId: policyResourceId
    providerSpecificInput: {
      instanceType: 'A2A'
    }
  }
}

@description('The name of the replication container.')
output name string = replicationContainer.name

@description('The resource ID of the replication container.')
output resourceId string = replicationContainer.id

@description('The name of the resource group the replication container was created in.')
output resourceGroupName string = resourceGroup().name
