targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('AVD subnet ID')
param avdSubnetId string

@description('Required. Location where to deploy compute services')
param avdSessionHostLocation string

@description('AVD Session Host prefix')
param avdSessionHostNamePrefix string

@description('Resource Group name for the session hosts')
param avdComputeObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario')
param avdWorkloadSubsId string 

@description('Quantity of session hosts to deploy')
param avdDeploySessionHostsCount int

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Defualt: true)')
param avdUseAvailabilityZones bool

@description('Optional. Availablity Set name')
param avdAvailabilitySetName string

@description('Optional. Sets the number of fault domains for the availability set.')
param avdAsFaultDomainCount int

@description('Optional. Sets the number of update domains for the availability set.')
param avdAsUpdateDomainCount int

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@description('Session host VM size')
param avdSessionHostsSize string 

@description('OS disk type for session host')
param avdSessionHostDiskType string 

@description('Market Place OS image')
param marketPlaceGalleryWindows object

@description('Set to deploy image from Azure Compute Gallery')
param useSharedImage bool

@description('Source custom image ID')
param avdImageTemplataDefinitionId string

@description('Fslogix Managed Identity Resource ID ')
param fslogixManagedIdentityResourceId string

@description('Local administrator username')
param avdVmLocalUserName string

@description('Local administrator password')
@secure()
param avdVmLocalUserPassword string

@description('Required. AD domain name')
param avdIdentityDomainName string

@description('Required. AVD session host domain join credentials')
param avdDomainJoinUserName string
@secure()
param avdDomainJoinUserPassword string

@description('Optional. OU path to join AVd VMs')
param avdOuPath string

@description('Application Security Group (ASG) for the session hosts')
param avdApplicationSecurityGroupResourceId string

@description('AVD host pool token')
param hostPoolToken string

@description('AVD Host Pool name')
param avdHostPoolName string

@description('Location for the AVD agent installation package. ')
param avdAgentPackageLocation string

@description('Deploy Fslogix setup')
param createAvdFslogixDeployment bool

@description('FSlogix configuration script file name. ')
param fsLogixScript string

@description('Configuration arguments for FSlogix')
param FsLogixScriptArguments string

@description('URI for FSlogix configuration script')
param fslogixScriptUri string

@description('Do not modify, used to set unique value for resource deployment')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var allAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', avdSessionHostLocation, 3)

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
module avdSessionHosts '../../../carml/1.2.0/Microsoft.Compute/virtualMachines/deploy.bicep' = [for i in range(0, avdDeploySessionHostsCount):  {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  name: 'AVD-Session-Host-${i}-${time}'
  params: {
      name: '${avdSessionHostNamePrefix}-${i}'
      location: avdSessionHostLocation
      userAssignedIdentities: createAvdFslogixDeployment ? {
          '${fslogixManagedIdentityResourceId}' : {} 
      }: {}
      availabilityZone: avdUseAvailabilityZones ? take(skip(allAvailabilityZones, i % length(allAvailabilityZones)), 1) : []
      encryptionAtHost: encryptionAtHost
      availabilitySetName: !avdUseAvailabilityZones ?  avdAvailabilitySet.outputs.name : ''
      osType: 'Windows'
      licenseType: 'Windows_Client'
      vmSize: avdSessionHostsSize
      imageReference: useSharedImage ? json('{\'id\': \'${avdImageTemplataDefinitionId}\'}') : marketPlaceGalleryWindows
      osDisk: {
          createOption: 'fromImage'
          deleteOption: 'Delete'
          diskSizeGB: 128
          managedDisk: {
              storageAccountType: avdSessionHostDiskType
          }
      }
      adminUsername: avdVmLocalUserName
      adminPassword: avdVmLocalUserPassword //avdWrklKeyVaultget.getSecret('avdVmLocalUserPassword') //avdVmLocalUserPassword // need to update to get value from KV
      nicConfigurations: [
          {
              nicSuffix: '-nic-01'
              deleteOption: 'Delete'
              asgId: !empty(avdApplicationSecurityGroupResourceId) ? avdApplicationSecurityGroupResourceId : null
              enableAcceleratedNetworking: false
              ipConfigurations: [
                  {
                      name: 'ipconfig01'
                      subnetId: avdSubnetId
                  }
              ]
          }
      ]
      // Join domain.
      allowExtensionOperations: true
      extensionDomainJoinPassword: avdDomainJoinUserPassword //avdWrklKeyVaultget.getSecret('avdDomainJoinUserPassword')
      extensionDomainJoinConfig: {
          enabled: true
          settings: {
              name: avdIdentityDomainName
              ouPath: !empty(avdOuPath) ? avdOuPath : null
              user: avdDomainJoinUserName
              restart: 'true'
              options: '3'
          }
      }
      // Enable and Configure Microsoft Malware.
      extensionAntiMalwareConfig: {
          enabled: true
          settings: {
              AntimalwareEnabled: true
              RealtimeProtectionEnabled: 'true'
              ScheduledScanSettings: {
                  isEnabled: 'true'
                  day: '7' // Day of the week for scheduled scan (1-Sunday, 2-Monday, ..., 7-Saturday)
                  time: '120' // When to perform the scheduled scan, measured in minutes from midnight (0-1440). For example: 0 = 12AM, 60 = 1AM, 120 = 2AM.
                  scanType: 'Quick' //Indicates whether scheduled scan setting type is set to Quick or Full (default is Quick)
              }
              Exclusions: createAvdFslogixDeployment ? {
                  Extensions: '*.vhd;*.vhdx'
                  Paths: '"%ProgramFiles%\\FSLogix\\Apps\\frxdrv.sys;%ProgramFiles%\\FSLogix\\Apps\\frxccd.sys;%ProgramFiles%\\FSLogix\\Apps\\frxdrvvt.sys;%TEMP%\\*.VHD;%TEMP%\\*.VHDX;%Windir%\\TEMP\\*.VHD;%Windir%\\TEMP\\*.VHDX;\\\\server\\share\\*\\*.VHD;\\\\server\\share\\*\\*.VHDX'
                  Processes: '%ProgramFiles%\\FSLogix\\Apps\\frxccd.exe;%ProgramFiles%\\FSLogix\\Apps\\frxccds.exe;%ProgramFiles%\\FSLogix\\Apps\\frxsvc.exe'
              } : {}
          }
      }
    }
    dependsOn: []
    }]

// Add session hosts to AVD Host pool.
module addAvdHostsToHostPool '../../vm-custom-extensions/add-avd-session-hosts.bicep' = [for i in range(0, avdDeploySessionHostsCount): {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  name: 'Add-AVD-Session-Host-${i}-to-HostPool-${time}'
  params: {
      location: avdSessionHostLocation
      hostPoolToken: hostPoolToken
      name: '${avdSessionHostNamePrefix}-${i}'
      hostPoolName: avdHostPoolName
      avdAgentPackageLocation: avdAgentPackageLocation
  }
  dependsOn: [
    avdSessionHosts
]
}]


// Add the registry keys for Fslogix. Alternatively can be enforced via GPOs.
module configureFsLogixForAvdHosts '../../vm-custom-extensions/configure-fslogix-session-hosts.bicep' = [for i in range(0, avdDeploySessionHostsCount): if (createAvdFslogixDeployment) {
  scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
  name: 'Configure-FsLogix-for-${i}-${time}'
  params: {
      location: avdSessionHostLocation
      name: '${avdSessionHostNamePrefix}-${i}'
      file: fsLogixScript
      FsLogixScriptArguments: FsLogixScriptArguments
      baseScriptUri: fslogixScriptUri
  }
  dependsOn: [
      avdSessionHosts
  ]
}]
