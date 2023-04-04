targetScope = 'resourceGroup'

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

@description('Optional. Availablity Set name.')
param availabilitySetNamePrefix string

@description('Optional. Availablity Set max members.')
param maxAvailabilitySetMembersCount int

@description('Resource Group name for the session hosts')
param computeObjectsRgName string

@description('Resource Group name for the session hosts')
param serviceObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Quantity of session hosts to deploy')
param sessionHostsCount int

@description('Optional. Create new virtual network.')
param createAvdVnet bool

@description('The session host number to begin with for the deployment.')
param avdSessionHostCountIndex int

@description('Optional. Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set.')
param useAvailabilityZones bool

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@description('Session host VM size.')
param sessionHostsSize string

@description('Optional. Specifies the securityType of the virtual machine. It is set as TrustedLaunch to enable UefiSettings.')
param securityType string

@description('Optional. Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool

@description('Optional. Specifies whether the virtual TPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  securityType should be set to TrustedLaunch to enable UefiSettings.')
param vTpmEnabled bool

@description('Optional. Enable accelerated networking on the session host VMs.')
param enableAcceleratedNetworking bool

@description('OS disk type for session host.')
param sessionHostDiskType string

@description('Market Place OS image.')
param marketPlaceGalleryWindows object

@description('Set to deploy image from Azure Compute Gallery.')
param useSharedImage bool

@description('Source custom image ID.')
param imageTemplateDefinitionId string

@description('Fslogix Managed Identity Resource ID.')
param storageManagedIdentityResourceId string

@description('Local administrator username.')
param vmLocalUserName string

@description('Required. AD domain name.')
param identityDomainName string

@description('Required. AVD session host domain join credentials.')
param domainJoinUserName string

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@description('Required, Eronll session hosts on Intune.')
param createIntuneEnrollment bool

@description('Required. Name of keyvault that contains credentials.')
param wrklKvName string

@description('Optional. OU path to join AVd VMs')
param sessionHostOuPath string

@description('Application Security Group for the session hosts.')
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
var varAllAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', sessionHostLocation, 3)
var varNicDiagnosticMetricsToEnable = [
    'AllMetrics'
  ]
// =========== //
// Deployments //
// =========== //
// Get keyvault.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (identityServiceProvider != 'AAD') {
    name: wrklKvName
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
}

// Session hosts.
module avdSessionHosts '../../../carml/1.2.0/Microsoft.Compute/virtualMachines/deploy.bicep' = [for i in range(1, sessionHostsCount): {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'Session-Host-${padLeft((i + avdSessionHostCountIndex), 3, '0')}-${time}'
    params: {
        name: '${sessionHostNamePrefix}-${padLeft((i + avdSessionHostCountIndex), 3, '0')}'
        location: sessionHostLocation
        timeZone: timeZone
        userAssignedIdentities: createAvdFslogixDeployment ? {
            '${storageManagedIdentityResourceId}': {}
        } : {}
        systemAssignedIdentity: (identityServiceProvider == 'AAD') ? true: false
        availabilityZone: useAvailabilityZones ? take(skip(varAllAvailabilityZones, i % length(varAllAvailabilityZones)), 1) : []
        encryptionAtHost: encryptionAtHost
        availabilitySetName: !useAvailabilityZones ? '${availabilitySetNamePrefix}-${padLeft(((1 + (i + avdSessionHostCountIndex) / maxAvailabilitySetMembersCount)), 3, '0')}': ''
        osType: 'Windows'
        licenseType: 'Windows_Client'
        vmSize: sessionHostsSize
        securityType: securityType
        secureBootEnabled: secureBootEnabled
        vTpmEnabled: vTpmEnabled
        imageReference: useSharedImage ? json('{\'id\': \'${imageTemplateDefinitionId}\'}') : marketPlaceGalleryWindows
        osDisk: {
            createOption: 'fromImage'
            deleteOption: 'Delete'
            diskSizeGB: 128
            managedDisk: {
                storageAccountType: sessionHostDiskType
            }
        }
        adminUsername: vmLocalUserName
        adminPassword: avdWrklKeyVaultget.getSecret('avdVmLocalUserPassword')
        nicConfigurations: [
            {
                nicSuffix: 'nic-001-'
                deleteOption: 'Delete'
                enableAcceleratedNetworking: enableAcceleratedNetworking
                ipConfigurations: createAvdVnet ? [
                    {
                        name: 'ipconfig01'
                        subnetId: subnetId
                        applicationSecurityGroups: applicationSecurityGroupResourceId
                    }
                ] : [
                    {
                        name: 'ipconfig01'
                        subnetId: subnetId
                    }
                ]
            }
        ]
        // ADDS or AADDS domain join.
        extensionDomainJoinPassword: avdWrklKeyVaultget.getSecret('avdDomainJoinUserPassword')
        extensionDomainJoinConfig: {
            enabled: (identityServiceProvider == 'AAD') ? false: true
            settings: {
                name: identityDomainName
                ouPath: !empty(sessionHostOuPath) ? sessionHostOuPath : null
                user: domainJoinUserName
                restart: 'true'
                options: '3'
            }
        }
        // Azure AD (AAD) Join.
        extensionAadJoinConfig: {
            enabled: (identityServiceProvider == 'AAD') ? true: false
            settings: createIntuneEnrollment ? {
                mdmId: '0000000a-0000-0000-c000-000000000000'
            }: {}
        }
            //}: {
            //    enabled: (identityServiceProvider == 'AAD') ? true: false
            //}
        // Enable and Configure Microsoft Malware.
        /*
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
                    Paths: '"%ProgramFiles%\\FSLogix\\Apps\\frxdrv.sys;%ProgramFiles%\\FSLogix\\Apps\\frxccd.sys;%ProgramFiles%\\FSLogix\\Apps\\frxdrvvt.sys;%TEMP%\\*.VHD;%TEMP%\\*.VHDX;%Windir%\\TEMP\\*.VHD;%Windir%\\TEMP\\*.VHDX;${fslogixSharePath}\\*\\*.VHD;${fslogixSharePath}\\*\\*.VHDX'
                    Processes: '%ProgramFiles%\\FSLogix\\Apps\\frxccd.exe;%ProgramFiles%\\FSLogix\\Apps\\frxccds.exe;%ProgramFiles%\\FSLogix\\Apps\\frxsvc.exe'
                } : {}
            }
        }
        */
        // Enable monitoring agent
        extensionMonitoringAgentConfig:{
            enabled: deployMonitoring
        }
        monitoringWorkspaceId: alaWorkspaceResourceId
        tags: tags
        nicdiagnosticMetricsToEnable: varNicDiagnosticMetricsToEnable
        diagnosticWorkspaceId: alaWorkspaceResourceId
        diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
    }
    dependsOn: []
}]

// Add session hosts to AVD Host pool.
module addAvdHostsToHostPool '../../vm-custom-extensions/add-avd-session-hosts.bicep' = [for i in range(1, sessionHostsCount): {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'HP-Join-${padLeft((i + avdSessionHostCountIndex), 3, '0')}-to-HP-${time}'
    params: {
        location: sessionHostLocation
        hostPoolToken: hostPoolToken
        name: '${sessionHostNamePrefix}-${padLeft((i + avdSessionHostCountIndex), 3, '0')}'
        hostPoolName: hostPoolName
        avdAgentPackageLocation: agentPackageLocation
    }
    dependsOn: [
        avdSessionHosts
    ]
}]

// Add the registry keys for Fslogix. Alternatively can be enforced via GPOs.
module configureFsLogixForAvdHosts '../../vm-custom-extensions/configure-fslogix-session-hosts.bicep' = [for i in range(1, sessionHostsCount): if (createAvdFslogixDeployment && (identityServiceProvider != 'AAD')) {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'Configure-FsLogix-for-${padLeft((i + avdSessionHostCountIndex), 3, '0')}-${time}'
    params: {
        location: sessionHostLocation
        name: '${sessionHostNamePrefix}-${padLeft((i + avdSessionHostCountIndex), 3, '0')}'
        file: fsLogixScript
        FsLogixScriptArguments: fsLogixScriptArguments
        baseScriptUri: fslogixScriptUri
    }
    dependsOn: [
        avdSessionHosts
    ]
}]
