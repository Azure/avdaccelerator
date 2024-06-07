
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
param alaWorkspaceId string

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

var varDcrRgName = 'AzureMonitor-DataCollectionRules'
var varAlaWorkspaceName = deployAlaWorkspace ? (split(alaWorkspace.outputs.resourceId, '/')[8]): (split(alaWorkspaceId, '/')[8])

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
    tags: tags
  }
  dependsOn:[
    baselineMonitoringResourceGroup
  ]
}

// Policy definitions.
module deployDiagnosticsAzurePolicyForAvd './.bicep/azurePolicyMonitoring.bicep' = if (deployCustomPolicyMonitoring) {
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
module dataCollectionRule '../../../../avm/1.0.0/res/insights/data-collection-rule/main.bicep' = {
  scope: resourceGroup('${subscriptionId}', (deployAlaWorkspace ? '${monitoringRgName}': '${serviceObjectsRgName}'))
  name: 'DCR-${time}'
  params: {
      location: location
      name: dataCollectionRulesName
      description: 'AVD Insights settings'
      dataFlows: [
        {
          streams: [
            'Microsoft-Perf'
            'Microsoft-Event'
          ]
          destinations: [
            varAlaWorkspaceName
          ]
        }
      ]
      dataSources: {
        performanceCounters: [
          {
              streams: [
                  'Microsoft-Perf'
              ]
              samplingFrequencyInSeconds: 30
              counterSpecifiers: [
                  '\\LogicalDisk(C:)\\Avg. Disk Queue Length'
                  '\\LogicalDisk(C:)\\Current Disk Queue Length'
                  '\\Memory\\Available Mbytes'
                  '\\Memory\\Page Faults/sec'
                  '\\Memory\\Pages/sec'
                  '\\Memory\\% Committed Bytes In Use'
                  '\\PhysicalDisk(*)\\Avg. Disk Queue Length'
                  '\\PhysicalDisk(*)\\Avg. Disk sec/Read'
                  '\\PhysicalDisk(*)\\Avg. Disk sec/Transfer'
                  '\\PhysicalDisk(*)\\Avg. Disk sec/Write'
                  '\\Processor Information(_Total)\\% Processor Time'
                  '\\User Input Delay per Process(*)\\Max Input Delay'
                  '\\User Input Delay per Session(*)\\Max Input Delay'
                  '\\RemoteFX Network(*)\\Current TCP RTT'
                  '\\RemoteFX Network(*)\\Current UDP Bandwidth'
              ]
              name: 'perfCounterDataSource10'
          }
          {
              streams: [
                  'Microsoft-Perf'
              ]
              samplingFrequencyInSeconds: 60
              counterSpecifiers: [
                  '\\LogicalDisk(C:)\\% Free Space'
                  '\\LogicalDisk(C:)\\Avg. Disk sec/Transfer'
                  '\\Terminal Services(*)\\Active Sessions'
                  '\\Terminal Services(*)\\Inactive Sessions'
                  '\\Terminal Services(*)\\Total Sessions'
              ]
              name: 'perfCounterDataSource30'
          }
      ]
      windowsEventLogs: [
        {
            streams: [
                'Microsoft-Event'
            ]
            xPathQueries: [
                'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin!*[System[(Level=2 or Level=3 or Level=4 or Level=0) ]]'
                'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]'
                'System!*'
                'Microsoft-FSLogix-Apps/Operational!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]'
                'Application!*[System[(Level=2 or Level=3)]]'
                'Microsoft-FSLogix-Apps/Admin!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]'
            ]
            name: 'eventLogsDataSource'
        }
      ]
      destinations: {
        logAnalytics: [
          {
            name: varAlaWorkspaceName
            workspaceResourceId: deployAlaWorkspace ? alaWorkspace.outputs.resourceId: alaWorkspaceId
          }
        ]
      }
      tags: tags
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
