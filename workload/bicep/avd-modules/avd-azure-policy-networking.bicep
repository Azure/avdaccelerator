targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Required. Location where to deploy AVD management plane.')
param avdManagementPlaneLocation string

@description('Required. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('Required. AVD Resource Group Name for monitoring resources.')
param avdMonitoringRgName string

@description('Required.  Azure Storage Account name.')
param stgAccountForFlowLogsName string

@description('Required.  Azure log analytics workspace Resource Id .')
param alaWorkspaceResourceId string


@description('Required.  Azure log analytics workspace ID.')
param alaWorkspaceId string

@description('Required. Existing Azure Storage account for NSG flow logs. (Default: )')
param stgAccountForFlowLogsId string = ''

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
// Policy Set/Initiative Definition Parameter Variables

var varPolicySetDefinitionEsDeployAzurePolicyNetworkParameters = loadJsonContent('../../policies/networking/policy-sets/parameters/policy-set-definition-es-deploy-networking.parameters.json')

// This variable contains a number of objects that load in the custom Azure Policy Set/Initiative Defintions 
// This variable contains a number of objects that load in the custom Azure Policy Set/Initiative Defintions that are provided as part of the ESLZ/ALZ reference implementation - this is automatically created in the file 'infra-as-code\bicep\modules\policy\lib\policy_set_definitions\_policySetDefinitionsBicepInput.txt' via a GitHub action, that runs on a daily schedule, and is then manually copied into this variable.
var varCustomPolicySetDefinitions = {
  name: 'policy-set-deploy-networking'
  libSetDefinition: json(loadTextContent('../../policies/networking/policy-sets/policy-set-definition-es-deploy-networking.json'))
}


// =========== //
// Deployments //
// =========== //


// Storage account for NSG flow logs. If blank value passed - then to 

module deployStgAccountForFlowLogs '../../../carml/1.2.1/Microsoft.Storage/storageAccounts/deploy.bicep' = if (empty(stgAccountForFlowLogsId)) {
scope: resourceGroup ('${avdMonitoringRgName}')
name: length('Deploy-Stg-Account-for-Flow-Logs-${stgAccountForFlowLogsName}-${time}') > 64 ? substring('Deploy-Stg-Account-for-Flow-Logs-${stgAccountForFlowLogsName}-${time}',0,63) : 'Deploy-Stg-Account-for-Flow-Logs-${stgAccountForFlowLogsName}-${time}'
params: {
  location: avdManagementPlaneLocation
  tags: avdTags
  name: stgAccountForFlowLogsName
  storageAccountKind: 'StorageV2'
  publicNetworkAccess: 'Disabled'
  networkAcls: {
    bypass: 'AzureServices'
    defaultAction: 'Deny'
  }
}
  }
// Policy definitions.

// Policy set definition.
 
module avdNetworkingPolicySetDefinition '../../../carml/1.2.0/Microsoft.Authorization/policySetDefinitions/subscription/deploy.bicep' = {
  scope: subscription('${avdWorkloadSubsId}')
  name: length('AVD-Network-Policy-Set-Definition-${time}') > 64 ? substring('AVD-Network-Policy-Set-Definition-${time}',0,63) : 'AVD-Network-Policy-Set-Definition-${time}'
  params: {
    location: avdManagementPlaneLocation
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
module avdNetworkingPolicySetDefinitionAssignment '../../../carml/1.2.0/Microsoft.Authorization/policyAssignments/subscription/deploy.bicep' = {
  scope: subscription('${avdWorkloadSubsId}')
  name: length('AVD-Network-Policy-Set-Assign-${time}') > 64 ? substring('AVD-Network-Policy-Set-Assign-${time}',0,63) : 'AVD-Network-Policy-Set-Assign-${time}'
  params: {
    name: '${varCustomPolicySetDefinitions.name}-${avdWorkloadSubsId}'
    location: avdManagementPlaneLocation
    policyDefinitionId: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/policySetDefinitions/${varCustomPolicySetDefinitions.name}'
    identity: 'SystemAssigned'
    roleDefinitionIds: [
      '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
    ]
  }
  dependsOn: [ 
    avdNetworkingPolicySetDefinition
    deployStgAccountForFlowLogs
   ]
}



// =========== //
// Outputs     //
// =========== //
