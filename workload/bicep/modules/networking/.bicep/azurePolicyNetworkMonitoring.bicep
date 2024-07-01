targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD management plane.')
param managementPlaneLocation string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@sys.description('AVD Resource Group Name for monitoring resources.')
param monitoringRgName string

@sys.description(' Azure Storage Account name.')
param stgAccountForFlowLogsName string

@sys.description(' Azure log analytics workspace Resource Id .')
param alaWorkspaceResourceId string

@sys.description(' Azure log analytics workspace ID.')
param alaWorkspaceId string

@sys.description('Existing Azure Storage account for NSG flow logs. (Default: )')
param stgAccountForFlowLogsId string = ''

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
// Policy Set/Initiative Definition Parameter Variables

// var varPolicySetDefinitionEsDeployAzurePolicyNetworkParameters = loadJsonContent('../../policies/networking/policy-sets/parameters/policy-set-definition-es-deploy-networking.parameters.json')

// This variable contains a number of objects that load in the custom Azure Policy Set/Initiative Defintions 
// This variable contains a number of objects that load in the custom Azure Policy Set/Initiative Defintions that are provided as part of the ESLZ/ALZ reference implementation - this is automatically created in the file 'infra-as-code\bicep\modules\policy\lib\policy_set_definitions\_policySetDefinitionsBicepInput.txt' via a GitHub action, that runs on a daily schedule, and is then manually copied into this variable.
var varCustomPolicySetDefinitions = {
  name: 'policy-set-deploy-networking'
  libSetDefinition: json(loadTextContent('../../../../policies/networking/policy-sets/policy-set-definition-es-deploy-networking.json'))
}

// =========== //
// Deployments //
// =========== //

// Storage account for NSG flow logs. If blank value passed - then to 

module deployStgAccountForFlowLogs '../../../../../avm/1.0.0/res/storage/storage-account/main.bicep' = if (empty(stgAccountForFlowLogsId)) {
  scope: resourceGroup('${monitoringRgName}')
  name: (length('Deploy-Stg-Account-for-Flow-Logs-${stgAccountForFlowLogsName}-${time}') > 64) ? take('Deploy-Stg-Account-for-Flow-Logs-${stgAccountForFlowLogsName}-${time}', 64) : 'Deploy-Stg-Account-for-Flow-Logs-${stgAccountForFlowLogsName}-${time}'
  params: {
    location: managementPlaneLocation
    tags: tags
    name: stgAccountForFlowLogsName
    kind: 'StorageV2'
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}
// Policy definitions.

// Policy set definition.

module networkingPolicySetDefinition '../../azurePolicies/policySetDefinitionsSubscriptions.bicep' = {
  scope: subscription('${workloadSubsId}')
  name: (length('NetPolicySetDefini-${time}') > 64) ? take('AVD-Network-Policy-Set-Definition-${time}', 64) : 'AVD-Network-Policy-Set-Definition-${time}'
  params: {
    name: varCustomPolicySetDefinitions.name
    description: varCustomPolicySetDefinitions.libSetDefinition.properties.description
    displayName: varCustomPolicySetDefinitions.libSetDefinition.properties.displayName
    metadata: varCustomPolicySetDefinitions.libSetDefinition.properties.metadata
    parameters: varCustomPolicySetDefinitions.libSetDefinition.properties.parameters
    policyDefinitions: varCustomPolicySetDefinitions.libSetDefinition.properties.policyDefinitions
    policyDefinitionGroups: varCustomPolicySetDefinitions.libSetDefinition.properties.policyDefinitionGroups

  }
}

// Policy set assignment.
module networkingPolicySetDefinitionAssignment '../../../../../avm/1.0.0/ptn/authorization/policy-assignment/modules/subscription.bicep' = {
  scope: subscription('${workloadSubsId}')
  name: (length('NetPolicySetAssign-${time}') > 64) ? take('AVD-NetPolicySetAssign-${time}', 64) : 'AVD-NetPolicySetAssign-${time}'
  params: {
    name: (length('${varCustomPolicySetDefinitions.name}-${workloadSubsId}') > 64) ? take('${varCustomPolicySetDefinitions.name}-${workloadSubsId}', 64) : '${varCustomPolicySetDefinitions.name}-${workloadSubsId}'
    displayName: varCustomPolicySetDefinitions.libSetDefinition.properties.displayName
    description: varCustomPolicySetDefinitions.libSetDefinition.properties.description
    location: managementPlaneLocation
    policyDefinitionId: '/subscriptions/${workloadSubsId}/providers/Microsoft.Authorization/policySetDefinitions/${varCustomPolicySetDefinitions.name}'
    identity: 'SystemAssigned'
    roleDefinitionIds: [
      '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    ]
    parameters: {
      nsgRegion: { value: managementPlaneLocation }
      storageId: { value: (empty(stgAccountForFlowLogsId)) ? '${deployStgAccountForFlowLogs.outputs.resourceId}' : stgAccountForFlowLogsId }
      workspaceResourceId: { value: alaWorkspaceResourceId }
      workspaceRegion: { value: managementPlaneLocation }
      workspaceId: { value: alaWorkspaceId }
      networkWatcherRG: { value: 'NetworkWatcherRG' }
      networkWatcherName: { value: 'NetworkWatcher_${managementPlaneLocation}' }

    }
  }
  dependsOn: [
    networkingPolicySetDefinition
    deployStgAccountForFlowLogs
  ]
}
// =========== //
// Outputs     //
// =========== //
