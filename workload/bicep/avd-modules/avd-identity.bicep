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

@description('FSlogix Managed Identity name.')
param fslogixManagedIdentityName string

@description('GUID for built role Reader.')
param readerRoleId string

@description('GUID for built in role ID of Storage Account Contributor.')
param storageAccountContributorRoleId string

@description('GUID for built in role ID of Desktop Virtualization Power On Contributor.')
param desktopVirtualizationPowerOnContributorRoleId string

@description('GUID for built in role ID of Desktop Virtualization Power On Off Contributor.')
param desktopVirtualizationPowerOnOffContributorRoleId string

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

// Introduce wait for management VM to be ready.
module fslogixManagedIdentityWait '../../../carml/1.0.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  name: 'FSLogix-Identity-Wait-${time}'
  params: {
      name: 'AVD-fslogixManagedIdentityWait-${time}'
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
    fslogixManagedIdentity
  ]
}

// RBAC role Assignments.
// Start VM on connect compute RG.
module startVMonConnectRoleAssignCompute '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (enableStartVmOnConnect) {
  name: 'Start-VM-OnConnect-RoleAssign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnContributorRoleId}'
    principalId: avdEnterpriseAppObjectId
  }
}

// Start VM on connect service objects RG.
module startVMonConnectRoleAssignServiceObjects '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (enableStartVmOnConnect) {
  name: 'Start-VM-OnConnect-RoleAssign-${time}'
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
    principalId: createAvdFslogixDeployment ? fslogixManagedIdentity.outputs.principalId: ''
  }
  dependsOn: [
    fslogixManagedIdentityWait
  ]
}
//FSLogix reader.
module fslogixReaderRoleAssign '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) {
  name: 'fslogix-UserAIdentity-ReaderRoleAssign-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${readerRoleId}'
    principalId: createAvdFslogixDeployment ? fslogixManagedIdentity.outputs.principalId: ''
  }
  dependsOn: [
    fslogixManagedIdentityWait
  ]
}

//Scaling plan compute RG.
module scalingPlanRoleAssignCompute '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (avdDeployScalingPlan) {
  name: 'Scaling-Plan-Assign-Compute-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${avdWorkloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnOffContributorRoleId}' 
    principalId: avdEnterpriseAppObjectId
  }
  dependsOn: []
}

//Scaling plan service objects RG.
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
  name: 'AAD-VM-Role-Assign-${take('${avdApplicationGropupIdentityId}', 6)}-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: 'Virtual Machine User Login' 
    principalId: avdApplicationGropupIdentityId
  }
  dependsOn: []
}]

// VM AAD access roles service objects RG.
module avdAadIdentityLoginAccessServiceObjects '../../../carml/1.2.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' =  [for avdApplicationGropupIdentityId in avdApplicationGroupIdentitiesIds: if (avdIdentityServiceProvider == 'AAD' && !empty(avdApplicationGroupIdentitiesIds)) {
  name: 'AAD-VM-Role-Assign-${take('${avdApplicationGropupIdentityId}', 6)}-${time}'
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
output fslogixManagedIdentityResourceId string = (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) ? fslogixManagedIdentity.outputs.resourceId: ''
output fslogixManagedIdentityClientId string = (createAvdFslogixDeployment && (avdIdentityServiceProvider != 'AAD')) ? fslogixManagedIdentity.outputs.clientId: ''
