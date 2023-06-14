targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Location where to deploy AVD management plane.')
param managementPlaneLocation string

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('create new Azure log analytics workspace.')
param deployAlaWorkspace bool

@description('Create and assign custom Azure Policy for diagnostic settings for the AVD Log Analytics workspace.')
param deployCustomPolicyMonitoring bool

@description('Exisintg Azure log analytics workspace resource.')
param alaWorkspaceId string

@description('AVD Resource Group Name for monitoring resources.')
param monitoringRgName string

@description(' Azure log analytics workspace name.')
param alaWorkspaceName string

@description(' Azure log analytics workspace name data retention.')
param alaWorkspaceDataRetention int

@description('Tags to be applied to resources')
param tags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Deployments //
// =========== //

// Resource group if new Log Analytics space is required
module baselineMonitoringResourceGroup '../../../../carml/1.3.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (deployAlaWorkspace) {
  scope: subscription(workloadSubsId)
  name: 'Monitoing-RG-${time}'
  params: {
      name: monitoringRgName
      location: managementPlaneLocation
      enableDefaultTelemetry: false
      tags: tags
  }
}

// Azure log analytics workspace.
module alaWorkspace '../../../../carml/1.3.0/Microsoft.OperationalInsights/workspaces/deploy.bicep' = if (deployAlaWorkspace) {
  scope: resourceGroup('${workloadSubsId}', '${monitoringRgName}')
  name: 'LA-Workspace-${time}'
  params: {
    location: managementPlaneLocation
    name: alaWorkspaceName
    dataRetention: alaWorkspaceDataRetention
    useResourcePermissions: true
    tags: tags
  }
  dependsOn:[
    baselineMonitoringResourceGroup
  ]
}

// Introduce Wait after log analitics workspace creation.
module alaWorkspaceWait '../../../../carml/1.3.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (deployAlaWorkspace) {
  scope: resourceGroup('${workloadSubsId}', '${monitoringRgName}')
  name: 'LA-Workspace-Wait-${time}'
  params: {
      name: 'LA-Workspace-Wait-${time}'
      location: managementPlaneLocation
      azPowerShellVersion: '8.3.0'
      cleanupPreference: 'Always'
      timeout: 'PT10M'
      scriptContent: '''
      Write-Host "Start"
      Get-Date
      Start-Sleep -Seconds 120
      Write-Host "Stop"
      Get-Date
      '''
  }
  dependsOn: [
    alaWorkspace
  ]
}

// Policy definitions.
module deployDiagnosticsAzurePolicyForAvd './.bicep/azurePolicyMonitoring.bicep' = if (deployCustomPolicyMonitoring) {
  scope: subscription('${workloadSubsId}')
  name: 'Custom-Policy-Monitoring-${time}'
  params: {
    alaWorkspaceId: deployAlaWorkspace ? alaWorkspace.outputs.resourceId : alaWorkspaceId
    location: managementPlaneLocation
    workloadSubsId: workloadSubsId
  }
  dependsOn: [
    alaWorkspaceWait
  ]
}

// Performance counters
module deployMonitoringEventsPerformanceSettings './.bicep/monitoringEventsPerformanceCounters.bicep' = if (deployAlaWorkspace) {
  name: 'Events-Performance-${time}'
  params: {
      deployAlaWorkspace: deployAlaWorkspace
      alaWorkspaceId: deployAlaWorkspace ? '' : alaWorkspaceId
      monitoringRgName: monitoringRgName
      alaWorkspaceName: deployAlaWorkspace ? alaWorkspaceName: ''
      workloadSubsId: workloadSubsId
      tags: tags
  }
  dependsOn: [
    alaWorkspaceWait
  ]
}

// =========== //
// Outputs //
// =========== //
output avdAlaWorkspaceResourceId string = deployAlaWorkspace ? alaWorkspace.outputs.resourceId : alaWorkspaceId
output avdAlaWorkspaceId string = deployAlaWorkspace ? alaWorkspace.outputs.logAnalyticsWorkspaceId : alaWorkspaceId // may need to call on existing LGA to get workspace guid // We should be safe to remove this one as CARML modules use the resource ID instead
