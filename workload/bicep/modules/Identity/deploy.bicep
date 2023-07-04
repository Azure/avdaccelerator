targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy AVD session hosts.')
param sessionHostLocation string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@sys.description('Resource Group Name for Azure Files.')
param storageObjectsRgName string

@sys.description('Azure Virtual Desktop enterprise application object ID.')
param enterpriseAppObjectId string

@sys.description('Configure start VM on connect.')
param enableStartVmOnConnect bool

@sys.description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Required, Identity ID to grant RBAC role to access AVD application group.')
param applicationGroupIdentitiesIds array

@sys.description('Deploy scaling plan.')
param deployScalingPlan bool

@sys.description('Storage managed identity name.')
param storageManagedIdentityName string

@sys.description('GUID for built role Reader.')
param readerRoleId string

@sys.description('GUID for built role Storage File Data SMB Share Contributor.')
param storageSmbShareContributorRoleId string

@sys.description('GUID for built in role ID of Storage Account Contributor.')
param storageAccountContributorRoleId string

@sys.description('GUID for built in role ID of Desktop Virtualization Power On Contributor.')
param desktopVirtualizationPowerOnContributorRoleId string

@sys.description('GUID for built in role ID of Desktop Virtualization Power On Off Contributor.')
param desktopVirtualizationPowerOnOffContributorRoleId string

@sys.description('Deploy Storage setup.')
param createStorageDeployment bool

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Managed identity for fslogix/msix app attach
module managedIdentity '../../../../carml/1.3.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (createStorageDeployment) {
  scope: resourceGroup('${workloadSubsId}', '${storageObjectsRgName}')
  name: 'Managed-Identity-${time}'
  params: {
    name: storageManagedIdentityName
    location: sessionHostLocation
    tags: tags
  }
}

// Introduce wait for management VM to be ready.
module managedIdentityWait '../../../../carml/1.3.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (createStorageDeployment) {
  scope: resourceGroup('${workloadSubsId}', '${storageObjectsRgName}')
  name: 'Managed-Identity-Wait-${time}'
  params: {
      name: 'Managed-Identity-Wait-${time}'
      location: sessionHostLocation
      azPowerShellVersion: '8.3.0'
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
module startVMonConnectRoleAssignCompute '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (enableStartVmOnConnect && !deployScalingPlan) {
  name: 'Start-OnConnect-RolAssignComp-${time}'
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${workloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnContributorRoleId}'
    principalId: enterpriseAppObjectId
  }
}

// Start VM on connect service objects RG.
module startVMonConnectRoleAssignServiceObjects '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (enableStartVmOnConnect && !deployScalingPlan) {
  name: 'Start-OnConnect-RolAssignServ-${time}'
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')

  params: {
    roleDefinitionIdOrName: '/subscriptions/${workloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnContributorRoleId}'
    principalId: enterpriseAppObjectId
  }
}

// Storage contributor.
module contributorRoleAssign '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createStorageDeployment) {
  name: 'UserAIdentity-ContributorRoleAssign-${time}'
  scope: resourceGroup('${workloadSubsId}', '${storageObjectsRgName}') 
  params: {
    roleDefinitionIdOrName: '/subscriptions/${workloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${storageAccountContributorRoleId}'
    principalId: createStorageDeployment ? managedIdentity.outputs.principalId: ''
  }
  dependsOn: [
    managedIdentityWait
  ]
}

// Storage reader.
module readerRoleAssign '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (createStorageDeployment) {
  name: 'Storage-ReaderRoleAssign-${time}'
  scope: resourceGroup('${workloadSubsId}', '${storageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${workloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${readerRoleId}'
    principalId: createStorageDeployment ? managedIdentity.outputs.principalId: ''
  }
  dependsOn: [
    managedIdentityWait
  ]
}

// Storage File Data SMB Share Contributor.
module storageSmbShareContributorRoleAssign '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = [for applicationGroupIdentitiesId in applicationGroupIdentitiesIds: if (createStorageDeployment && (identityServiceProvider == 'AAD') && (!empty(applicationGroupIdentitiesIds))) {
  name: 'Storage-SmbContributor-Role-Assign-${take('${applicationGroupIdentitiesId}', 6)}-${time}'
  scope: resourceGroup('${workloadSubsId}', '${storageObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${workloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${storageSmbShareContributorRoleId}'
    principalId: applicationGroupIdentitiesId
  }
  dependsOn: []
}]

// Scaling plan compute RG.
module scalingPlanRoleAssignCompute '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (deployScalingPlan) {
  name: 'Scaling-Plan-Assign-Compute-${time}'
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${workloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnOffContributorRoleId}' 
    principalId: enterpriseAppObjectId
  }
  dependsOn: []
}

// Scaling plan service objects RG.
module scalingPlanRoleAssignServiceObjects '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (deployScalingPlan) {
  name: 'Scaling-Plan-Assign-Service-${time}'
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  params: {
    roleDefinitionIdOrName: '/subscriptions/${workloadSubsId}/providers/Microsoft.Authorization/roleDefinitions/${desktopVirtualizationPowerOnOffContributorRoleId}' 
    principalId: enterpriseAppObjectId
  }
  dependsOn: []
}

// VM AAD access roles compute RG.
module aadIdentityLoginAccessCompute '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' =  [for avdApplicationGropupIdentityId in applicationGroupIdentitiesIds: if (identityServiceProvider == 'AAD' && !empty(applicationGroupIdentitiesIds)) {
  name: 'VM-Login-Comp-${take('${avdApplicationGropupIdentityId}', 6)}-${time}'
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
  params: {
    roleDefinitionIdOrName: 'Virtual Machine User Login' 
    principalId: avdApplicationGropupIdentityId
  }
  dependsOn: []
}]

// VM AAD access roles service objects RG.
module aadIdentityLoginAccessServiceObjects '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' =  [for avdApplicationGropupIdentityId in applicationGroupIdentitiesIds: if (identityServiceProvider == 'AAD' && !empty(applicationGroupIdentitiesIds)) {
  name: 'VM-Login-Serv-${take('${avdApplicationGropupIdentityId}', 6)}-${time}'
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
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
output managedIdentityResourceId string = (createStorageDeployment) ? managedIdentity.outputs.resourceId: ''
output managedIdentityClientId string = (createStorageDeployment) ? managedIdentity.outputs.clientId: ''
