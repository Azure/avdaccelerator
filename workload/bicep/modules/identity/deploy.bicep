targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD session hosts.')
param location string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@sys.description('Resource Group Name for Azure Files.')
param storageObjectsRgName string

@sys.description('Azure Virtual Desktop service principal object ID.')
param avdServicePrincipalObjectId string

@sys.description('Azure Virtual Desktop ARM provider service principal object ID.')
param avdArmServicePrincipalObjectId string

@sys.description('Configure App Attach Role Assignments.')
param createAppAttachRoleAssignments bool

@sys.description('Configure start VM on connect.')
param enableStartVmOnConnect bool

@sys.description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Required, Identity ID to grant RBAC role to access AVD application group.')
param securityPrincipalId string

@sys.description('Deploy scaling plan.')
param deployScalingPlan bool

@sys.description('Storage managed identity name.')
param storageManagedIdentityName string

@sys.description('Deploy Storage setup.')
param createStorageDeployment bool

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varVirtualMachineUserLoginRole = {
  id: 'fb879df8-f326-4884-b1cf-06f3ad86be52'
  name: 'Virtual Machine User Login'
}
var varStorageSmbShareContributorRole = {
  id: '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
  name: 'Storage File Data SMB Share Contributor'
}
var varDesktopVirtualizationPowerOnContributorRole = {
  id: '489581de-a3bd-480d-9518-53dea7416b33'
  name: 'Desktop Virtualization Power On Contributor'
}
var varDesktopVirtualizationPowerOnOffContributorRole = {
  id: '40c5ff49-9181-41f8-ae61-143b0e78555e'
  name: 'Desktop Virtualization Power On Off Contributor'
}
var computeAndServiceObjectsRgs = [
  {
    name: 'ServiceObjects'
    rgName: computeObjectsRgName
  }
  {
    name: 'Compute'
    rgName: serviceObjectsRgName
  }
]
var storageRoleAssignments = [
  {
    name: 'Storage Account Contributor'
    acronym: 'StoraContri'
    id: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  }
  {
    name: 'Reader'
    acronym: 'Reader'
    id: 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
  }
]

var appAttachEntraIDPrincpals = [
  {
    name: 'AVD'
    id: avdServicePrincipalObjectId
  }
  {
    name: 'AVDARM'
    id: avdArmServicePrincipalObjectId
  }
]

// =========== //
// Deployments //
// =========== //

// Managed identity for fslogix/App Attach
module managedIdentityStorage '../../../../avm/1.0.0/res/managed-identity/user-assigned-identity/main.bicep' = if (createStorageDeployment && identityServiceProvider != 'EntraID') {
  scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
  name: 'MI-Storage-${time}'
  params: {
    name: storageManagedIdentityName
    location: location
    tags: tags
  }
}

// Start VM on connect role assignments
module startVMonConnectRoleAssignCompute '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = [
  for computeAndServiceObjectsRg in computeAndServiceObjectsRgs: if (enableStartVmOnConnect && !deployScalingPlan && !empty(avdServicePrincipalObjectId)) {
    name: 'StartOnCon-RolAssign-${computeAndServiceObjectsRg.name}-${time}'
    scope: resourceGroup('${subscriptionId}', '${computeAndServiceObjectsRg.rgName}')
    params: {
      roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varDesktopVirtualizationPowerOnContributorRole.id}'
      principalId: avdServicePrincipalObjectId
      resourceGroupName: computeAndServiceObjectsRg.rgName
      principalType: 'ServicePrincipal'
    }
  }
]

// Scaling plan role assignments
module scalingPlanRoleAssignCompute '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = [
  for computeAndServiceObjectsRg in computeAndServiceObjectsRgs: if (deployScalingPlan && !empty(avdServicePrincipalObjectId)) {
    name: 'ScalingPlan-RolAssign-${computeAndServiceObjectsRg.name}-${time}'
    scope: resourceGroup('${subscriptionId}', '${computeAndServiceObjectsRg.rgName}')
    params: {
      roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varDesktopVirtualizationPowerOnOffContributorRole.id}'
      principalId: avdServicePrincipalObjectId
      resourceGroupName: computeAndServiceObjectsRg.rgName
      subscriptionId: subscriptionId
      principalType: 'ServicePrincipal'
    }
  }
]

// Storage role assignments
module storageContributorRoleAssign '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = [
  for storageRoleAssignment in storageRoleAssignments: if (createStorageDeployment && identityServiceProvider != 'EntraID') {
    name: 'Stora-RolAssign-${storageRoleAssignment.acronym}-${time}'
    scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
    params: {
      roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${storageRoleAssignment.id}'
      principalId: createStorageDeployment ? managedIdentityStorage.outputs.principalId : ''
      resourceGroupName: storageObjectsRgName
      subscriptionId: subscriptionId
      principalType: 'ServicePrincipal'
    }
  }
]

// Storage File Data SMB Share Contributor
module storageSmbShareContributorRoleAssign '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = if (createStorageDeployment && (!empty(securityPrincipalId)) && identityServiceProvider != 'EntraID') {
  name: 'Stora-SmbContri-RolAssign${take('${securityPrincipalId}', 6)}-${time}'
  scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varStorageSmbShareContributorRole.id}'
    principalId: !empty(securityPrincipalId) ? securityPrincipalId : ''
    resourceGroupName: storageObjectsRgName
    subscriptionId: subscriptionId
    principalType: 'Group'
  }
}

// Azure Files Reader and Data Access for EntraID Identities with App Attach

module storageReaderandDataAccessRoleAssign '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = [
  for principal in appAttachEntraIDPrincpals: if (createAppAttachRoleAssignments) {
    name: 'Stora-ReaderData-RolAssign-${principal.name}-${time}'
    scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
    params: {
      principalId: principal.id
      roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/c12c1c16-33a1-487b-954d-41c89c60f349'
      resourceGroupName: storageObjectsRgName
      subscriptionId: subscriptionId
      principalType: 'ServicePrincipal'
    }
  }
]

// Virtual machine Microsoft Entra ID access roles on the compute resource group
module aadIdentityLoginRoleAssign '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = if (contains(
  identityServiceProvider,
  'EntraID'
) && !empty(securityPrincipalId)) {
  name: 'VM-Login-Comp-${take('${securityPrincipalId}', 6)}-${time}'
  scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varVirtualMachineUserLoginRole.id}'
    principalId: !empty(securityPrincipalId) ? securityPrincipalId : ''
    resourceGroupName: computeObjectsRgName
    subscriptionId: subscriptionId
    principalType: 'Group'
  }
}

// Virtual machine Microsoft Entra ID access roles on the service objects resource group
module aadIdentityLoginAccessServiceObjects '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = if (contains(
  identityServiceProvider,
  'EntraID'
) && !empty(securityPrincipalId)) {
  name: 'VM-Login-Serv-${take('${securityPrincipalId}', 6)}-${time}'
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varVirtualMachineUserLoginRole.id}'
    principalId: !empty(securityPrincipalId) ? securityPrincipalId : ''
    resourceGroupName: serviceObjectsRgName
    subscriptionId: subscriptionId
    principalType: 'Group'
  }
}

// =========== //
// Outputs //
// =========== //
output managedIdentityStorageResourceId string = (createStorageDeployment && identityServiceProvider != 'EntraID')
  ? managedIdentityStorage.outputs.resourceId
  : ''
output managedIdentityStorageClientId string = (createStorageDeployment && identityServiceProvider != 'EntraID') ? managedIdentityStorage.outputs.clientId : ''
