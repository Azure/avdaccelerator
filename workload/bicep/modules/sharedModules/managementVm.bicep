targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('AVD disk encryption set resource ID to enable server side encyption.')
param diskEncryptionSetResourceId string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subId string

@sys.description('Virtual machine time zone.')
param computeTimeZone string

@sys.description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Resource Group Name for Azure Files.')
param serviceObjectsRgName string

@sys.description('AVD subnet ID.')
param subnetResourceId string

@sys.description('Enable accelerated networking on the session host VMs.')
param enableAcceleratedNetworking bool

@sys.description('Specifies the securityType of the virtual machine. Must be TrustedLaunch or ConfidentialVM enable UefiSettings.')
param securityType string

@sys.description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool

@sys.description('Specifies whether virtual TPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  securityType should be set to TrustedLaunch to enable UefiSettings.')
param vTpmEnabled bool

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@sys.description('Session host VM size.')
param vmSize string

@sys.description('OS disk type for session host.')
param osDiskType string

@sys.description('Market Place OS image')
param osImage object

@sys.description('Storage Managed Identity Resource ID.')
param storageManagedIdentityResourceId string

@sys.description('Local administrator username.')
param vmLocalUserName string

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('Keyvault resource ID to get credentials from.')
param keyVaultResourceId string

@sys.description('AVD session host domain join credentials.')
param domainJoinUserName string

@sys.description('OU path to join AVd VMs.')
param ouPath string

@sys.description('Application Security Group (ASG) for the session hosts.')
param applicationSecurityGroupResourceId string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Name for management virtual machine. for tools and to join Azure Files to domain.')
param vmName string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varKeyVaultSubId = split(keyVaultResourceId, '/')[2]
var varKeyVaultRgName = split(keyVaultResourceId, '/')[4]
var varKeyVaultName = split(keyVaultResourceId, '/')[8]
var varManagedDisk = empty(diskEncryptionSetResourceId) ? {
    storageAccountType: osDiskType
} : {
    diskEncryptionSet: {
        id: diskEncryptionSetResourceId
    }
    storageAccountType: osDiskType
}

// =========== //
// Deployments //
// =========== //

// Call on the KV.
resource keyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
    name: varKeyVaultName
    scope: resourceGroup('${varKeyVaultSubId}', '${varKeyVaultRgName}')
}


// Provision temporary VM and add it to domain.
module managementVm '../../../../avm/1.0.0/res/compute/virtual-machine/main.bicep' = {
    scope: resourceGroup('${subId}', '${serviceObjectsRgName}')
    name: 'MGMT-VM-${time}'
    params: {
        name: vmName
        location: location
        timeZone: computeTimeZone
        managedIdentities: {
            systemAssigned: false
            userAssignedResourceIds: [
                storageManagedIdentityResourceId
            ] 
        }
        encryptionAtHost: encryptionAtHost
        zone: 0
        osType: 'Windows'
        vmSize: vmSize
        securityType: securityType
        secureBootEnabled: secureBootEnabled
        vTpmEnabled: vTpmEnabled
        imageReference: osImage
        osDisk: {
            createOption: 'FromImage'
            deleteOption: 'Delete'
            caching: 'ReadWrite'
            managedDisk: varManagedDisk
        }
        adminUsername: vmLocalUserName
        adminPassword: keyVaultget.getSecret('vmLocalUserPassword')
        nicConfigurations: [
            {
                name: 'nic-01-${vmName}'
                deleteOption: 'Delete'
                enableAcceleratedNetworking: enableAcceleratedNetworking
                ipConfigurations: !empty(applicationSecurityGroupResourceId)  ? [
                    {
                        name: 'ipconfig01'
                        subnetResourceId: subnetResourceId
                        applicationSecurityGroups: [
                            {
                                id: applicationSecurityGroupResourceId
                            }
                        ] 
                    }
                ] : [
                    {
                        name: 'ipconfig01'
                        subnetResourceId: subnetResourceId
                    }
                ]
            }
        ]
        // Join domain
        allowExtensionOperations: true
        extensionDomainJoinPassword: keyVaultget.getSecret('domainJoinUserPassword')
        extensionDomainJoinConfig: {
            enabled: contains(identityServiceProvider, 'EntraID') ? false: true
            settings: {
                name: identityDomainName
                ouPath: !empty(ouPath) ? ouPath : null
                user: domainJoinUserName
                restart: 'true'
                options: '3'
            }
        }
        // Entra ID Join.
        extensionAadJoinConfig: {
            enabled: contains(identityServiceProvider, 'EntraID') ? true: false
        }
        tags: tags
    }
    dependsOn: [
    ]
}

// =========== //
//   Outputs   //
// =========== //
