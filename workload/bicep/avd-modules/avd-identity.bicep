targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Required. Location where to deploy AVD session hosts.')
param avdSessionHostLocation string

@description('Required. Location where to deploy AVD management plane.')
param avdManagementPlaneLocation string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('AVD Resource Group Name for the service objects.')
param avdServiceObjectsRgName string

@description('Resource Group name for the session hosts.')
param avdComputeObjectsRgName string

@description('Resource Group Name for Azure Files.')
param avdStorageObjectsRgName string

@description('Azure Virtual Desktop enterprise application object ID.')
param avdEnterpriseAppObjectId string

@description('Create custom Start VM on connect role.')
param createStartVmOnConnectCustomRole bool

@description('Deploy new session hosts.')
param avdDeploySessionHosts bool

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param avdIdentityServiceProvider string

@description('Required, Identity ID to grant RBAC role to access AVD application group.')
param avdApplicationGropupIdentitiesIds array

@description('Deploy scaling plan.')
param avdDeployScalingPlan bool

@description('FSlogix Managed Identity name.')
param fslogixManagedIdentityName string

@description('GUID for built role Reader.')
param readerRoleId string

@description('GUID for built in role ID of Storage Account Contributor.')
param storageAccountContributorRoleId string

@description('GUID for built in role ID of Desktop Virtualization Power On Off Contributor.')
param avdVmPowerStateContributor string

@description('Optional. Deploy Fslogix setup.')
param createAvdFslogixDeployment bool

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Deployments //
// =========== //

// FSLogix managed identity.
module fslogixManagedIdentity '../../../carml/1.2.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  name: 'fslogix-Managed-Identity-${time}'
  params: {
    name: fslogixManagedIdentityName
    location: avdSessionHostLocation
    tags: avdTags
  }
}

// RBAC Roles.
// Start VM on connect.
module startVMonConnectRole '../../../carml/1.2.0/Microsoft.Authorization/roleDefinitions/subscription/deploy.bicep' = if (createStartVmOnConnectCustomRole) {
  scope: subscription(avdWorkloadSubsId)
  name: 'Start-VM-on-Connect-Role-${time}'
  params: {
    subscriptionId: avdWorkloadSubsId
    description: 'Start VM on connect AVD'
    roleName: 'StartVMonConnect-AVD'
    location: avdSessionHostLocation
    actions: [
      'Microsoft.Compute/virtualMachines/start/action'
      'Microsoft.Compute/virtualMachines/*/read'
    ]
    assignableScopes: [
      '/subscriptions/${avdWorkloadSubsId}'
    ]
  }
}

// RBAC role Assignments.
// Start VM on connect.
module startVMonConnectRoleAssign '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createStartVmOnConnectCustomRole) {
  name: 'Start-VM-OnConnect-RoleAssign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: createStartVmOnConnectCustomRole ? startVMonConnectRole.outputs.resourceId : ''
    principalId: avdEnterpriseAppObjectId
  }
  dependsOn: [
    startVMonConnectRole
  ]
}

// FSLogix.
module fslogixRoleAssign '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) {
  name: 'fslogix-UserAIdentity-RoleAssign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${storageAccountContributorRoleId}'
    principalId: createAvdFslogixDeployment ? fslogixManagedIdentity.outputs.principalId: ''
  }
  dependsOn: []
}
//FSLogix reader.
module fslogixReaderRoleAssign '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) {
  name: 'fslogix-UserAIdentity-ReaderRoleAssign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${readerRoleId}'
    principalId: createAvdFslogixDeployment ? fslogixManagedIdentity.outputs.principalId: ''
  }
  dependsOn: []
}

//Scaling plan compute RG.
module scalingPlanRoleAssignCompute '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (avdDeployScalingPlan) {
  name: 'Scaling-Plan-Assign-Compute-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${avdVmPowerStateContributor}' 
    principalId: avdEnterpriseAppObjectId
  }
  dependsOn: []
}

//Scaling plan service objects RG.
module scalingPlanRoleAssignServiceObjects '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (avdDeployScalingPlan) {
  name: 'Scaling-Plan-Assign-Service-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${avdVmPowerStateContributor}' 
    principalId: avdEnterpriseAppObjectId
  }
  dependsOn: []
}

module avdAadIdentityLoginAccess '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' =  [for avdApplicationGropupIdentitiesIds in avdApplicationGropupIdentitiesIds: if (avdIdentityServiceProvider == 'AAD' && !empty(avdApplicationGropupIdentitiesIds)) {
  name: 'AAD-VM-Access-Role-Assign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: 'Virtual Machine User Login' 
    principalId: avdApplicationGropupIdentitiesIds
  }
  dependsOn: []
}]
//

// =========== //
// Outputs //
// =========== //
output fslogixManagedIdentityResourceId string = (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) ? fslogixManagedIdentity.outputs.resourceId: ''
output fslogixManagedIdentityClientId string = (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) ? fslogixManagedIdentity.outputs.clientId: ''
