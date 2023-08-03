targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //

@sys.description('AVD disk encryption set resource ID to enable server side encyption.')
param diskEncryptionSetResourceId string

@sys.description('AVD subnet ID.')
param subnetId string

@sys.description('Location where to deploy compute services.')
param sessionHostLocation string

@sys.description('Virtual machine time zone.')
param timeZone string

@sys.description('AVD Session Host prefix.')
param sessionHostNamePrefix string

@sys.description('Availablity Set name.')
param avsetNamePrefix string

@sys.description('Availablity Set max members.')
param maxAvsetMembersCount int

@sys.description('Resource Group name for the session hosts')
param computeObjectsRgName string

@sys.description('Resource Group name for the session hosts')
param serviceObjectsRgName string

@sys.description('General session host batch identifier')
param sessionHostBatchId string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('Quantity of session hosts to deploy')
param sessionHostsCount int

@sys.description('The session host number to begin with for the deployment.')
param sessionHostCountIndex int

@sys.description('Creates an availability zone and adds the VMs to it. Cannot be used in combination with availability set nor scale set.')
param useAvailabilityZones bool

@sys.description('This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@sys.description('Session host VM size.')
param sessionHostsSize string

@sys.description('Specifies the securityType of the virtual machine. It is set as TrustedLaunch to enable UefiSettings.')
param securityType string

@sys.description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool

@sys.description('Specifies whether the virtual TPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  securityType should be set to TrustedLaunch to enable UefiSettings.')
param vTpmEnabled bool

@sys.description('Enable accelerated networking on the session host VMs.')
param enableAcceleratedNetworking bool

@sys.description('OS disk type for session host.')
param sessionHostDiskType string

@sys.description('Market Place OS image.')
param marketPlaceGalleryWindows object

@sys.description('Set to deploy image from Azure Compute Gallery.')
param useSharedImage bool

@sys.description('Source custom image ID.')
param imageTemplateDefinitionId string

@sys.description('Fslogix Managed Identity Resource ID.')
param storageManagedIdentityResourceId string

@sys.description('Clean up Managed Identity Resource ID.')
param cleanUpManagedIdentityClientId string

@sys.description('Local administrator username.')
param vmLocalUserName string

@sys.description('AD domain name.')
param identityDomainName string

@sys.description('AVD session host domain join credentials.')
param domainJoinUserName string

@sys.description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Required, Eronll session hosts on Intune.')
param createIntuneEnrollment bool

@sys.description('Name of keyvault that contains credentials.')
param wrklKvName string

@sys.description('OU path to join AVd VMs')
param sessionHostOuPath string

@sys.description('Application Security Group for the session hosts.')
param asgResourceId string

@sys.description('AVD host pool token.')
param hostPoolToken string

@sys.description('AVD Host Pool name.')
param hostPoolName string

@sys.description('Location for the AVD agent installation package.')
param avdAgentPackageLocation string

@sys.description('Deploy Fslogix setup.')
param createAvdFslogixDeployment bool

@sys.description('FSlogix configuration script file name.')
param fsLogixScriptFile string

@sys.description('Configuration arguments for FSlogix.')
param fsLogixScriptArguments string

@sys.description('Path for the FSlogix share.')
param fslogixSharePath string

@sys.description('URI for FSlogix configuration script.')
param fslogixScriptUri string

@sys.description('URI for compute RG deployment cleanup configuration script.')
param compRgDeploCleanScriptUri string

@sys.description('URI for compute RG deployment cleanup configuration script.')
param compRgDeploCleanScript string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Diagnostic logs retention.')
param diagnosticLogsRetentionInDays int

@sys.description('Deploy AVD monitoring resources and setings. (Default: true)')
param deployMonitoring bool

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varAllAvailabilityZones = pickZones('Microsoft.Compute', 'virtualMachines', sessionHostLocation, 3)
var varNicDiagnosticMetricsToEnable = [
    'AllMetrics'
  ]
var varManagedDisk = empty(diskEncryptionSetResourceId) ? {
    storageAccountType: sessionHostDiskType
} : {
    diskEncryptionSet: {
        id: diskEncryptionSetResourceId
    }
    storageAccountType: sessionHostDiskType
}
// =========== //
// Deployments //
// =========== //
// call on the keyvault.
resource wrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = if (identityServiceProvider != 'AAD') {
    name: wrklKvName
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
}

// Session hosts.
module sessionHosts '../../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/deploy.bicep' = [for i in range(1, sessionHostsCount): {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-${sessionHostBatchId}-${i-1}-${time}'
    params: {
        name: '${sessionHostNamePrefix}${padLeft((i + sessionHostCountIndex), 4, '0')}'
        location: sessionHostLocation
        timeZone: timeZone
        userAssignedIdentities: createAvdFslogixDeployment ? {
            '${storageManagedIdentityResourceId}': {}
        } : {}
        systemAssignedIdentity: (identityServiceProvider == 'AAD') ? true: false
        availabilityZone: useAvailabilityZones ? take(skip(varAllAvailabilityZones, i % length(varAllAvailabilityZones)), 1) : []
        encryptionAtHost: encryptionAtHost
        availabilitySetResourceId: useAvailabilityZones ? '' : '/subscriptions/${subscriptionId}/resourceGroups/${computeObjectsRgName}/providers/Microsoft.Compute/availabilitySets/${avsetNamePrefix}-${padLeft(((1 + (i + sessionHostCountIndex) / maxAvsetMembersCount)), 3, '0')}'
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
            managedDisk: varManagedDisk
        }
        adminUsername: vmLocalUserName
        adminPassword: wrklKeyVaultget.getSecret('vmLocalUserPassword')
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
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Wait-${sessionHostBatchId}-${time}'
    params: {
        name: 'SH-Wait-${sessionHostBatchId}-${time}'
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
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Antimal-${sessionHostBatchId}-${i-1}-${time}'
    params: {
        location: sessionHostLocation
        virtualMachineName: '${sessionHostNamePrefix}${padLeft((i + sessionHostCountIndex), 4, '0')}'
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
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Antimal-Wait-${sessionHostBatchId}-${time}'
    params: {
        name: 'SH-Antimal-Wait-${sessionHostBatchId}-${time}'
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
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Mon-${sessionHostBatchId}-${i-1}-${time}'
    params: {
        location: sessionHostLocation
        virtualMachineName: '${sessionHostNamePrefix}${padLeft((i + sessionHostCountIndex), 4, '0')}'
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
module sessionHostsMonitoringWait '../../../../../carml/1.3.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = if (deployMonitoring) {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Mon-Wait-${sessionHostBatchId}-${time}' 
    params: {
        name: 'SH-Mon-Wait-${sessionHostBatchId}-${time}'
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
module configureFsLogixAvdHosts './configureFslogixOnSessionHosts.bicep' = [for i in range(1, sessionHostsCount): if (createAvdFslogixDeployment) {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'Fsl-Conf-${sessionHostBatchId}-${i-1}-${time}'
    params: {
        location: sessionHostLocation
        name: '${sessionHostNamePrefix}${padLeft((i + sessionHostCountIndex), 4, '0')}'
        file: fsLogixScriptFile
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
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'HP-Join-${sessionHostBatchId}-${i}-${time}'
    params: {
        location: sessionHostLocation
        hostPoolToken: hostPoolToken
        name: '${sessionHostNamePrefix}${padLeft((i + sessionHostCountIndex), 4, '0')}'
        hostPoolName: hostPoolName
        avdAgentPackageLocation: avdAgentPackageLocation
    }
    dependsOn: [
        sessionHosts
        sessionHostsMonitoringWait
        configureFsLogixAvdHosts
    ]
}]

// Clean up depployment on compute objects RG
module computeRgDeploymentCleanUp './cleanUpRgDeployments.bicep' = {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'Comp-Deplo-Clean-${sessionHostBatchId}-1-${time}'
    params: {
        location: sessionHostLocation
        name: '${sessionHostNamePrefix}${padLeft((1 + sessionHostCountIndex), 4, '0')}'
        file: compRgDeploCleanScript
        cleanUpScriptArguments: '-subscriptionId ${subscriptionId} -resourceGroupName ${computeObjectsRgName} -clientId ${cleanUpManagedIdentityClientId}'
        baseScriptUri: compRgDeploCleanScriptUri
    }
    dependsOn: [
        sessionHosts
        sessionHostsMonitoringWait
        addAvdHostsToHostPool
        configureFsLogixAvdHosts
    ]
}
