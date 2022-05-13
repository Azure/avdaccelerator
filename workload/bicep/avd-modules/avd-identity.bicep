targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Required. Location where to deploy AVD management plane')
param avdManagementPlaneLocation string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario')
param avdWorkloadSubsId string

@description('AVD Resource Group Name for the service objects')
param avdServiceObjectsRgName string

@description('Resource Group name for the session hosts')
param avdComputeObjectsRgName string

@description('Resource Group Name for Azure Files')
param avdStorageObjectsRgName string

@description('Azure Virtual Desktop enterprise application object ID')
param avdEnterpriseAppObjectId string

@description('Create custom Start VM on connect role')
param createStartVmOnConnectCustomRole bool

@description('Deploy new session hosts')
param avdDeploySessionHosts bool

@description('FSlogix Managed Identity name')
param fslogixManagedIdentityName string

@description('GUID for built role Reader')
param readerRoleId string

@description('GUID for built in role ID of Storage Account Contributor')
param storageAccountContributorRoleId string

@description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

// =========== //
// Deployments //
// =========== //

// FSLogix managed identity.
module fslogixManagedIdentity '../../../carml/1.2.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (avdDeploySessionHosts) {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
  name: 'fslogix-Managed-Identity-${time}'
  params: {
      name: fslogixManagedIdentityName
      location: avdManagementPlaneLocation
  }
}

// RBAC Roles.
module startVMonConnectRole '../../../carml/1.2.0/Microsoft.Authorization/roleDefinitions/subscription/deploy.bicep' = if (createStartVmOnConnectCustomRole) {
  scope: subscription(avdWorkloadSubsId)
  name: 'Start-VM-on-Connect-Role-${time}'
  params: {
      subscriptionId: avdWorkloadSubsId
      description: 'Start VM on connect AVD'
      roleName: 'StartVMonConnect-AVD'
      location: avdManagementPlaneLocation
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

module fslogixConnectRoleAssign '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (avdDeploySessionHosts) {
  name: 'fslogix-UserAIdentity-RoleAssign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  params: {
      roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${storageAccountContributorRoleId}'
      principalId: fslogixManagedIdentity.outputs.principalId
  }
  dependsOn: [
      fslogixManagedIdentity
  ]
}

module fslogixConnectReaderRoleAssign '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (avdDeploySessionHosts) {
  name: 'fslogix-UserAIdentity-ReaderRoleAssign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  params: {
      roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${readerRoleId}'
      principalId: fslogixManagedIdentity.outputs.principalId
  }
  dependsOn: [
      fslogixManagedIdentity
  ]
}

// =========== //
// Outputs //
// =========== //
output fslogixManagedIdentityResourceId string = fslogixManagedIdentity.outputs.resourceId
