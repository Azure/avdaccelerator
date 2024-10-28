metadata name = 'AVD Accelerator -Test NIH Policy issue'
metadata description = 'AVD Accelerator -Test NIH Policy issue'

targetScope = 'subscription'

@sys.description('AVD workload subscription ID, multiple subscriptions scenario. (Default: "")')
param avdWorkloadSubsId string = ''

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@maxLength(90)
@sys.description('AVD service resources resource group custom name. (Default: rg-avd-app1-dev-use2-service-objects)')
param avdServiceObjectsRgCustomName string = 'avd-nih-arpah-prod-use2-service-objects'

@maxLength(90)
@sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-network)')
param avdNetworkObjectsRgCustomName string = 'avd-nih-arpah-prod-use2-network'

@maxLength(90)
@sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-pool-compute)')
param avdComputeObjectsRgCustomName string = 'avd-nih-arpah-prod-use2-pool-compute'

@maxLength(90)
@sys.description('AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-storage)')
param avdStorageObjectsRgCustomName string = 'avd-nih-arpah-prod-use2-storage'

@sys.description('Location where to deploy AVD management plane. (Default: eastus2)')
param location string = 'eastus2'

var verResourceGroups = [
  {
      purpose: 'Service-Objects'
      name: avdServiceObjectsRgCustomName
      location: location
      enableDefaultTelemetry: false
  }
  {
      purpose: 'Pool-Compute'
      name: avdComputeObjectsRgCustomName
      location: location
      enableDefaultTelemetry: false
  }
]

module baselineNetworkResourceGroup '../../avm/1.0.0/res/resources/resource-group/main.bicep' = {
  scope: subscription(avdWorkloadSubsId)
  name: 'Deploy-Network-RG-${time}'
  params: {
      name: avdNetworkObjectsRgCustomName
      location: location
      enableTelemetry: false
  }
}

// Compute, service objects
module baselineResourceGroups '../../avm/1.0.0/res/resources/resource-group/main.bicep' = [
for resourceGroup in verResourceGroups: {
  scope: subscription(avdWorkloadSubsId)
  name: '${resourceGroup.purpose}-${time}'
  params: {
      name: resourceGroup.name
      location: resourceGroup.location
      enableTelemetry: resourceGroup.enableDefaultTelemetry
      //tags: resourceGroup.tags
  }
}
]

// Storage
module baselineStorageResourceGroup '../../avm/1.0.0/res/resources/resource-group/main.bicep' =  {
  scope: subscription(avdWorkloadSubsId)
  name: 'Storage-RG-${time}'
  params: {
      name: avdStorageObjectsRgCustomName
      location: location
      enableTelemetry: false
  }
}
