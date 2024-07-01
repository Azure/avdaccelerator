targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD management plane.')
param location string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('Exisintg Azure log analytics workspace.')
param alaWorkspaceId string

@sys.description('AVD Resource Group Name for the compute resources.')
param computeObjectsRgName string

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('AVD Resource Group Name for the network resources.')
param networkObjectsRgName string

@sys.description('AVD Resource Group Name for the storage resources.')
param storageObjectsRgName string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
// Target RGs for policy assignment
var varComputeServObjRgs = [
  {
    rgName: computeObjectsRgName
  }
  {
    rgName: serviceObjectsRgName
  }
]
var varNetworkObjRgs = !empty(networkObjectsRgName) ? [
  {
    rgName: networkObjectsRgName
  }
] : []
var varStorageObjRgs = !empty(storageObjectsRgName) ? [
  {
    rgName: storageObjectsRgName
  }
] : []
var varPolicyAssignmentRgs = union(varComputeServObjRgs, varNetworkObjRgs, varStorageObjRgs)

// Policy Set/Initiative Definition Parameter Variables
var varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters = loadJsonContent('../../../policies/monitoring/policySets/parameters/policy-set-definition-es-deploy-diagnostics-to-log-analytics.parameters.json')

// This variable contains a number of objects that load in the custom Azure Policy Defintions that are provided as part of the ESLZ/ALZ reference implementation. 
var varCustomPolicyDefinitions = [
  {
    deploymentName: 'App-Group-Diag'
    libDefinition: json(loadTextContent('../../../policies/monitoring/policyDefinitions/policy-definition-es-deploy-diagnostics-avd-application-group.json'))
  }
  {
    deploymentName: 'Host-Pool-Diag'
    libDefinition: json(loadTextContent('../../../policies/monitoring/policyDefinitions/policy-definition-es-deploy-diagnostics-avd-host-pool.json'))
  }
  {
    deploymentName: 'Scaling-Plan-Diag'
    libDefinition: json(loadTextContent('../../../policies/monitoring/policyDefinitions/policy-definition-es-deploy-diagnostics-avd-scaling-plan.json'))
  }
  {
    deploymentName: 'Workspace-Diag'
    libDefinition: json(loadTextContent('../../../policies/monitoring/policyDefinitions/policy-definition-es-deploy-diagnostics-avd-workspace.json'))
  }
  {
    deploymentName: 'NSG-Diag'
    libDefinition: json(loadTextContent('../../../policies/monitoring/policyDefinitions/policy-definition-es-deploy-diagnostics-network-security-group.json'))
  }
  {
    deploymentName: 'NIC-Diag'
    libDefinition: json(loadTextContent('../../../policies/monitoring/policyDefinitions/policy-definition-es-deploy-diagnostics-nic.json'))
  }
  {
    deploymentName: 'VM-Diag'
    libDefinition: json(loadTextContent('../../../policies/monitoring/policyDefinitions/policy-definition-es-deploy-diagnostics-virtual-machine.json'))
  }
  {
    deploymentName: 'vNet-Diag'
    libDefinition: json(loadTextContent('../../../policies/monitoring/policyDefinitions/policy-definition-es-deploy-diagnostics-virtual-network.json'))
  }
  {
    deploymentName: 'Azure-Files-Diag'
    libDefinition: json(loadTextContent('../../../policies/monitoring/policyDefinitions/policy-definition-es-deploy-diagnostics-azure-files.json'))
  }
]

// This variable contains a number of objects that load in the custom Azure Policy Set/Initiative Defintions that are provided as part of the ESLZ/ALZ reference implementation - this is automatically created in the file 'infra-as-code\bicep\modules\policy\lib\policy_set_definitions\_policySetDefinitionsBicepInput.txt' via a GitHub action, that runs on a daily schedule, and is then manually copied into this variable.
var varCustomPolicySetDefinitions = {
  deploymentName: 'policy-set-avd-diagnostics'
  libSetDefinition: json(loadTextContent('../../../policies/monitoring/policySets/policy-set-definition-es-deploy-diagnostics-to-log-analytics.json'))
  libSetChildDefinitions: [
    {
      definitionReferenceId: 'AVDAppGroupDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-application-group'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDAppGroupDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AVDHostPoolsDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-host-pool'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDHostPoolsDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AVDScalingPlansDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-scaling-plan'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDScalingPlansDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AVDWorkspaceDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-avd-workspace'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AVDWorkspaceDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-network-security-group'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.NetworkSecurityGroupsDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'NetworkNICDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-nic'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.NetworkNICDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'VirtualMachinesDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-virtual-machine'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.VirtualMachinesDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'VirtualNetworkDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-virtual-network'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.VirtualNetworkDeployDiagnosticLogDeployLogAnalytics.parameters
    }
    {
      definitionReferenceId: 'AzureFilesDeployDiagnosticLogDeployLogAnalytics'
      definitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/policy-deploy-diagnostics-azure-files'
      definitionParameters: varPolicySetDefinitionEsDeployDiagnosticsLoganalyticsParameters.AzureFilesDeployDiagnosticLogDeployLogAnalytics.parameters
    }
  ]
}

// =========== //
// Deployments //
// =========== //

// Policy definitions.
module policyDefinitions './policyDefinitionsSubscriptions.bicep' = [for customPolicyDefinition in varCustomPolicyDefinitions: {
  scope: subscription('${subscriptionId}')
  name: 'Policy-Defin-${customPolicyDefinition.deploymentName}-${time}'
  params: {
    name: customPolicyDefinition.libDefinition.name
    displayName: customPolicyDefinition.libDefinition.properties.displayName
    metadata: customPolicyDefinition.libDefinition.properties.metadata
    mode: customPolicyDefinition.libDefinition.properties.mode
    parameters: customPolicyDefinition.libDefinition.properties.parameters
    policyRule: customPolicyDefinition.libDefinition.properties.policyRule
  }
}]

// Policy set definition.
module policySetDefinitions './policySetDefinitionsSubscriptions.bicep' = {
  scope: subscription('${subscriptionId}')
  name: 'Policy-Set-Definition-${time}'
  params: {
    name: varCustomPolicySetDefinitions.libSetDefinition.name
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
    policyDefinitions
  ]
}

// Policy set assignment.
module policySetAssignment '../../../../avm/1.0.0/ptn/authorization/policy-assignment/modules/resource-group.bicep' = [for policyAssignmentRg in varPolicyAssignmentRgs: {
  scope: resourceGroup('${subscriptionId}', '${policyAssignmentRg.rgName}')
  name: 'Policy-Set-Assignment-${time}'
  params: {
    location: location
    name: varCustomPolicySetDefinitions.libSetDefinition.name
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
        value: alaWorkspaceId
      }
    }
    policyDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/policySetDefinitions/policy-set-deploy-avd-diagnostics-to-log-analytics'
  }
  dependsOn: [
    policySetDefinitions
  ]
}]

// Policy set remediation.
module policySetRemediation '../../../../avm/1.0.0/ptn/policy-insights/remediation/modules/resource-group.bicep' = [for (policyAssignmentRg, i) in varPolicyAssignmentRgs: {
  scope: resourceGroup('${subscriptionId}', '${policyAssignmentRg.rgName}')
  name: 'Remm-Diag-${varCustomPolicySetDefinitions.deploymentName}-${i}'
  params: {
    name: '${varCustomPolicySetDefinitions.deploymentName}-${i}'
    policyAssignmentId: policySetAssignment[i].outputs.resourceId
}
}]

// =========== //
// Outputs     //
// =========== //
