targetScope = 'resourceGroup'

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

@description('Optional. Availablity Set name.')
param avdAvailabilitySetNamePrefix string

@description('Optional. Availablity Set max members.')
param maxAvailabilitySetMembersCount int

@description('Resource Group name for the session hosts')
param avdComputeObjectsRgName string

@description('Resource Group name for the session hosts')
param avdServiceObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('Quantity of session hosts to deploy')
param avdSessionHostsCount int

@description('The session host number to begin with for the deployment.')
param avdSessionHostCountIndex int

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set. (Defualt: true)')
param avdUseAvailabilityZones bool

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
param avdImageTemplateDefinitionId string

@description('Fslogix Managed Identity Resource ID.')
param fslogixManagedIdentityResourceId string

@description('Local administrator username.')
param avdVmLocalUserName string

@description('Required. AD domain name.')
param avdIdentityDomainName string

@description('Required. AVD session host domain join credentials.')
param avdDomainJoinUserName string

@description('Required, The service providing domain services for Azure Virtual Desktop. (Defualt: ADDS)')
param avdIdentityServiceProvider string

@description('Required. Name of keyvault that contains credentials.')
param avdWrklKvName string

@description('Optional. OU path to join AVd VMs')
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
var varAllAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', avdSessionHostLocation, 3)

// =========== //
// Deployments //
// =========== //
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
    name: avdWrklKvName
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
}

// Session hosts.
module avdSessionHosts '../../../carml/1.2.0/Microsoft.Compute/virtualMachines/deploy.bicep' = [for i in range(1, avdSessionHostsCount): {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'AVD-Session-Host-${padLeft((i + avdSessionHostCountIndex), 3, '0')}-${time}'
    params: {
        name: '${avdSessionHostNamePrefix}-${padLeft((i + avdSessionHostCountIndex), 3, '0')}'
        location: avdSessionHostLocation
        timeZone: avdTimeZone
        userAssignedIdentities: createAvdFslogixDeployment ? {
            '${fslogixManagedIdentityResourceId}': {}
        } : {}
        availabilityZone: avdUseAvailabilityZones ? take(skip(varAllAvailabilityZones, i % length(varAllAvailabilityZones)), 1) : []
        encryptionAtHost: encryptionAtHost
        availabilitySetName: !avdUseAvailabilityZones ? '${avdAvailabilitySetNamePrefix}-${padLeft(((1 + (i + avdSessionHostCountIndex) / maxAvailabilitySetMembersCount)), 3, '0')}': ''
        osType: 'Windows'
        licenseType: 'Windows_Client'
        vmSize: avdSessionHostsSize
        imageReference: useSharedImage ? json('{\'id\': \'${avdImageTemplateDefinitionId}\'}') : marketPlaceGalleryWindows
        osDisk: {
            createOption: 'fromImage'
            deleteOption: 'Delete'
            diskSizeGB: 128
            managedDisk: {
                storageAccountType: avdSessionHostDiskType
            }
        }
        adminUsername: avdVmLocalUserName
        adminPassword: avdWrklKeyVaultget.getSecret('avdVmLocalUserPassword')
        nicConfigurations: [
            {
                nicSuffix: 'nic-001-'
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
        extensionDomainJoinPassword: avdWrklKeyVaultget.getSecret('avdDomainJoinUserPassword')
        extensionDomainJoinConfig: {
            enabled: true
            settings: {
                name: avdIdentityDomainName
                ouPath: !empty(sessionHostOuPath) ? sessionHostOuPath : null
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
        tags: avdTags
    }
    dependsOn: []
}]

// Add session hosts to AVD Host pool.
module addAvdHostsToHostPool '../../vm-custom-extensions/add-avd-session-hosts.bicep' = [for i in range(1, avdSessionHostsCount): {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'Add-AVD-SH-${padLeft((i + avdSessionHostCountIndex), 3, '0')}-to-HP-${time}'
    params: {
        location: avdSessionHostLocation
        hostPoolToken: hostPoolToken
        name: '${avdSessionHostNamePrefix}-${padLeft((i + avdSessionHostCountIndex), 3, '0')}'
        hostPoolName: avdHostPoolName
        avdAgentPackageLocation: avdAgentPackageLocation
    }
    dependsOn: [
        avdSessionHosts
    ]
}]

// Add the registry keys for Fslogix. Alternatively can be enforced via GPOs.
module configureFsLogixForAvdHosts '../../vm-custom-extensions/configure-fslogix-session-hosts.bicep' = [for i in range(1, avdSessionHostsCount): if (createAvdFslogixDeployment) {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdComputeObjectsRgName}')
    name: 'Configure-FsLogix-for-${padLeft((i + avdSessionHostCountIndex), 3, '0')}-${time}'
    params: {
        location: avdSessionHostLocation
        name: '${avdSessionHostNamePrefix}-${padLeft((i + avdSessionHostCountIndex), 3, '0')}'
        file: fsLogixScript
        FsLogixScriptArguments: FsLogixScriptArguments
        baseScriptUri: fslogixScriptUri
    }
    dependsOn: [
        avdSessionHosts
    ]
}]
