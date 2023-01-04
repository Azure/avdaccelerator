targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Required. Location where to deploy AVD management plane.')
param avdManagementPlaneLocation string

@description('Required. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('Required. create new Azure log analytics workspace.')
param deployAlaWorkspace bool

@description('Required. Create and assign custom Azure Policy for diagnostic settings for the AVD Log Analytics workspace.')
param deployCustomPolicyMonitoring bool

@description('Required. Exisintg Azure log analytics workspace resource.')
param alaWorkspaceId string

@description('Required. AVD Resource Group Name for monitoring resources.')
param avdMonitoringRgName string

@description('Required.  Azure log analytics workspace name.')
param avdAlaWorkspaceName string

@description('Required.  Azure log analytics workspace name data retention.')
param avdAlaWorkspaceDataRetention int

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Deployments //
// =========== //

// Resource group if new Log Analytics space is required
module avdBaselineMonitoringResourceGroup '../../../carml/1.2.0/Microsoft.Resources/resourceGroups/deploy.bicep' = if (deployAlaWorkspace) {
  scope: subscription(avdWorkloadSubsId)
  name: 'Deploy-${avdMonitoringRgName}-${time}'
  params: {
      name: avdMonitoringRgName
      location: avdManagementPlaneLocation
      enableDefaultTelemetry: false
      tags: avdTags
  }
}

// Azure log analytics workspace.
module avdAlaWorkspace '../../../carml/1.2.1/Microsoft.OperationalInsights/workspaces/deploy.bicep' = if (deployAlaWorkspace) {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdMonitoringRgName}')
  name: 'AVD-Log-Analytics-Workspace-${time}'
  params: {
    location: avdManagementPlaneLocation
    name: avdAlaWorkspaceName
    dataRetention: avdAlaWorkspaceDataRetention
    useResourcePermissions: true
    tags: avdTags
  }
  dependsOn:[
    avdBaselineMonitoringResourceGroup
  ]
}

// Introduce delay after log analitics workspace creation.
module avdAlaWorkspaceDelay '../../../carml/1.0.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (deployAlaWorkspace) {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdMonitoringRgName}')
  name: 'AVD-ALA-Workspace-Delay-${time}'
  params: {
      name: 'AVD-avdAlaWorkspaceDelay-${time}'
      location: avdManagementPlaneLocation
      azPowerShellVersion: '6.2'
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
    avdAlaWorkspace
  ]
}

// Policy definitions.

module deployDiagnosticsAzurePolicyForAvd 'avd-azure-policy-monitoring.bicep' = if (deployCustomPolicyMonitoring) {
  scope: subscription('${avdWorkloadSubsId}')
  name: 'Custom-Policy-Monitoring-${time}'
  params: {
    alaWorkspaceId: deployAlaWorkspace ? avdAlaWorkspace.outputs.resourceId : alaWorkspaceId
    avdManagementPlaneLocation: avdManagementPlaneLocation
    avdWorkloadSubsId: avdWorkloadSubsId
  }
}

// Performance counters
module deployMonitoringEventsPerformanceSettings 'avd-monitoring-events-performance-counters.bicep' = {
  name: 'Deploy-AVD-Events-Performance-${time}'
  params: {
      avdManagementPlaneLocation: avdManagementPlaneLocation
      deployAlaWorkspace: deployAlaWorkspace
      alaWorkspaceId: deployAlaWorkspace ? '' : alaWorkspaceId
      avdMonitoringRgName: avdMonitoringRgName
      avdAlaWorkspaceName: deployAlaWorkspace ? avdAlaWorkspaceName: ''
      avdWorkloadSubsId: avdWorkloadSubsId
      avdTags: avdTags
  }
  dependsOn: [
      avdAlaWorkspace
  ]
}

// =========== //
// Outputs //
// =========== //
output avdAlaWorkspaceResourceId string = deployAlaWorkspace ? avdAlaWorkspace.outputs.resourceId : alaWorkspaceId
output avdAlaWorkspaceId string = deployAlaWorkspace ? avdAlaWorkspace.outputs.logAnalyticsWorkspaceId : alaWorkspaceId // may need to call on existing LGA to get workspace guid // We should be safe to remove this one as CARML modules use the resource ID instead
