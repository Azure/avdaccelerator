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
  //  name: 'policy-deploy-diagnostics-storage-account'
  //  libDefinition: json(loadTextContent('../../policies/policy-definitions/policy-definition-es-deploy-diagnostics-virtual-network.json'))
  //}
]

// This variable contains a number of objects that load in the custom Azure Policy Set/Initiative Defintions that are provided as part of the ESLZ/ALZ reference implementation - this is automatically created in the file 'infra-as-code\bicep\modules\policy\lib\policy_set_definitions\_policySetDefinitionsBicepInput.txt' via a GitHub action, that runs on a daily schedule, and is then manually copied into this variable.
var varCustomPolicySetDefinitions = {
  name: 'policy-set-deploy-avd-diagnostics-to-log-analytics'
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
    tags: avdTags
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

// =========== //
// Outputs     //
// =========== //
