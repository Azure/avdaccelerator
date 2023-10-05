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

@sys.description('Azure Virtual Desktop enterprise application object ID.')
param avdEnterpriseObjectId string

@sys.description('Configure start VM on connect.')
param enableStartVmOnConnect bool

@sys.description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Required, Identity ID to grant RBAC role to access AVD application group.')
param appGroupIdentitiesIds array

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

// =========== //
// Deployments //
// =========== //

// Managed identity for fslogix/msix app attach
module managedIdentityStorage '../../../../carml/1.3.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (createStorageDeployment) {
  scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
  name: 'MI-Storage-${time}'
  params: {
    name: storageManagedIdentityName
    location: location
    tags: tags
  }
}

// Start VM on connect role assignments
module startVMonConnectRoleAssignCompute '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for computeAndServiceObjectsRg in computeAndServiceObjectsRgs: if (enableStartVmOnConnect && !deployScalingPlan) {
  name: 'StartOnCon-RolAssign-${computeAndServiceObjectsRg.name}-${time}'
  scope: resourceGroup('${subscriptionId}', '${computeAndServiceObjectsRg.rgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varDesktopVirtualizationPowerOnContributorRole.id}'
    principalId: avdEnterpriseObjectId
  }
}]

// Scaling plan role assignments
module scalingPlanRoleAssignCompute '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for computeAndServiceObjectsRg in computeAndServiceObjectsRgs: if (deployScalingPlan) {
  name: 'ScalingPlan-RolAssign-${computeAndServiceObjectsRg.name}-${time}'
  scope: resourceGroup('${subscriptionId}', '${computeAndServiceObjectsRg.rgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varDesktopVirtualizationPowerOnOffContributorRole.id}'
    principalId: avdEnterpriseObjectId
  }
}]

// Storage role assignments
module storageContributorRoleAssign '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for storageRoleAssignment in storageRoleAssignments: if (createStorageDeployment) {
  name: 'Stora-RolAssign-${storageRoleAssignment.acronym}-${time}'
  scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${storageRoleAssignment.id}'
    principalId: createStorageDeployment ? managedIdentityStorage.outputs.principalId : ''
  }
  dependsOn: [
    managedIdentityStorage
  ]
}]

// Storage File Data SMB Share Contributor
module storageSmbShareContributorRoleAssign '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for appGroupIdentitiesId in appGroupIdentitiesIds: if (createStorageDeployment && (identityServiceProvider == 'AAD') && (!empty(appGroupIdentitiesIds))) {
  name: 'Stora-SmbContri-RolAssign-${take('${appGroupIdentitiesId}', 6)}-${time}'
  scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varStorageSmbShareContributorRole.id}'
    principalId: appGroupIdentitiesId
  }
}]

// VM AAD access roles compute RG
module aadIdentityLoginRoleAssign '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for appGroupIdentitiesId in appGroupIdentitiesIds: if (identityServiceProvider == 'AAD' && !empty(appGroupIdentitiesIds)) {
  name: 'VM-Login-Comp-${take('${appGroupIdentitiesId}', 6)}-${time}'
  scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varVirtualMachineUserLoginRole.id}'
    principalId: appGroupIdentitiesId
  }
}]

// VM AAD access roles service objects RG
module aadIdentityLoginAccessServiceObjects '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for appGroupIdentitiesId in appGroupIdentitiesIds: if (identityServiceProvider == 'AAD' && !empty(appGroupIdentitiesIds)) {
  name: 'VM-Login-Serv-${take('${appGroupIdentitiesId}', 6)}-${time}'
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varVirtualMachineUserLoginRole.id}'
    principalId: appGroupIdentitiesId
  }
}]

// =========== //
// Outputs //
// =========== //
output managedIdentityStorageResourceId string = (createStorageDeployment) ? managedIdentityStorage.outputs.resourceId : ''
output managedIdentityStorageClientId string = (createStorageDeployment) ? managedIdentityStorage.outputs.clientId : ''
