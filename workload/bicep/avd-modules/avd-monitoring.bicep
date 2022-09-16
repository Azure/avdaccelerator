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

@description('Required. Exisintg Azure log analytics workspace.')
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
// Variable declaration //
// =========== //
// Policy Set/Initiative Definition Parameter Variables
var varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters = loadJsonContent('../../policies/policy-sets/parameters/policy-set-definition-es-deploy-diagnostics-to-log-analytics.parameters.json')

// This variable contains a number of objects that load in the custom Azure Policy Defintions that are provided as part of the ESLZ/ALZ reference implementation. 
var varCustomPolicyDefinitions = [
  {
    name: 'policy-deploy-diagnostics-avd-application-group'
    libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-avd-application-group.json'))
  }
  {
    name: 'policy-deploy-diagnostics-avd-host-pool'
    libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-avd-host-pool.json'))
  }
  {
    name: 'policy-deploy-diagnostics-avd-scaling-plan'
    libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-avd-scaling-plan.json'))
  }
  {
    name: 'policy-deploy-diagnostics-avd-workspace'
    libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-avd-workspace.json'))
  }
  {
    name: 'policy-deploy-diagnostics-network-security-group'
    libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-network-security-group.json'))
  }
  {
    name: 'policy-deploy-diagnostics-nic'
    libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-nic.json'))
  }
  {
    name: 'policy-deploy-diagnostics-virtual-machine'
    libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-virtual-machine.json'))
  }
  {
    name: 'policy-deploy-diagnostics-virtual-network'
    libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-virtual-network.json'))
  }
  //{
  //  name: 'policy-deploy-diagnostics-virtual-storage'
  //  libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-virtual-network.json'))
  //}
]

// This variable contains a number of objects that load in the custom Azure Policy Set/Initiative Defintions that are provided as part of the ESLZ/ALZ reference implementation - this is automatically created in the file 'infra-as-code\bicep\modules\policy\lib\policy_set_definitions\_policySetDefinitionsBicepInput.txt' via a GitHub action, that runs on a daily schedule, and is then manually copied into this variable.
var varCustomPolicySetDefinitions = {
  name: 'policy-set-deploy-diagnostics-to-log-analytics'
  libSetDefinition: json(loadTextContent('../../policies/policy-sets/policy-set-definition-es-deploy-diagnostics-to-log-analytics.json'))
  libSetChildDefinitions: [
    {
      definitionReferenceId: 'AVDAppGroupDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-application-group'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDAppGroupDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AVDHostPoolsDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-host-pool'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDHostPoolsDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AVDScalingPlansDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-scaling-plan'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDScalingPlansDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AVDWorkspaceDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-workspace'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDWorkspaceDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-network-security-group'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'NetworkNICDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-nic'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.NetworkNICDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'VirtualMachinesDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-virtual-machine'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.VirtualMachinesDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'VirtualNetworkDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-virtual-network'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.VirtualNetworkDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    //{
    //  definitionReferenceId: 'StorageAccountDeployDiagnosticLogDeployLogAnalytics'
    //  definitionId: '${avdWorkloadSubsId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-virtual-network'
    //  definitionParameters: varvarPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.StorageAccountDeployDiagnosticLogDeployLogAnalytics.parameters
    //}
  ]
}

var varAvdOsSettingsAlaWorkspaceName = deployAlaWorkspace ? avdAlaWorkspaceName: varAvdExistingAlaWorkspaceName
var varAvdExistingAlaWorkspaceName =  deployAlaWorkspace ? '' : split(alaWorkspaceId, '/')[8]
var varAvdExistingAlaWorkspaceRgName = deployAlaWorkspace ? '' :  split(alaWorkspaceId, '/')[4]
var varAvdExistingAlaWorkspaceSubID = deployAlaWorkspace ? '' :  split(alaWorkspaceId, '/')[2]
var varAvdOsSettingsAlaWorkspaceRgName = deployAlaWorkspace ? avdMonitoringRgName: varAvdExistingAlaWorkspaceRgName
var varAvdOsSettingsAlaWorkspaceSubId = deployAlaWorkspace ? avdWorkloadSubsId: varAvdExistingAlaWorkspaceSubID

var varWindowsEvents = [
  {
    name: 'Microsoft-FSLogix-Apps/Operational'
    types: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
  {
    name: 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'
    types: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
  {
    name: 'System'
    types: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
    ]
  }
  {
    name: 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin'
    types: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
  {
    name: 'Microsoft-FSLogix-Apps/Admin'
    types: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
      {
        eventType: 'Information'
      }
    ]
  }
  {
    name: 'Application'
    types: [
      {
        eventType: 'Error'
      }
      {
        eventType: 'Warning'
      }
    ]
  }
]
var varWindowsPerformanceCounters = [
  {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Disk Transfers/sec'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Current Disk Queue Length'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Disk Reads/sec'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Free Space'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Read'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Disk Writes/sec'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Write'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Free Megabytes'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: 'C:'
    intervalSeconds: 60
    counterName: '% Free Space'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: 'C:'
    intervalSeconds: 30
    counterName: 'Avg. Disk Queue Length'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: 'C:'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Transfer'
  }
  {
    objectName: 'LogicalDisk'
    instanceName: 'C:'
    intervalSeconds: 30
    counterName: 'Current Disk Queue Length'
  }
  {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Committed Bytes In Use'
  }
  {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Available MBytes'
  }
  {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Available Mbytes'
  }
  {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Page Faults/sec'
  }
  {
    objectName: 'Memory'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Pages/sec'
  }
  {
    objectName: 'Network Adapter'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Bytes Sent/sec'
  }
  {
    objectName: 'Network Adapter'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Bytes Received/sec'
  }
  {
    objectName: 'Network Interface'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Bytes Total/sec'
  }
  {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk Bytes/Transfer'
  }
  {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk Bytes/Read'
  }
  {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Write'
  }
  {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Read'
  }
  {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk Bytes/Write'
  }
  {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Avg. Disk sec/Transfer'
  }
  {
    objectName: 'PhysicalDisk'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Avg. Disk Queue Length'
  }
  {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'IO Write Operations/sec'
  }
  {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'IO Read Operations/sec'
  }
  {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Thread Count'
  }
  {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% User Time'
  }
  {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Working Set'
  }
  {
    objectName: 'Process'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Processor Time'
  }
  {
    objectName: 'Processor'
    instanceName: '_Total'
    intervalSeconds: 60
    counterName: '% Processor Time'
  }
  {
    objectName: 'Processor Information'
    instanceName: '_Total'
    intervalSeconds: 30
    counterName: '% Processor Time'
  }
  {
    objectName: 'RemoteFX Graphics'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Frames Skipped/Second - Insufficient Server Resources'
  }
  {
    objectName: 'RemoteFX Graphics'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Average Encoding Time'
  }
  {
    objectName: 'RemoteFX Graphics'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Frames Skipped/Second - Insufficient Client Resources'
  }
  {
    objectName: 'RemoteFX Graphics'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Frames Skipped/Second - Insufficient Network Resources'
  }
  {
    objectName: 'RemoteFX Network'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Current UDP Bandwidth'
  }
  {
    objectName: 'RemoteFX Network'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Current TCP Bandwidth'
  }
  {
    objectName: 'RemoteFX Network'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Current TCP RTT'
  }
  {
    objectName: 'RemoteFX Network'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Current UDP RTT'
  }
  {
    objectName: 'System'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Processor Queue Length'
  }
  {
    objectName: 'Terminal Services'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Inactive Sessions'
  }
  {
    objectName: 'Terminal Services'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Total Sessions'
  }
  {
    objectName: 'Terminal Services'
    instanceName: '*'
    intervalSeconds: 60
    counterName: 'Active Sessions'
  }
  {
    objectName: 'Terminal Services Session'
    instanceName: '*'
    intervalSeconds: 60
    counterName: '% Processor Time'
  }
  {
    objectName: 'User Input Delay per Process'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Max Input Delay'
  }
  {
    objectName: 'User Input Delay per Session'
    instanceName: '*'
    intervalSeconds: 30
    counterName: 'Max Input Delay'
  }
]

// =========== //
// Deployments //
// =========== //
// Azure log analytics workspace.
module avdAlaWorkspace '../../../carml/1.2.1/Microsoft.OperationalInsights/workspaces/deploy.bicep' = if (deployAlaWorkspace) {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdMonitoringRgName}')
  name: 'AVD-Log-Analytics-Workspace-${time}'
  params: {
    location: avdManagementPlaneLocation
    name: avdAlaWorkspaceName
    dataRetention: avdAlaWorkspaceDataRetention
    //tags: avdTags
  }
}

// Policy definitions.
module avdPolicyDefinitions '../../../carml/1.2.0/Microsoft.Authorization/policyDefinitions/subscription/deploy.bicep' = [for customPolicyDefinition in varCustomPolicyDefinitions: {
  scope: subscription('${avdWorkloadSubsId}')
  name: '${take(customPolicyDefinition.libDefinition.name, 46)}-${time}'
  //name: customPolicyDefinition.libDefinition.properties.displayName
  params: {
    location: avdManagementPlaneLocation
    name: customPolicyDefinition.name
    displayName: customPolicyDefinition.libDefinition.properties.displayName
    metadata: customPolicyDefinition.libDefinition.properties.metadata
    mode: customPolicyDefinition.libDefinition.properties.mode
    parameters: customPolicyDefinition.libDefinition.properties.parameters
    policyRule: customPolicyDefinition.libDefinition.properties.policyRule
  }
}]

// Policy set definition.
module avdPolicySetDefinitions '../../../carml/1.2.0/Microsoft.Authorization/policySetDefinitions/subscription/deploy.bicep' = {
  scope: subscription('${avdWorkloadSubsId}')
  name: 'AVD-Policy-Set-Definition-${time}'
  params: {
    location: avdManagementPlaneLocation
    name: varCustomPolicySetDefinitions.name
    description: varCustomPolicySetDefinitions.libSetDefinition.properties.description
    displayName: varCustomPolicySetDefinitions.libSetDefinition.properties.displayName
    metadata: varCustomPolicySetDefinitions.libSetDefinition.properties.metadata
    parameters: varCustomPolicySetDefinitions.libSetDefinition.properties.parameters
    policyDefinitions: [for policySetDef in varCustomPolicySetDefinitions.libSetChildDefinitions: {
      policyDefinitionReferenceId: policySetDef.definitionReferenceId
      policyDefinitionId: policySetDef.definitionId
      parameters: policySetDef.definitionParameters
    }]
    policyDefinitionGroups: []
  }
  dependsOn: [
    avdPolicyDefinitions
  ]
}

// Policy set assignment.
module avdPolicySetassignment '../../../carml/1.2.0/Microsoft.Authorization/policyAssignments/subscription/deploy.bicep' = {
  scope: subscription('${avdWorkloadSubsId}')
  name: 'AVD-Policy-Set-Assignment-${time}'
  params: {
    location: avdManagementPlaneLocation
    name: varCustomPolicySetDefinitions.name
    description: varCustomPolicySetDefinitions.libSetDefinition.properties.description
    displayName: varCustomPolicySetDefinitions.libSetDefinition.properties.displayName
    metadata: varCustomPolicySetDefinitions.libSetDefinition.properties.metadata
    identity: 'SystemAssigned'
    roleDefinitionIds: [
      '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
      '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
    ]
    parameters: {
      logAnalytics: {
        value: deployAlaWorkspace ? avdAlaWorkspace.outputs.resourceId : alaWorkspaceId
      }
    }
    policyDefinitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policySetDefinitions/policy-set-deploy-diagnostics-to-log-analytics'
  }
  dependsOn: [
    avdPolicySetDefinitions
    avdAlaWorkspace
  ]
}

// OS seetings
@batchSize(1)
module avdOsEvents '../../../carml/1.2.1/Microsoft.OperationalInsights/workspaces/dataSources/deploy.bicep' = [for (varWindowsEvent, i) in varWindowsEvents: {
  scope: resourceGroup('${varAvdOsSettingsAlaWorkspaceSubId}', '${varAvdOsSettingsAlaWorkspaceRgName}')
  name: 'AVD-Monitoring-OS-Events-${i}-${time}'
  params: {
    name: 'WindowsEvent${i}'
    kind: 'WindowsEvent'
    logAnalyticsWorkspaceName: deployAlaWorkspace ? avdAlaWorkspace.outputs.name: varAvdExistingAlaWorkspaceName
    eventLogName: varWindowsEvent.name
    eventTypes: varWindowsEvent.types
    tags: avdTags
  }
  dependsOn: [
    avdAlaWorkspace
  ]
}]

@batchSize(1)
module avdOsPerformanceCounters '../../../carml/1.2.1/Microsoft.OperationalInsights/workspaces/dataSources/deploy.bicep' = [for (varWindowsPerformanceCounter, i) in varWindowsPerformanceCounters: {
  scope: resourceGroup('${varAvdOsSettingsAlaWorkspaceSubId}', '${varAvdOsSettingsAlaWorkspaceRgName}')
  name: 'AVD-Monitoring-OS-Performance-Counters-${i}-${time}'
  params: {
    name: 'WindowsPerformanceCounter${i}'
    kind: 'WindowsPerformanceCounter'
    logAnalyticsWorkspaceName: deployAlaWorkspace ? avdAlaWorkspace.outputs.name: varAvdExistingAlaWorkspaceName
    objectName: varWindowsPerformanceCounter.objectName
    instanceName: varWindowsPerformanceCounter.instanceName
    intervalSeconds: varWindowsPerformanceCounter.intervalSeconds
    counterName: varWindowsPerformanceCounter.counterName
    tags: avdTags
  }
  dependsOn: [
    avdOsEvents
  ]
}]
