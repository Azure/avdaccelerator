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

@description('Deploy new session hosts.')
param avdDeploySessionHosts bool

@description('Configure start VM on connect.')
param enableStartVmOnConnect bool

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param avdIdentityServiceProvider string

@description('Required, Identity ID to grant RBAC role to access AVD application group.')
param avdApplicationGroupIdentitiesIds array

@description('Deploy scaling plan.')
param avdDeployScalingPlan bool

@description('Storage managed identity name.')
param storageManagedIdentityName string

@description('GUID for built role Reader.')
param readerRoleId string

@description('GUID for built in role ID of Storage Account Contributor.')
param storageAccountContributorRoleId string

@description('GUID for built in role ID of Desktop Virtualization Power On Contributor.')
param desktopVirtualizationPowerOnContributorRoleId string

@description('GUID for built in role ID of Desktop Virtualization Power On Off Contributor.')
param desktopVirtualizationPowerOnOffContributorRoleId string

@description('Optional. Deploy Storage setup.')
param createStorageDeployment bool

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Deployments //
// =========== //

// Managed identity for fslogix/msix app attach
module managedIdentity '../../../carml/1.2.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (createStorageDeployment && (avdIdentityServiceProvider != 'AAD')) {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  name: 'Managed-Identity-${time}'
  params: {
    name: storageManagedIdentityName
    location: avdSessionHostLocation
    tags: avdTags
  }
}

// Introduce wait for management VM to be ready.
module managedIdentityWait '../../../carml/1.0.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (createStorageDeployment && (avdIdentityServiceProvider != 'AAD')) {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  name: 'Storage-Identity-Wait-${time}'
  params: {
      name: 'AVD-storageManagedIdentityWait-${time}'
      location: avdSessionHostLocation
      azPowerShellVersion: '6.2'
      cleanupPreference: 'Always'
      timeout: 'PT10M'
      scriptContent: '''
      Write-Host "Start"
      Get-Date
      Start-Sleep -Seconds 60
      Write-Host "Stop"
      Get-Date
      '''
  }
  dependsOn: [
    managedIdentity
  ]
}

// RBAC role Assignments.
// Start VM on connect compute RG.
module startVMonConnectRoleAssignCompute '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (enableStartVmOnConnect && !avdDeployScalingPlan) {
  name: 'Start-OnConnect-RolAssignComp-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnContributorRoleId}'
    principalId: avdEnterpriseAppObjectId
  }
}


// Start VM on connect service objects RG.
module startVMonConnectRoleAssignServiceObjects '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (enableStartVmOnConnect && !avdDeployScalingPlan) {
  name: 'Start-OnConnect-RolAssignServ-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')

  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnContributorRoleId}'
    principalId: avdEnterpriseAppObjectId
  }
}

// FSLogix storage account contributor.
module fslogixRoleAssign '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) {
  name: 'fslogix-UserAIdentity-RoleAssign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${storageAccountContributorRoleId}'
    principalId: createStorageDeployment ? managedIdentity.outputs.principalId: ''
  }
  dependsOn: [
    managedIdentityWait
  ]
}
// Storage reader.
module readerRoleAssign '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createStorageDeployment && (avdIdentityServiceProvider != 'AAD')) {
  name: 'Storage-UserAIdentity-ReaderRoleAssign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${readerRoleId}'
    principalId: createStorageDeployment ? managedIdentity.outputs.principalId: ''
  }
  dependsOn: [
    managedIdentityWait
  ]
}

// Scaling plan compute RG.
module scalingPlanRoleAssignCompute '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (avdDeployScalingPlan) {
  name: 'Scaling-Plan-Assign-Compute-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnOffContributorRoleId}' 
    principalId: avdEnterpriseAppObjectId
  }
  dependsOn: []
}

// Scaling plan service objects RG.
module scalingPlanRoleAssignServiceObjects '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (avdDeployScalingPlan) {
  name: 'Scaling-Plan-Assign-Service-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnOffContributorRoleId}' 
    principalId: avdEnterpriseAppObjectId
  }
  dependsOn: []
}

// VM AAD access roles compute RG.
module avdAadIdentityLoginAccessCompute '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' =  [for avdApplicationGropupIdentityId in avdApplicationGroupIdentitiesIds: if (avdIdentityServiceProvider == 'AAD' && !empty(avdApplicationGroupIdentitiesIds)) {
  name: 'AAD-VM-Role-AssignComp-${take('${avdApplicationGropupIdentityId}', 6)}-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: 'Virtual Machine User Login' 
    principalId: avdApplicationGropupIdentityId
  }
  dependsOn: []
}]

// VM AAD access roles service objects RG.
module avdAadIdentityLoginAccessServiceObjects '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' =  [for avdApplicationGropupIdentityId in avdApplicationGroupIdentitiesIds: if (avdIdentityServiceProvider == 'AAD' && !empty(avdApplicationGroupIdentitiesIds)) {
  name: 'AAD-VM-Role-AssignServ-${take('${avdApplicationGropupIdentityId}', 6)}-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: 'Virtual Machine User Login' 
    principalId: avdApplicationGropupIdentityId
  }
  dependsOn: []
}]
//

// =========== //
// Outputs //
// =========== //
output managedIdentityResourceId string = (createStorageDeployment && (avdIdentityServiceProvider != 'AAD')) ? managedIdentity.outputs.resourceId: ''
output managedIdentityClientId string = (createStorageDeployment && (avdIdentityServiceProvider != 'AAD')) ? managedIdentity.outputs.clientId: ''
