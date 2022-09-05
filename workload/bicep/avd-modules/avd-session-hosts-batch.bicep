targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('AVD subnet ID.')
param avdSubnetId string

@description('Required. Location where to deploy compute services.')
param avdSessionHostLocation string

@description('Required. Virtual machine time zone.')
param avdTimeZone string

@description('AVD Session Host prefix.')
param avdSessionHostNamePrefix string

@description('Resource Group name for the session hosts.')
param avdComputeObjectsRgName string

@description('Required. Name of AVD service objects RG.')
param avdServiceObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('Quantity of session hosts to deploy.')
param avdDeploySessionHostsCount int

@description('The session host number to begin with for the deployment.')
param avdSessionHostCountIndex int

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Defualt: true)')
param avdUseAvailabilityZones bool

@description('Optional. Availablity Set name.')
param avdAvailabilitySetNamePrefix string

@description('Optional. Sets the number of fault domains for the availability set.')
param avdAsFaultDomainCount int

@description('Optional. Sets the number of update domains for the availability set.')
param avdAsUpdateDomainCount int

@description('Required, The service providing domain services for Azure Virtual Desktop. (Defualt: ADDS)')
param avdIdentityServiceProvider string

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@description('Session host VM size.')
param avdSessionHostsSize string

@description('OS disk type for session host.')
param avdSessionHostDiskType string

@description('Market Place OS image.')
param marketPlaceGalleryWindows object

@description('Set to deploy image from Azure Compute Gallery.')
param useSharedImage bool

@description('Source custom image ID.')
param avdImageTemplataDefinitionId string

@description('Fslogix Managed Identity Resource ID.')
param fslogixManagedIdentityResourceId string

@description('Local administrator username.')
param avdVmLocalUserName string

@description('Required. Name of keyvault that contains credentials.')
param avdWrklKvName string

@description('Required. AD domain name.')
param avdIdentityDomainName string

@description('Required. AVD session host domain join credentials.')
param avdDomainJoinUserName string

@description('Optional. OU path to join AVd VMs.')
param sessionHostOuPath string

@description('Application Security Group (ASG) for the session hosts.')
param avdApplicationSecurityGroupResourceId string

@description('AVD host pool token.')
param hostPoolToken string

@description('AVD Host Pool name.')
param avdHostPoolName string

@description('Location for the AVD agent installation package.')
param avdAgentPackageLocation string

@description('Deploy Fslogix setup.')
param createAvdFslogixDeployment bool

@description('FSlogix configuration script file name.')
param fsLogixScript string

@description('Configuration arguments for FSlogix.')
param FsLogixScriptArguments string

@description('URI for FSlogix configuration script.')
param fslogixScriptUri string

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

var avdMaxSessionHostsPerTemplateDeployment = 30 //50 // max number of session hosts that can be deployed from the avd-session-hosts.bicep file in each batch / for loop. Math: (800 - <Number of Static Resources>) / <Number of Looped Resources> 
var divisionValue = avdDeploySessionHostsCount / avdMaxSessionHostsPerTemplateDeployment // This determines if any full batches are required.
var divisionRemainderValue = avdDeploySessionHostsCount % avdMaxSessionHostsPerTemplateDeployment // This determines if any partial batches are required.
var avdSessionHostBatchCount = divisionRemainderValue > 0 ? divisionValue + 1 : divisionValue // This determines the total number of batches needed, whether full and / or partial.

var maxAvailabilitySetMembersCount = 20 //200 // This is the max number of session hosts that can be deployed in an availability set.
var divisionAvSetValue = avdDeploySessionHostsCount / maxAvailabilitySetMembersCount // This determines if any full availability sets are required.
var divisionAvSetRemainderValue = avdDeploySessionHostsCount % maxAvailabilitySetMembersCount // This determines if any partial availability sets are required.
var availabilitySetCount = divisionAvSetRemainderValue > 0 ? divisionAvSetValue + 1 : divisionAvSetValue // This determines the total number of availability sets needed, whether full and / or partial.


// =========== //
// Deployments //
// =========== //

// Availability set.
module avdAvailabilitySet './avd-availability-sets.bicep' = if (!avdUseAvailabilityZones) {
  name: 'AVD-Availability-Set-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
      avdWorkloadSubsId: avdWorkloadSubsId
      avdComputeObjectsRgName: avdComputeObjectsRgName
      avdAvailabilitySetNamePrefix: avdAvailabilitySetNamePrefix
      avdSessionHostLocation: avdSessionHostLocation
      availabilitySetCount: availabilitySetCount
      avdAsFaultDomainCount: avdAsFaultDomainCount
      avdAsUpdateDomainCount: avdAsUpdateDomainCount
      avdTags: avdTags
  }
}

// Session hosts.
@batchSize(1)
module avdSessionHosts './avd-session-hosts.bicep' = [for i in range(1, avdSessionHostBatchCount): {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  name: 'AVD-SH-Batch-${i-1}-${time}'
  params: {
    avdAgentPackageLocation: avdAgentPackageLocation
    avdTimeZone: avdTimeZone
    avdApplicationSecurityGroupResourceId: avdApplicationSecurityGroupResourceId
    avdAvailabilitySetNamePrefix: avdAvailabilitySetNamePrefix
    maxAvailabilitySetMembersCount: maxAvailabilitySetMembersCount
    avdComputeObjectsRgName: avdComputeObjectsRgName
    avdDomainJoinUserName: avdDomainJoinUserName
    avdWrklKvName: avdWrklKvName
    avdServiceObjectsRgName: avdServiceObjectsRgName
    avdHostPoolName: avdHostPoolName
    avdIdentityDomainName: avdIdentityDomainName
    avdImageTemplataDefinitionId: avdImageTemplataDefinitionId
    sessionHostOuPath: sessionHostOuPath
    avdSessionHostsCount: i == avdSessionHostBatchCount && divisionRemainderValue > 0 ? divisionRemainderValue : avdMaxSessionHostsPerTemplateDeployment
    avdSessionHostCountIndex: i == 1 ? avdSessionHostCountIndex : ((i - 1) * avdMaxSessionHostsPerTemplateDeployment) + avdSessionHostCountIndex
    avdSessionHostDiskType: avdSessionHostDiskType
    avdSessionHostLocation: avdSessionHostLocation
    avdSessionHostNamePrefix: avdSessionHostNamePrefix
    avdSessionHostsSize: avdSessionHostsSize
    avdSubnetId: avdSubnetId
    avdUseAvailabilityZones: avdUseAvailabilityZones
    avdVmLocalUserName: avdVmLocalUserName
    avdWorkloadSubsId: avdWorkloadSubsId
    encryptionAtHost: encryptionAtHost
    createAvdFslogixDeployment: createAvdFslogixDeployment
    fslogixManagedIdentityResourceId: fslogixManagedIdentityResourceId
    fsLogixScript: fsLogixScript
    FsLogixScriptArguments: FsLogixScriptArguments
    fslogixScriptUri: fslogixScriptUri
    hostPoolToken: hostPoolToken
    marketPlaceGalleryWindows: marketPlaceGalleryWindows
    useSharedImage: useSharedImage
    avdIdentityServiceProvider: avdIdentityServiceProvider
    avdTags: avdTags
  }
  dependsOn: [
  ]
}]
