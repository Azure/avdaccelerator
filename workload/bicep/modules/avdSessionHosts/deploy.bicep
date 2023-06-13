targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('AVD disk encryption set resource ID to enable server side encyption.')
param diskEncryptionSetResourceId string

@description('AVD subnet ID.')
param subnetId string

@description('Location where to deploy compute services.')
param sessionHostLocation string

@description('Virtual machine time zone.')
param computeTimeZone string

@description('AVD Session Host prefix.')
param sessionHostNamePrefix string

@description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@description('Name of AVD service objects RG.')
param serviceObjectsRgName string

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Quantity of session hosts to deploy.')
param deploySessionHostsCount int

@description('The session host number to begin with for the deployment.')
param sessionHostCountIndex int

@description('Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set.')
param useAvailabilityZones bool

@description('Availablity Set name.')
param availabilitySetNamePrefix string

@description('Sets the number of fault domains for the availability set.')
param availabilitySetFaultDomainCount int

@description('Sets the number of update domains for the availability set.')
param availabilitySetUpdateDomainCount int

@description('Create new virtual network.')
param createAvdVnet bool

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@description('Required, Eronll session hosts on Intune.')
param createIntuneEnrollment bool

@description('This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@description('Session host VM size.')
param sessionHostsSize string

@description('Enables accelerated Networking on the session hosts.')
param enableAcceleratedNetworking bool

@description('Specifies the securityType of the virtual machine. Must be TrustedLaunch or ConfidentialVM enable UefiSettings.')
param securityType string

@description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool

@description('Specifies whether virtual TPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  securityType should be set to TrustedLaunch to enable UefiSettings.')
param vTpmEnabled bool

@description('OS disk type for session host.')
param sessionHostDiskType string

@description('Market Place OS image.')
param marketPlaceGalleryWindows object

@description('Set to deploy image from Azure Compute Gallery.')
param useSharedImage bool

@description('Source custom image ID.')
param avdImageTemplateDefinitionId string

@description('Storage Managed Identity Resource ID.')
param storageManagedIdentityResourceId string

@description('Local administrator username.')
param vmLocalUserName string

@description('Name of keyvault that contains credentials.')
param wrklKvName string

@description('AD domain name.')
param identityDomainName string

@description('AVD session host domain join credentials.')
param domainJoinUserName string

@description('OU path to join AVd VMs.')
param sessionHostOuPath string

@description('Application Security Group (ASG) for the session hosts.')
param applicationSecurityGroupResourceId string

@description('AVD Host Pool name.')
param hostPoolName string

@description('Location for the AVD agent installation package.')
param avdAgentPackageLocation string

@description('Deploy Fslogix setup.')
param createAvdFslogixDeployment bool

@description('FSlogix configuration script file name.')
param fsLogixScript string

@description('Configuration arguments for FSlogix.')
param fsLogixScriptArguments string

@description('Path for the FSlogix share.')
param fslogixSharePath string

@description('URI for FSlogix configuration script.')
param fslogixScriptUri string

@description('Tags to be applied to resources')
param tags object

@description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@description('Diagnostic logs retention.')
param diagnosticLogsRetentionInDays int

@description('Deploy AVD monitoring resources and setings. (Default: true)')
param deployMonitoring bool

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varMaxSessionHostsPerTemplateDeployment = 30 // max number of session hosts that can be deployed from the avd-session-hosts.bicep file in each batch / for loop. Math: (800 - <Number of Static Resources>) / <Number of Looped Resources> 
var varDivisionValue = deploySessionHostsCount / varMaxSessionHostsPerTemplateDeployment // This determines if any full batches are required.
var varDivisionRemainderValue = deploySessionHostsCount % varMaxSessionHostsPerTemplateDeployment // This determines if any partial batches are required.
var varAvdSessionHostBatchCount = varDivisionRemainderValue > 0 ? varDivisionValue + 1 : varDivisionValue // This determines the total number of batches needed, whether full and / or partial.
var maxAvailabilitySetMembersCount = 199 // This is the max number of session hosts that can be deployed in an availability set.
var divisionAvSetValue = deploySessionHostsCount / maxAvailabilitySetMembersCount // This determines if any full availability sets are required.
var divisionAvSetRemainderValue = deploySessionHostsCount % maxAvailabilitySetMembersCount // This determines if any partial availability sets are required.
var availabilitySetCount = divisionAvSetRemainderValue > 0 ? divisionAvSetValue + 1 : divisionAvSetValue // This determines the total number of availability sets needed, whether full and / or partial.
// =========== //
// Deployments //
// =========== //

// Call on the hotspool.
resource getHostPool 'Microsoft.DesktopVirtualization/hostPools@2019-12-10-preview' existing = {
  name: hostPoolName
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
}

// Availability set.
module availabilitySet './.bicep/availabilitySets.bicep' = if (!useAvailabilityZones) {
  name: 'AVD-Availability-Set-${time}'
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
  params: {
      workloadSubsId: workloadSubsId
      computeObjectsRgName: computeObjectsRgName
      availabilitySetNamePrefix: availabilitySetNamePrefix
      sessionHostLocation: sessionHostLocation
      availabilitySetCount: availabilitySetCount
      availabilitySetFaultDomainCount: availabilitySetFaultDomainCount
      availabilitySetUpdateDomainCount: availabilitySetUpdateDomainCount
      tags: tags
  }
}

// Session hosts.
@batchSize(1)
module sessionHosts './.bicep/avdSessionHosts.bicep' = [for i in range(1, varAvdSessionHostBatchCount): {
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
  name: 'AVD-SH-Batch-${i-1}-${time}'
  params: {
    diskEncryptionSetResourceId: diskEncryptionSetResourceId 
    avdAgentPackageLocation: avdAgentPackageLocation
    timeZone: computeTimeZone
    applicationSecurityGroupResourceId: applicationSecurityGroupResourceId
    availabilitySetNamePrefix: availabilitySetNamePrefix
    maxAvailabilitySetMembersCount: maxAvailabilitySetMembersCount
    computeObjectsRgName: computeObjectsRgName
    domainJoinUserName: domainJoinUserName
    wrklKvName: wrklKvName
    serviceObjectsRgName: serviceObjectsRgName
    hostPoolName: hostPoolName
    identityDomainName: identityDomainName
    imageTemplateDefinitionId: avdImageTemplateDefinitionId
    sessionHostOuPath: sessionHostOuPath
    sessionHostsCount: i == varAvdSessionHostBatchCount && varDivisionRemainderValue > 0 ? varDivisionRemainderValue : varMaxSessionHostsPerTemplateDeployment
    sessionHostCountIndex: i == 1 ? sessionHostCountIndex : (((i - 1) * varMaxSessionHostsPerTemplateDeployment) + sessionHostCountIndex)
    sessionHostDiskType: sessionHostDiskType
    sessionHostLocation: sessionHostLocation
    sessionHostNamePrefix: sessionHostNamePrefix
    sessionHostsSize: sessionHostsSize
    enableAcceleratedNetworking: enableAcceleratedNetworking
    securityType: securityType
    secureBootEnabled: secureBootEnabled
    vTpmEnabled: vTpmEnabled
    subnetId: subnetId
    useAvailabilityZones: useAvailabilityZones
    vmLocalUserName: vmLocalUserName
    workloadSubsId: workloadSubsId
    encryptionAtHost: encryptionAtHost
    createAvdFslogixDeployment: createAvdFslogixDeployment
    storageManagedIdentityResourceId: storageManagedIdentityResourceId
    fsLogixScriptFile: fsLogixScript
    fsLogixScriptArguments: fsLogixScriptArguments
    fslogixSharePath: fslogixSharePath
    fslogixScriptUri: fslogixScriptUri
    hostPoolToken: getHostPool.properties.registrationInfo.token
    marketPlaceGalleryWindows: marketPlaceGalleryWindows
    useSharedImage: useSharedImage
    identityServiceProvider: identityServiceProvider
    createIntuneEnrollment: createIntuneEnrollment
    tags: tags
    deployMonitoring: deployMonitoring
    alaWorkspaceResourceId: alaWorkspaceResourceId
    diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
  }
  dependsOn: [
    availabilitySet
  ]
}]
/*
// GPU policy definitions.
module gpuPolicies './.bicep/gpuAzurePolicies.bicep' = {
  scope: subscription('${workloadSubsId}')
  name: 'Custom-Policy-GPU-${time}'
  params: {
    subscriptionId: workloadSubsId
    location: sessionHostLocation
  }
}
*/
