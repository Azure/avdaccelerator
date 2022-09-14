targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@description('Required. Location where to deploy compute services.')
param avdSessionHostLocation string

@description('Optional. Availablity Set name.')
param avdAvailabilitySetNamePrefix string

@description('Optional. Availablity Set count.')
param availabilitySetCount int

@description('Optional. Sets the number of fault domains for the availability set.')
param avdAsFaultDomainCount int

@description('Optional. Sets the number of update domains for the availability set.')
param avdAsUpdateDomainCount int

@description('Resource Group name for the session hosts.')
param avdComputeObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Availability set.
module avdAvailabilitySet '../../../carml/1.2.0/Microsoft.Compute/availabilitySets/deploy.bicep' = [for i in range(1, availabilitySetCount): {
    name: 'AVD-AvSet--${i}-${time}'
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    params: {
        name: '${avdAvailabilitySetNamePrefix}-${padLeft(i, 3, '0')}'
        location: avdSessionHostLocation
        availabilitySetFaultDomain: avdAsFaultDomainCount
        availabilitySetUpdateDomain: avdAsUpdateDomainCount
        tags: avdTags
    }
}]


param Availability string
param DiskEncryption bool
param DiskSku string
param DomainName string
param DomainServices string
param EphemeralOsDisk bool
param ImageSku string
param KerberosEncryption string
param Location string
param ManagedIdentityResourceId string
param NamingStandard string
param PooledHostPool bool
param RecoveryServices bool
param SasToken string
param ScriptsUri string
param SecurityPrincipalIds array
param SecurityPrincipalNames array
param SessionHostCount int
param SessionHostIndex int
param StartVmOnConnect bool
param StorageCount int
param StorageSolution string
param Tags object
param Timestamp string
param VirtualNetwork string
param VirtualNetworkResourceGroup string
param VmSize string


var SecurityPrincipalIdsCount = length(SecurityPrincipalIds)
var SecurityPrincipalNamesCount = length(SecurityPrincipalNames)


resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ds-${NamingStandard}-validation'
  location: Location
  tags: Tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${ManagedIdentityResourceId}': {}
    }
  }
  properties: {
    forceUpdateTag: Timestamp
    azPowerShellVersion: '5.4'
    arguments: '-Availability ${Availability} -DiskEncryption ${DiskEncryption} -DiskSku ${DiskSku} -DomainName ${DomainName} -DomainServices ${DomainServices} -EphemeralOsDisk ${EphemeralOsDisk} -ImageSku ${ImageSku} -KerberosEncryption ${KerberosEncryption} -Location ${Location} -PooledHostPool ${PooledHostPool} -RecoveryServices ${RecoveryServices} -SecurityPrincipalIdsCount ${SecurityPrincipalIdsCount} -SecurityPrincipalNamesCount ${SecurityPrincipalNamesCount} -SessionHostCount ${SessionHostCount} -SessionHostIndex ${SessionHostIndex} -StartVmOnConnect ${StartVmOnConnect} -StorageCount ${StorageCount} -StorageSolution ${StorageSolution} -VmSize ${VmSize} -VnetName ${VirtualNetwork} -VnetResourceGroupName ${VirtualNetworkResourceGroup}'
    primaryScriptUri: '${ScriptsUri}Get-Validation.ps1${SasToken}'
    timeout: 'PT2H'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

output acceleratedNetworking string = deploymentScript.properties.outputs.acceleratedNetworking
output anfActiveDirectory string = deploymentScript.properties.outputs.anfActiveDirectory
output anfDnsServers string = deploymentScript.properties.outputs.anfDnsServers
output anfSubnetId string = deploymentScript.properties.outputs.anfSubnetId
output dnsForwarders array = deploymentScript.properties.outputs.dnsForwarders
output dnsServerSize string = deploymentScript.properties.outputs.dnsServerSize
output ephemeralOsDisk string = deploymentScript.properties.outputs.ephemeralOsDisk
