targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('AVD subnet ID.')
param avdSubnetId string

@description('Required. Location where to deploy compute services.')
param avdSessionHostLocation string

@description('AVD Session Host prefix.')
param avdSessionHostNamePrefix string

@description('Resource Group name for the session hosts.')
param avdComputeObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string 

@description('Quantity of session hosts to deploy.')
param avdDeploySessionHostsCount int

@description('The session host number to begin with for the deployment.')
param avdSessionHostCountIndex int

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Defualt: true)')
param avdUseAvailabilityZones bool

@description('Optional. Availablity Set name.')
param avdAvailabilitySetName string

@description('Optional. Sets the number of fault domains for the availability set.')
param avdAsFaultDomainCount int

@description('Optional. Sets the number of update domains for the availability set.')
param avdAsUpdateDomainCount int

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

@description('Local administrator password.')
@secure()
param avdVmLocalUserPassword string

@description('Required. AD domain name.')
param avdIdentityDomainName string

@description('Required. AVD session host domain join credentials.')
param avdDomainJoinUserName string
@secure()
param avdDomainJoinUserPassword string

@description('Optional. OU path to join AVd VMs.')
param avdOuPath string

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

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var allAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', avdSessionHostLocation, 3)

// Batching baseline logic for session hosts and availability sets provided by @jamasten (Jason Masten))
var avdMaxResourcesPerTemplateDeployment = 50 // max number of session hosts that can be deployed from the avd-session-hosts.bicep file in each batch / for loop. Math: (800 - <Number of Static Resources>) / <Number of Looped Resources> 
var divisionValue = avdDeploySessionHostsCount / avdMaxResourcesPerTemplateDeployment // This determines if any full batches are required.
var divisionRemainderValue = avdDeploySessionHostsCount % avdMaxResourcesPerTemplateDeployment // This determines if any partial batches are required.
var avdSessionHostBatchCount = divisionRemainderValue > 0 ? divisionValue + 1 : divisionValue // This determines the total number of batches needed, whether full and / or partial.

var maxAvailabilitySetMembersCount = 200 // This is the max number of session hosts that can be deployed in an availability set.
var divisionAvSetValue = avdDeploySessionHostsCount / maxAvailabilitySetMembersCount // This determines if any full availability sets are required.
var divisionAvSetRemainderValue = avdDeploySessionHostsCount % maxAvailabilitySetMembersCount // This determines if any partial availability sets are required.
var availabilitySetMembersCount = divisionAvSetRemainderValue > 0 ? divisionAvSetValue + 1 : divisionAvSetValue // This determines the total number of availability sets needed, whether full and / or partial.
//

// =========== //
// Deployments //
// =========== //

// Availability set.
module avdAvailabilitySet '../../../carml/1.2.0/Microsoft.Compute/availabilitySets/deploy.bicep' = if (!avdUseAvailabilityZones) {
  name: 'AVD-Availability-Set-${time}'
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  params: {
      name: avdAvailabilitySetName
      location: avdSessionHostLocation
      availabilitySetFaultDomain: avdAsFaultDomainCount
      availabilitySetUpdateDomain: avdAsUpdateDomainCount
  }
}

// Session hosts.
@batchSize(1)
module avdSessionHosts 'avd-modules/avd-session-hosts.bicep' = [for i in range(1, avdSessionHostBatchCount):  {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  name: 'AVD-SH-Batch-${i-1}-${time}'
  params: {
      name: '${avdSessionHostNamePrefix}-${i-1}'
      location: avdSessionHostLocation
      userAssignedIdentities: createAvdFslogixDeployment ? {
    }
    
  }
}]
