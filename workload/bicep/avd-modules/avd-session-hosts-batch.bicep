targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('AVD subnet ID.')
param subnetId string

@description('Required. Location where to deploy compute services.')
param sessionHostLocation string

@description('Required. Virtual machine time zone.')
param timeZone string

@description('AVD Session Host prefix.')
param sessionHostNamePrefix string

@description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@description('Required. Name of AVD service objects RG.')
param serviceObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Quantity of session hosts to deploy.')
param deploySessionHostsCount int

@description('The session host number to begin with for the deployment.')
param sessionHostCountIndex int

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set.')
param useAvailabilityZones bool

@description('Optional. Availablity Set name.')
param availabilitySetNamePrefix string

@description('Optional. Sets the number of fault domains for the availability set.')
param avsetFaultDomainCount int

@description('Optional. Sets the number of update domains for the availability set.')
param avsetUpdateDomainCount int

@description('Optional. Create new virtual network.')
param createAvdVnet bool

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@description('Required, Eronll session hosts on Intune.')
param createIntuneEnrollment bool

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@description('Session host VM size.')
param sessionHostsSize string

@description('Optional. Specifies the securityType of the virtual machine. Must be TrustedLaunch or ConfidentialVM enable UefiSettings.')
param securityType string

@description('Optional. Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool

@description('Optional. Specifies whether virtual TPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  securityType should be set to TrustedLaunch to enable UefiSettings.')
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

@description('Required. Name of keyvault that contains credentials.')
param wrklKvName string

@description('Required. AD domain name.')
param identityDomainName string

@description('Required. AVD session host domain join credentials.')
param domainJoinUserName string

@description('Optional. OU path to join AVd VMs.')
param sessionHostOuPath string

@description('Application Security Group (ASG) for the session hosts.')
param applicationSecurityGroupResourceId string

@description('AVD host pool token.')
param hostPoolToken string

@description('AVD Host Pool name.')
param hostPoolName string

@description('Location for the AVD agent installation package.')
param agentPackageLocation string

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

@description('Required. Tags to be applied to resources')
param tags object

@description('Optional. Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@description('Optional. Diagnostic logs retention.')
param diagnosticLogsRetentionInDays int

@description('Optional. Deploy AVD monitoring resources and setings. (Default: true)')
param deployMonitoring bool

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varAvdMaxSessionHostsPerTemplateDeployment = 30 // max number of session hosts that can be deployed from the avd-session-hosts.bicep file in each batch / for loop. Math: (800 - <Number of Static Resources>) / <Number of Looped Resources> 
var varDivisionValue = deploySessionHostsCount / varAvdMaxSessionHostsPerTemplateDeployment // This determines if any full batches are required.
var varDivisionRemainderValue = deploySessionHostsCount % varAvdMaxSessionHostsPerTemplateDeployment // This determines if any partial batches are required.
var varAvdSessionHostBatchCount = varDivisionRemainderValue > 0 ? varDivisionValue + 1 : varDivisionValue // This determines the total number of batches needed, whether full and / or partial.
var maxAvailabilitySetMembersCount = 199 // This is the max number of session hosts that can be deployed in an availability set.
var divisionAvSetValue = deploySessionHostsCount / maxAvailabilitySetMembersCount // This determines if any full availability sets are required.
var divisionAvSetRemainderValue = deploySessionHostsCount % maxAvailabilitySetMembersCount // This determines if any partial availability sets are required.
var availabilitySetCount = divisionAvSetRemainderValue > 0 ? divisionAvSetValue + 1 : divisionAvSetValue // This determines the total number of availability sets needed, whether full and / or partial.

// =========== //
// Deployments //
// =========== //

// Availability set.
module availabilitySet './avd-availability-sets.bicep' = if (!useAvailabilityZones) {
  name: 'AVD-Availability-Set-${time}'
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
  params: {
      avdWorkloadSubsId: workloadSubsId
      avdComputeObjectsRgName: computeObjectsRgName
      avdAvailabilitySetNamePrefix: availabilitySetNamePrefix
      avdSessionHostLocation: sessionHostLocation
      availabilitySetCount: availabilitySetCount
      avdAsFaultDomainCount: avsetFaultDomainCount
      avdAsUpdateDomainCount: avsetUpdateDomainCount
      avdTags: tags
  }
}

// Session hosts.
@batchSize(1)
module sessionHosts './avd-session-hosts.bicep' = [for i in range(1, varAvdSessionHostBatchCount): {
  scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
  name: 'AVD-SH-Batch-${i-1}-${time}'
  params: {
    agentPackageLocation: agentPackageLocation
    timeZone: timeZone
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
    sessionHostsCount: i == varAvdSessionHostBatchCount && varDivisionRemainderValue > 0 ? varDivisionRemainderValue : varAvdMaxSessionHostsPerTemplateDeployment
    sessionHostCountIndex: i == 1 ? sessionHostCountIndex : ((i - 1) * varAvdMaxSessionHostsPerTemplateDeployment) + sessionHostCountIndex
    sessionHostDiskType: sessionHostDiskType
    sessionHostLocation: sessionHostLocation
    sessionHostNamePrefix: sessionHostNamePrefix
    createAvdVnet: createAvdVnet
    sessionHostsSize: sessionHostsSize
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
    fsLogixScript: fsLogixScript
    fsLogixScriptArguments: fsLogixScriptArguments
    fslogixSharePath: fslogixSharePath
    fslogixScriptUri: fslogixScriptUri
    hostPoolToken: hostPoolToken
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
