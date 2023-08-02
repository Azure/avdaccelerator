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

@sys.description('Resource Group Name for temporal resources.')
param tempRgName string

@sys.description('Identity type to grant RBAC role to access AVD application group.')
param principalType string

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

@sys.description('Deploy Storage setup.')
param createSessionHosts bool

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varVirtualMachineUserLoginRoleId = 'fb879df8-f326-4884-b1cf-06f3ad86be52'
var varStorageSmbShareContributorRoleId = '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
var varStorageAccountContributorRoleId = '17d1049b-9a84-46fb-8f53-869881c3d3ab'
var varDesktopVirtualizationPowerOnContributorRoleId = '489581de-a3bd-480d-9518-53dea7416b33'
var varDesktopVirtualizationPowerOnOffContributorRoleId = '40c5ff49-9181-41f8-ae61-143b0e78555e'
var varContributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var varReaderRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
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
    name: 'StorageContributor'
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varStorageAccountContributorRoleId}'
  }
  {
    name: 'StorageReader'
    roleDefinitionIdOrName: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varReaderRoleId}'
  } 
]

// =========== //
// Deployments //
// =========== //

// Managed identity for fslogix/msix app attach
module managedIdentityStorage '.bicep/createManagedIdentity.bicep' = if (createStorageDeployment) {
  scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
  name: 'MI-Storage-${time}'
  params: {
    name: storageManagedIdentityName
    location: location
    tags: tags
  }
}

// Managed identity for fslogix/msix app attach
module managedIdentityCleanUp '.bicep/createManagedIdentity.bicep' = if (createStorageDeployment || createSessionHosts) {
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  name: 'MI-CleanUp-${time}'
  params: {
    name: storageManagedIdentityName
    location: location
    tags: tags
  }
}

// Start VM on connect role assignments
module startVMonConnectRoleAssignCompute './.bicep/roleAssignment.bicep' = [for computeAndServiceObjectsRg in computeAndServiceObjectsRgs: if (enableStartVmOnConnect && !deployScalingPlan) {
  name: 'StartOnCon-RolAssign-${computeAndServiceObjectsRg.name}-${time}'
  scope: resourceGroup('${subscriptionId}', '${computeAndServiceObjectsRg.rgName}')
  params: {
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varDesktopVirtualizationPowerOnContributorRoleId}'
    roleDefinitionName: 'PowerOnContributor'
    principalType: 'ServicePrincipal'
    principalId: avdEnterpriseObjectId
  }
}]

// Scaling plan role assignments
module scalingPlanRoleAssignCompute './.bicep/roleAssignment.bicep' = [for computeAndServiceObjectsRg in computeAndServiceObjectsRgs: if (deployScalingPlan) {
  name: 'ScalingPlan-RolAssign-${computeAndServiceObjectsRg.name}-${time}'
  scope: resourceGroup('${subscriptionId}', '${computeAndServiceObjectsRg.rgName}')
  params: {
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varDesktopVirtualizationPowerOnOffContributorRoleId}'
    roleDefinitionName: 'PowerOnOffContributor'
    principalType: 'ServicePrincipal'
    principalId: avdEnterpriseObjectId
  }
}]

// Storage role assignments
module storageContributorRoleAssign './.bicep/roleAssignment.bicep' = [for storageRoleAssignment in storageRoleAssignments: if (createStorageDeployment) {
  name: 'Stora-RolAssign-${storageRoleAssignment.name}-${time}'
  scope: resourceGroup('${subscriptionId}', '${storageRoleAssignment}')
  params: {
    roleDefinitionId: createStorageDeployment ? storageRoleAssignment.roleDefinitionIdOrName : ''
    roleDefinitionName: storageRoleAssignment.name
    principalType: 'ServicePrincipal'
    principalId: createStorageDeployment ? managedIdentityStorage.outputs.principalId : ''
  }
  dependsOn: [
    managedIdentityStorage
  ]
}]

// Storage File Data SMB Share Contributor.
module storageSmbShareContributorRoleAssign './.bicep/roleAssignment.bicep' = [for appGroupIdentitiesId in appGroupIdentitiesIds: if (createStorageDeployment && (identityServiceProvider == 'AAD') && (!empty(appGroupIdentitiesIds))) {
  name: 'Stora-SmbContri-RolAssign-${take('${appGroupIdentitiesId}', 6)}-${time}'
  scope: resourceGroup('${subscriptionId}', '${storageObjectsRgName}')
  params: {
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varStorageSmbShareContributorRoleId}'
    principalType: principalType
    roleDefinitionName: 'SMBShareContri'
    principalId: appGroupIdentitiesId
  }
}]

// VM AAD access roles compute RG.
module aadIdentityLoginRoleAssign './.bicep/roleAssignment.bicep' = [for appGroupIdentitiesId in appGroupIdentitiesIds: if (identityServiceProvider == 'AAD' && !empty(appGroupIdentitiesIds)) {
  name: 'VM-Login-Comp-${take('${appGroupIdentitiesId}', 6)}-${time}'
  scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
  params: {
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varVirtualMachineUserLoginRoleId}'
    principalType: principalType
    roleDefinitionName: 'Virtual Machine User Login'
    principalId: appGroupIdentitiesId
  }
}]

// VM AAD access roles service objects RG.
module aadIdentityLoginAccessServiceObjects './.bicep/roleAssignment.bicep' = [for appGroupIdentitiesId in appGroupIdentitiesIds: if (identityServiceProvider == 'AAD' && !empty(appGroupIdentitiesIds)) {
  name: 'VM-Login-Serv-${take('${appGroupIdentitiesId}', 6)}-${time}'
  scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
  params: {
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varVirtualMachineUserLoginRoleId}'
    principalType: principalType
    roleDefinitionName: 'Virtual Machine User Login'
    principalId: appGroupIdentitiesId
  }
}]

// Clean up contributor compute RG
module cleanUpRoleAssign './.bicep/roleAssignment.bicep' = if (createStorageDeployment || createSessionHosts) {
  name: 'Storage-ReaderRoleAssign-${time}'
  scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
  params: {
    roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varContributorRoleId}'
    principalType: 'ServicePrincipal'
    roleDefinitionName: 'Contributor'
    principalId: (createStorageDeployment || createSessionHosts) ? managedIdentityCleanUp.outputs.principalId : ''
  }
  dependsOn: [
    managedIdentityCleanUp
  ]
}
//

// =========== //
// Outputs //
// =========== //
output managedIdentityStorageResourceId string = (createStorageDeployment) ? managedIdentityStorage.outputs.resourceId : ''
output managedIdentityStorageClientId string = (createStorageDeployment) ? managedIdentityStorage.outputs.clientId : ''
output managedIdentityCleanUpResourceId string = (createStorageDeployment || createSessionHosts) ? managedIdentityCleanUp.outputs.resourceId : ''
output managedIdentityCleanUpClientId string = (createStorageDeployment || createSessionHosts) ? managedIdentityCleanUp.outputs.clientId : ''
