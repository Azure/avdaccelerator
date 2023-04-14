targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@description('AVD subnet ID.')
param subnetId string

@description('Location where to deploy compute services.')
param sessionHostLocation string

@description('Virtual machine time zone.')
param timeZone string

@description('AVD Session Host prefix.')
param sessionHostNamePrefix string

@description('Availablity Set name.')
param availabilitySetNamePrefix string

@description('Availablity Set max members.')
param maxAvailabilitySetMembersCount int

@description('Resource Group name for the session hosts')
param computeObjectsRgName string

@description('Resource Group name for the session hosts')
param serviceObjectsRgName string

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Quantity of session hosts to deploy')
param sessionHostsCount int

@description('Create new virtual network.')
param createAvdVnet bool

@description('The session host number to begin with for the deployment.')
param sessionHostCountIndex int

@description('Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set.')
param useAvailabilityZones bool

@description('This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@description('Session host VM size.')
param sessionHostsSize string

@description('Specifies the securityType of the virtual machine. It is set as TrustedLaunch to enable UefiSettings.')
param securityType string

@description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool

@description('Specifies whether the virtual TPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  securityType should be set to TrustedLaunch to enable UefiSettings.')
param vTpmEnabled bool

@description('Enable accelerated networking on the session host VMs.')
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

@description('AD domain name.')
param identityDomainName string

@description('AVD session host domain join credentials.')
param domainJoinUserName string

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@description('Required, Eronll session hosts on Intune.')
param createIntuneEnrollment bool

@description('Name of keyvault that contains credentials.')
param wrklKvName string

@description('OU path to join AVd VMs')
param sessionHostOuPath string

@description('Application Security Group for the session hosts.')
param applicationSecurityGroupResourceId string

@description('AVD host pool token.')
param hostPoolToken string

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
var varAllAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', sessionHostLocation, 3)
var varNicDiagnosticMetricsToEnable = [
    'AllMetrics'
  ]
// =========== //
// Deployments //
// =========== //
// call on the keyvault.
resource wrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (identityServiceProvider != 'AAD') {
    name: wrklKvName
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
}

// Session hosts.
module sessionHosts '../../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/deploy.bicep' = [for i in range(1, sessionHostsCount): {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'Session-Host-${padLeft((i + sessionHostCountIndex), 3, '0')}-${time}'
    params: {
        name: '${sessionHostNamePrefix}-${padLeft((i + sessionHostCountIndex), 3, '0')}'
        location: sessionHostLocation
        timeZone: timeZone
        userAssignedIdentities: createAvdFslogixDeployment ? {
            '${storageManagedIdentityResourceId}': {}
        } : {}
        systemAssignedIdentity: (identityServiceProvider == 'AAD') ? true: false
        availabilityZone: useAvailabilityZones ? take(skip(varAllAvailabilityZones, i % length(varAllAvailabilityZones)), 1) : []
        encryptionAtHost: encryptionAtHost
        availabilitySetResourceId: useAvailabilityZones ? '' : '/subscriptions/${workloadSubsId}/resourceGroups/${computeObjectsRgName}/providers/Microsoft.Compute/availabilitySets/${availabilitySetNamePrefix}-${padLeft(((1 + (i + sessionHostCountIndex) / maxAvailabilitySetMembersCount)), 3, '0')}'
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
        adminPassword: wrklKeyVaultget.getSecret('vmLocalUserPassword')
        nicConfigurations: [
            {
                nicSuffix: 'nic-01-'
                deleteOption: 'Delete'
                enableAcceleratedNetworking: enableAcceleratedNetworking
                ipConfigurations: createAvdVnet ? [
                    {
                        name: 'ipconfig01'
                        subnetResourceId: subnetId
                        applicationSecurityGroups: [
                            {
                                id: applicationSecurityGroupResourceId
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
        extensionDomainJoinPassword: wrklKeyVaultget.getSecret('domainJoinUserPassword')
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
        // Enable monitoring agent
        //extensionMonitoringAgentConfig: deployMonitoring ? {
        //    enabled: deployMonitoring
        //}: {}
        //monitoringWorkspaceId: deployMonitoring ? alaWorkspaceResourceId : ''
        nicdiagnosticMetricsToEnable: deployMonitoring ? varNicDiagnosticMetricsToEnable : []
        diagnosticWorkspaceId: deployMonitoring ? alaWorkspaceResourceId : ''
        diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
        tags: tags
    }
    dependsOn: [
        wrklKeyVaultget
    ]
}]

// Introduce wait for session hosts to be ready.
module sessionHostsWait '../../../../../carml/1.3.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'Session-Hosts-Wait-${time}'
    params: {
        name: 'Session-Hosts-Wait-${time}'
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
        sessionHosts
    ]
} 

// Add antimalware extension to session host.
module sessionHostsAntimalwareExtension '../../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/extensions/deploy.bicep' = [for i in range(1, sessionHostsCount): {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'SH-Antimalware-${padLeft((i + sessionHostCountIndex), 3, '0')}-${time}'
    params: {
        location: sessionHostLocation
        virtualMachineName: '${sessionHostNamePrefix}-${padLeft((i + sessionHostCountIndex), 3, '0')}'
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
        sessionHostsWait
    ]
}]

// Introduce wait for antimalware extension to complete to be ready.
module antimalwareExtensionWait '../../../../../carml/1.3.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'Antimalware-Extension-Wait-${time}'
    params: {
        name: 'Antimalware-Extension-Wait-${time}'
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
        sessionHostsAntimalwareExtension
    ]
} 

// Call to the ALA workspace.
resource alaWorkspaceGet 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = if (!empty(alaWorkspaceResourceId) && deployMonitoring) {
    scope: az.resourceGroup(split(alaWorkspaceResourceId, '/')[2], split(alaWorkspaceResourceId, '/')[4])
    name: last(split(alaWorkspaceResourceId, '/'))!
}

// Add monitoring extension to session host.
module sessionHostsMonitoring '../../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/extensions/deploy.bicep' = [for i in range(1, sessionHostsCount): if (deployMonitoring) {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'SH-Monitoring-${padLeft((i + sessionHostCountIndex), 3, '0')}-${time}'
    params: {
        location: sessionHostLocation
        virtualMachineName: '${sessionHostNamePrefix}-${padLeft((i + sessionHostCountIndex), 3, '0')}'
        name: 'MicrosoftMonitoringAgent'
        publisher: 'Microsoft.EnterpriseCloud.Monitoring'
        type: 'MicrosoftMonitoringAgent'
        typeHandlerVersion: '1.0'
        autoUpgradeMinorVersion: true
        enableAutomaticUpgrade: false
        settings: {
          workspaceId: !empty(alaWorkspaceResourceId) ? reference(alaWorkspaceGet.id, alaWorkspaceGet.apiVersion).customerId : ''
        }
        protectedSettings: {
          workspaceKey: !empty(alaWorkspaceResourceId) ? alaWorkspaceGet.listKeys().primarySharedKey: ''
        }
        enableDefaultTelemetry: false
    }
    dependsOn: [
        antimalwareExtensionWait
        alaWorkspaceGet
    ]
}]

// Introduce wait for antimalware extension to complete to be ready.
module sessionHostsMonitoringWait '../../../../../carml/1.3.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'SH-Moniroting-Wait-${time}'
    params: {
        name: 'SH-Moniroting-Wait-${time}'
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
        sessionHostsMonitoring
    ]
} 

// Add the registry keys for Fslogix. Alternatively can be enforced via GPOs.
module configureFsLogixForAvdHosts './configureFslogixOnSessionHosts.bicep' = [for i in range(1, sessionHostsCount): if (createAvdFslogixDeployment && (identityServiceProvider != 'AAD')) {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'Configure-FsLogix-for-${padLeft((i + sessionHostCountIndex), 3, '0')}-${time}'
    params: {
        location: sessionHostLocation
        name: '${sessionHostNamePrefix}-${padLeft((i + sessionHostCountIndex), 3, '0')}'
        file: fsLogixScript
        fsLogixScriptArguments: fsLogixScriptArguments
        baseScriptUri: fslogixScriptUri
    }
    dependsOn: [
        sessionHosts
        sessionHostsMonitoringWait
    ]
}]

// Add session hosts to AVD Host pool.
module addAvdHostsToHostPool './registerSessionHostsOnHopstPool.bicep' = [for i in range(1, sessionHostsCount): {
    scope: resourceGroup('${workloadSubsId}', '${computeObjectsRgName}')
    name: 'HP-Join-${padLeft((i + sessionHostCountIndex), 3, '0')}-to-HP-${time}'
    params: {
        location: sessionHostLocation
        hostPoolToken: hostPoolToken
        name: '${sessionHostNamePrefix}-${padLeft((i + sessionHostCountIndex), 3, '0')}'
        hostPoolName: hostPoolName
        avdAgentPackageLocation: avdAgentPackageLocation
    }
    dependsOn: [
        sessionHosts
        sessionHostsMonitoringWait
        configureFsLogixForAvdHosts
    ]
}]

