targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('AVD disk encryption set resource ID to enable server side encyption.')
param diskEncryptionSetResourceId string

@sys.description('AVD subnet ID.')
param subnetId string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('Virtual machine time zone.')
param timeZone string

@sys.description('General session host batch identifier')
param batchId int

@sys.description('AVD Session Host prefix.')
param namePrefix string

@sys.description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@sys.description('Name of AVD service objects RG.')
param serviceObjectsRgName string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('Quantity of session hosts to deploy.')
param count int

@sys.description('Max VMs per availability set.')
param maxAvsetMembersCount int

@sys.description('The session host number to begin with for the deployment.')
param countIndex int

@sys.description('Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set.')
param useAvailabilityZones bool

@sys.description('Availablity Set name.')
param avsetNamePrefix string

@sys.description('The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Eronll session hosts on Intune.')
param createIntuneEnrollment bool

@sys.description('This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@sys.description('Session host VM size.')
param vmSize string

@sys.description('Enables accelerated Networking on the session hosts.')
param enableAcceleratedNetworking bool

@sys.description('Specifies the securityType of the virtual machine. Must be TrustedLaunch or ConfidentialVM enable UefiSettings.')
param securityType string

@sys.description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool

@sys.description('Specifies whether virtual TPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  securityType should be set to TrustedLaunch to enable UefiSettings.')
param vTpmEnabled bool

@sys.description('OS disk type for session host.')
param diskType string

@sys.description('Market Place OS image.')
param marketPlaceGalleryWindows object

@sys.description('Set to deploy image from Azure Compute Gallery.')
param useSharedImage bool

@sys.description('Source custom image ID.')
param avdImageTemplateDefinitionId string

@sys.description('Storage Managed Identity Resource ID.')
param storageManagedIdentityResourceId string

@sys.description('Local administrator username.')
param vmLocalUserName string

@sys.description('Name of keyvault that contains credentials.')
param wrklKvName string

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('AVD session host domain join credentials.')
param domainJoinUserName string

@sys.description('OU path to join AVd VMs.')
param sessionHostOuPath string

@sys.description('Application Security Group (ASG) for the session hosts.')
param asgResourceId string

@sys.description('AVD Host Pool name.')
param hostPoolName string

@sys.description('Deploy Fslogix setup.')
param createAvdFslogixDeployment bool

@sys.description('Path for the FSlogix share.')
param fslogixSharePath string

@sys.description('FSLogix storage account FDQN.')
param fslogixStorageFqdn string

@sys.description('URI for AVD session host configuration script URI.')
param sessionHostConfigurationScriptUri string

@sys.description('URI for AVD session host configuration script.')
param sessionHostConfigurationScript string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Deploy AVD monitoring resources and setings. (Default: true)')
param deployMonitoring bool

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varAllAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', location, 3)
var varNicDiagnosticMetricsToEnable = [
    'AllMetrics'
]
var varManagedDisk = empty(diskEncryptionSetResourceId) ? {
    storageAccountType: diskType
} : {
    diskEncryptionSet: {
        id: diskEncryptionSetResourceId
    }
    storageAccountType: diskType
}
// =========== //
// Deployments //
// =========== //
// Call on the hotspool
resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2019-12-10-preview' existing = {
    name: hostPoolName
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
}

// call on the keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (identityServiceProvider != 'AAD') {
    name: wrklKvName
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
}

// Session hosts
module sessionHosts '../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/deploy.bicep' = [for i in range(1, count): {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-${batchId}-${i - 1}-${time}'
    params: {
        name: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
        location: location
        timeZone: timeZone
        userAssignedIdentities: createAvdFslogixDeployment ? {
            '${storageManagedIdentityResourceId}': {}
        } : {}
        systemAssignedIdentity: (identityServiceProvider == 'AAD') ? true : false
        availabilityZone: useAvailabilityZones ? take(skip(varAllAvailabilityZones, i % length(varAllAvailabilityZones)), 1) : []
        encryptionAtHost: encryptionAtHost
        availabilitySetResourceId: useAvailabilityZones ? '' : '/subscriptions/${subscriptionId}/resourceGroups/${computeObjectsRgName}/providers/Microsoft.Compute/availabilitySets/${avsetNamePrefix}-${padLeft(((1 + (i + countIndex) / maxAvsetMembersCount)), 3, '0')}'
        osType: 'Windows'
        licenseType: 'Windows_Client'
        vmSize: vmSize
        securityType: securityType
        secureBootEnabled: secureBootEnabled
        vTpmEnabled: vTpmEnabled
        imageReference: useSharedImage ? json('{\'id\': \'${avdImageTemplateDefinitionId}\'}') : marketPlaceGalleryWindows
        osDisk: {
            createOption: 'fromImage'
            deleteOption: 'Delete'
            diskSizeGB: 128
            managedDisk: varManagedDisk
        }
        adminUsername: vmLocalUserName
        adminPassword: keyVault.getSecret('vmLocalUserPassword')
        nicConfigurations: [
            {
                nicSuffix: 'nic-01-'
                deleteOption: 'Delete'
                enableAcceleratedNetworking: enableAcceleratedNetworking
                ipConfigurations: !empty(asgResourceId) ? [
                    {
                        name: 'ipconfig01'
                        subnetResourceId: subnetId
                        applicationSecurityGroups: [
                            {
                                id: asgResourceId
                            }
                        ]
                    }
                ] : [
                    {
                        name: 'ipconfig01'
                        subnetResourceId: subnetId
                    }
                ]
            }
        ]
        // ADDS or AADDS domain join.
        extensionDomainJoinPassword: keyVault.getSecret('domainJoinUserPassword')
        extensionDomainJoinConfig: {
            enabled: (identityServiceProvider == 'AAD') ? false : true
            settings: {
                name: identityDomainName
                ouPath: !empty(sessionHostOuPath) ? sessionHostOuPath : null
                user: domainJoinUserName
                restart: 'true'
                options: '3'
            }
        }
        // Microsoft Entra ID Join.
        extensionAadJoinConfig: {
            enabled: (identityServiceProvider == 'AAD') ? true : false
            settings: createIntuneEnrollment ? {
                mdmId: '0000000a-0000-0000-c000-000000000000'
            } : {}
        }
        nicdiagnosticMetricsToEnable: deployMonitoring ? varNicDiagnosticMetricsToEnable : []
        diagnosticWorkspaceId: deployMonitoring ? alaWorkspaceResourceId : ''
        tags: tags
    }
    dependsOn: [
        keyVault
    ]
}]

// Add antimalware extension to session host.
module sessionHostsAntimalwareExtension '../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/extensions/deploy.bicep' = [for i in range(1, count): {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Antimal-${batchId}-${i - 1}-${time}'
    params: {
        location: location
        virtualMachineName: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
        name: 'MicrosoftAntiMalware'
        publisher: 'Microsoft.Azure.Security'
        type: 'IaaSAntimalware'
        typeHandlerVersion: '1.3'
        autoUpgradeMinorVersion: true
        enableAutomaticUpgrade: false
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
        enableDefaultTelemetry: false
    }
    dependsOn: [
        sessionHosts
    ]
}]

// Call to the ALA workspace
resource alaWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(alaWorkspaceResourceId) && deployMonitoring) {
    scope: az.resourceGroup(split(alaWorkspaceResourceId, '/')[2], split(alaWorkspaceResourceId, '/')[4])
    name: last(split(alaWorkspaceResourceId, '/'))!
}

// Add monitoring extension to session host
module monitoring '../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/extensions/deploy.bicep' = [for i in range(1, count): if (deployMonitoring) {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Mon-${batchId}-${i - 1}-${time}'
    params: {
        location: location
        virtualMachineName: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
        name: 'MicrosoftMonitoringAgent'
        publisher: 'Microsoft.EnterpriseCloud.Monitoring'
        type: 'MicrosoftMonitoringAgent'
        typeHandlerVersion: '1.0'
        autoUpgradeMinorVersion: true
        enableAutomaticUpgrade: false
        settings: {
            workspaceId: !empty(alaWorkspaceResourceId) ? reference(alaWorkspace.id, alaWorkspace.apiVersion).customerId : ''
        }
        protectedSettings: {
            workspaceKey: !empty(alaWorkspaceResourceId) ? alaWorkspace.listKeys().primarySharedKey : ''
        }
        enableDefaultTelemetry: false
    }
    dependsOn: [
        sessionHostsAntimalwareExtension
        alaWorkspace
    ]
}]

// Apply AVD session host configurations
module sessionHostConfiguration '.bicep/configureSessionHost.bicep' = [for i in range(1, count): {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Config-${batchId}-${i}-${time}'
    params: {
        location: location
        name: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
        hostPoolToken: hostPool.properties.registrationInfo.token
        baseScriptUri: sessionHostConfigurationScriptUri
        scriptName: sessionHostConfigurationScript
        fslogix: createAvdFslogixDeployment
        identityDomainName: identityDomainName
        vmSize: vmSize
        fslogixFileShare: fslogixSharePath
        fslogixStorageFqdn: fslogixStorageFqdn
        identityServiceProvider: identityServiceProvider
    }
    dependsOn: [
        sessionHosts
        monitoring
    ]
}]
