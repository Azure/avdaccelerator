targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Virtual machine time zone.')
param computeTimeZone string

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@description('Resource Group Name for Azure Files.')
param serviceObjectsRgName string

@description('AVD subnet ID.')
param avdSubnetId string

@description('Enable accelerated networking on the session host VMs.')
param enableAcceleratedNetworking bool

@description('Create new virtual network.')
param createAvdVnet bool

@description('Location where to deploy compute services.')
param sessionHostLocation string

@description('This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@description('Session host VM size.')
param sessionHostsSize string

@description('OS disk type for session host.')
param sessionHostDiskType string

@description('Market Place OS image')
param marketPlaceGalleryWindowsManagementVm object

@description('Set to deploy image from Azure. Compute Gallery')
param useSharedImage bool

@description('Source custom image ID.')
param imageTemplateDefinitionId string

@description('Storage Managed Identity Resource ID.')
param storageManagedIdentityResourceId string

@description('Local administrator username.')
param vmLocalUserName string

@description('AD domain name.')
param identityDomainName string

@description('Keyvault name to get credentials from.')
param wrklKvName string

@description('AVD session host domain join credentials.')
param domainJoinUserName string

@description('OU path to join AVd VMs.')
param sessionHostOuPath string

@description('Application Security Group (ASG) for the session hosts.')
param applicationSecurityGroupResourceId string

@description('Tags to be applied to resources')
param tags object

@description('Name for management virtual machine. for tools and to join Azure Files to domain.')
param managementVmName string

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
    name: wrklKvName
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
}

// Provision temporary VM and add it to domain.
module managementVm '../../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/deploy.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
    name: 'Management-VM-${time}'
    params: {
        name: managementVmName
        location: sessionHostLocation
        timeZone: computeTimeZone
        systemAssignedIdentity: false
        userAssignedIdentities: {
            '${storageManagedIdentityResourceId}': {}
        }
        encryptionAtHost: encryptionAtHost
        availabilityZone: []
        osType: 'Windows'
        //licenseType: 'Windows_Client'
        vmSize: sessionHostsSize
        imageReference: useSharedImage ? json('{\'id\': \'${imageTemplateDefinitionId}\'}') : marketPlaceGalleryWindowsManagementVm
        //imageReference: marketPlaceGalleryWindowsManagementVm
        osDisk: {
            createOption: 'fromImage'
            deleteOption: 'Delete'
            diskSizeGB: 128
            managedDisk: {
                storageAccountType: sessionHostDiskType
            }
        }
        adminUsername: vmLocalUserName
        adminPassword: avdWrklKeyVaultget.getSecret('vmLocalUserPassword')
        nicConfigurations: [
            {
                nicSuffix: 'nic-001-'
                deleteOption: 'Delete'
                enableAcceleratedNetworking: enableAcceleratedNetworking
                ipConfigurations: createAvdVnet ? [
                    {
                        name: 'ipconfig01'
                        subnetResourceId: avdSubnetId
                        applicationSecurityGroups: [
                            {
                                id: applicationSecurityGroupResourceId
                            }
                        ] 
                    }
                ] : [
                    {
                        name: 'ipconfig01'
                        subnetResourceId: avdSubnetId
                    }
                ]
            }
        ]
        // Join domain
        allowExtensionOperations: true
        extensionDomainJoinPassword: avdWrklKeyVaultget.getSecret('domainJoinUserPassword')
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
        }
        tags: tags
    }
    dependsOn: [
    ]
}

// Introduce wait for management VM to be ready.
module managementVmWait '../../../../../carml/1.3.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
    name: 'Management-VM-Wait-${time}'
    params: {
        name: 'Management-VM-Wait-${time}'
        location: sessionHostLocation
        azPowerShellVersion: '8.3.0'
        cleanupPreference: 'Always'
        timeout: 'PT10M'
        scriptContent: '''
        Write-Host "Start"
        Get-Date
        Start-Sleep -Seconds 120
        Write-Host "Stop"
        Get-Date
        '''
    }
    dependsOn: [
        managementVm
    ]
} 

// =========== //
//   Outputs   //
// =========== //
