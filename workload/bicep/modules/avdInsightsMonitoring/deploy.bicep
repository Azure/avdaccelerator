
metadata name = 'AVD LZA insights monitoring'
metadata description = 'This module deploys Log analytics workspace, DCR and policies'
metadata owner = 'Azure/avdaccelerator'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD management plane.')
param location string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('create new Azure log analytics workspace.')
param deployAlaWorkspace bool

@sys.description('Create and assign custom Azure Policy for diagnostic settings for the AVD Log Analytics workspace.')
param deployCustomPolicyMonitoring bool

@sys.description('Exisintg Azure log analytics workspace resource.')
param alaWorkspaceId string = ''

@sys.description('AVD Resource Group Name for monitoring resources.')
param monitoringRgName string

@sys.description('AVD Resource Group Name for compute resources.')
param computeObjectsRgName string

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('AVD Resource Group Name for the storage resources.')
param storageObjectsRgName string

@sys.description('AVD Resource Group Name for the network resources.')
param networkObjectsRgName string

@sys.description('Azure log analytics workspace name.')
param alaWorkspaceName string

@sys.description('Data collection rules name.')
param dataCollectionRulesName string

@sys.description(' Azure log analytics workspace name data retention.')
param alaWorkspaceDataRetention int

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Resource group if new Log Analytics space is required
module baselineMonitoringResourceGroup '../../../../avm/1.0.0/res/resources/resource-group/main.bicep' = if (deployAlaWorkspace) {
  scope: subscription(subscriptionId)
  name: 'Monitoing-RG-${time}'
  params: {
      name: monitoringRgName
      location: location
      enableTelemetry: false
      tags: tags
  }
}

// Azure log analytics workspace.
module alaWorkspace '../../../../avm/1.0.0/res/operational-insights/workspace/main.bicep' = if (deployAlaWorkspace) {
  scope: resourceGroup('${subscriptionId}', '${monitoringRgName}')
  name: 'LA-Workspace-${time}'
  params: {
    location: location
    name: alaWorkspaceName
    dataRetention: alaWorkspaceDataRetention
    useResourcePermissions: true
    managedIdentities: {
      systemAssigned: false
    }
    tags: tags
  }
  dependsOn:[
    baselineMonitoringResourceGroup
  ]
}

// Policy definitions.
module deployDiagnosticsAzurePolicyForAvd '../azurePolicies/avdMonitoring.bicep' = if (deployCustomPolicyMonitoring) {
  scope: subscription('${subscriptionId}')
  name: 'Custom-Policy-Monitoring-${time}'
  params: {
    alaWorkspaceId: deployAlaWorkspace ? alaWorkspace.outputs.resourceId : alaWorkspaceId
    location: location
    subscriptionId: subscriptionId
    computeObjectsRgName: computeObjectsRgName
    serviceObjectsRgName: serviceObjectsRgName
    storageObjectsRgName: storageObjectsRgName
    networkObjectsRgName: networkObjectsRgName
  }
  dependsOn: [
    alaWorkspace
    baselineMonitoringResourceGroup
  ]
}

// data collection rules
module dataCollectionRule './.bicep/dataCollectionRules.bicep' = {
  scope: resourceGroup('${subscriptionId}', (deployAlaWorkspace ? '${monitoringRgName}': '${serviceObjectsRgName}'))
  name: 'DCR-${time}'
  params: {
      location: location
      name: dataCollectionRulesName
      alaWorkspaceId: deployAlaWorkspace ? alaWorkspace.outputs.resourceId : alaWorkspaceId
      tags: {
        name: 'test'
      }  //tags
  }
  dependsOn: [
    alaWorkspace
  ]
}

// =========== //
// Outputs //
// =========== //

output avdAlaWorkspaceResourceId string = deployAlaWorkspace ? alaWorkspace.outputs.resourceId : alaWorkspaceId
output avdAlaWorkspaceId string = deployAlaWorkspace ? alaWorkspace.outputs.logAnalyticsWorkspaceId : alaWorkspaceId // may need to call on existing LGA to get workspace guid // We should be safe to remove this one as CARML modules use the resource ID instead
output dataCollectionRuleId string = dataCollectionRule.outputs.dataCollectionRulesId
