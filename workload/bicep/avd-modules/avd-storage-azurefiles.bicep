targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Required. Virtual machine time zone.')
param timeZone string

@description('Resource Group Name for Azure Files.')
param storageObjectsRgName string

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@description('Resource Group Name for Azure Files.')
param serviceObjectsRgName string

@description('AVD subnet ID.')
param subnetId string

@description('Optional. Create new virtual network.')
param createAvdVnet bool

@description('Required. Location where to deploy compute services.')
param sessionHostLocation string

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
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

@description('File share SMB multichannel.')
param fileShareMultichannel bool

@description('Subnet resource ID for the Azure Files private endpoint.')
param subnetResourceId string

@description('Local administrator username.')
param vmLocalUserName string

@description('Required. AD domain name.')
param identityDomainName string

@description('Required. Keyvault name to get credentials from.')
param wrklKvName string

@description('Required. AVD session host domain join credentials.')
param domainJoinUserName string

@description('Optional. OU path to join AVd VMs.')
param sessionHostOuPath string

@description('Application Security Group (ASG) for the session hosts.')
param applicationSecurityGroupResourceId string

@description('*Azure Files storage account SKU.')
param storageSku string

@description('*Azure File share quota')
param fileShareQuotaSize int

@description('Use Azure private DNS zones for private endpoints.')
param vnetPrivateDnsZone bool

@description('Use Azure private DNS zones for private endpoints.')
param vnetPrivateDnsZoneFilesId string

@description('Script name for adding storage account to Active Directory.')
param storageToDomainScript string

@description('URI for the script for adding the storage account to Active Directory.')
param storageToDomainScriptUri string

@description('Required. Tags to be applied to resources')
param tags object

@description('Name for management virtual machine. for tools and to join Azure Files to domain.')
param managementVmName string

@description('Optional. Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@description('Optional. Diagnostic logs retention.')
param diagnosticLogsRetentionInDays int

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@description('Sets purpose of the storage account.')
param storagePurpose string

@description('Required. AVD resources custom naming. (Default: false)')
param useCustomNaming bool

@description('Sets purpose of the storage account.')
param storageAccountPrefixCustomName string

@description('Deployment Prefix set in main template, in lowercase.')
param deploymentPrefixLowercase string

@description('Unique name truncated into 6 characters')
param namingUniqueStringSixChar string


//parameters for domain join
@description('Sets location of DSC Agent.')
param dscAgentPackageLocation string

@secure()
@description('Domain join user password.')
param domainJoinUserPassword string

@description('Custom OU path for storage.')
param avdStorageCustomOuPath string

@description('OU Storage Path')
param avdOuStgPath string

@description('Optional. If OU for Azure Storage needs to be created - set to true and ensure the domain join credentials have priviledge to create OU and create computer objects or join to domain. (Default: "")')
param avdCreateOuForStorageString string

@description('Managed Identity Client ID')
param managedIdentityClientId string

@maxLength(64)
@description('Optional. Storage account profile container file share prefix custom name. (Default: storagePurpose-pc-app1-001)')
param fileShareCustomName string


// =========== //
// Variable declaration //
// =========== //

var varAvdFileShareLogsDiagnostic = [
    'StorageRead'
    'StorageWrite'
    'StorageDelete'
]
var varAvdFileShareMetricsDiagnostic = [
    'Transaction'
]
var varFileShareName = useCustomNaming ? fileShareCustomName : '${varStoragePurposeLower}-pc-${deploymentPrefixLowercase}-001'
var varWrklStoragePrivateEndpointName = 'pe-${varStorageName}-file'
var varStoragePurposeLower = toLower(storagePurpose)
var varStoragePurposeLowerPrefix = substring(varStoragePurposeLower, 0,2)
var varStorageName = useCustomNaming ? '${storageAccountPrefixCustomName}${varStoragePurposeLower}${deploymentPrefixLowercase}${namingUniqueStringSixChar}' : 'stavd${varStoragePurposeLower}${deploymentPrefixLowercase}${namingUniqueStringSixChar}'

var varStorageToDomainScriptArgs = '-DscPath ${dscAgentPackageLocation} -StorageAccountName ${varStorageName} -StorageAccountRG ${storageObjectsRgName} -DomainName ${identityDomainName} -IdentityServiceProvider ${identityServiceProvider} -AzureCloudEnvironment AzureCloud -SubscriptionId ${workloadSubsId} -DomainAdminUserName ${domainJoinUserName} -DomainAdminUserPassword ${domainJoinUserPassword} -CustomOuPath ${avdStorageCustomOuPath} -OUName ${avdOuStgPath} -CreateNewOU ${avdCreateOuForStorageString} -ShareName ${varFileShareName} -ClientId ${managedIdentityClientId} -Verbose'

// =========== //
// Deployments //
// =========== //

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
    name: wrklKvName
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
}

// Provision the storage account and Azure Files.
module storageAndFile '../../../carml/1.2.0/Microsoft.Storage/storageAccounts/deploy.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${storageObjectsRgName}')
    name: 'AVD-${storagePurpose}-${time}'
    params: {
        name: varStorageName
        location: sessionHostLocation
        storageAccountSku: storageSku
        allowBlobPublicAccess: false
        storageAccountKind: ((storageSku =~ 'Premium_LRS') || (storageSku =~ 'Premium_ZRS')) ? 'FileStorage' : 'StorageV2'
        azureFilesIdentityBasedAuthentication: (identityServiceProvider == 'AADDS') ? {
            directoryServiceOptions: 'AADDS'
        }: {
            directoryServiceOptions: 'None'
        }
        storageAccountAccessTier: 'Hot'
        networkAcls: {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        }
        fileServices: {
            shares: [
                {
                    name: varFileShareName
                    sharedQuota: fileShareQuotaSize * 100 //Portal UI steps scale
                }
            ]
            protocolSettings: fileShareMultichannel ? {
                smb: {
                    multichannel: {
                        enabled: fileShareMultichannel
                    }
                }
            } : {}
            diagnosticWorkspaceId: alaWorkspaceResourceId
            diagnosticLogCategoriesToEnable: varAvdFileShareLogsDiagnostic
            diagnosticMetricsToEnable: varAvdFileShareMetricsDiagnostic
        }
        privateEndpoints: vnetPrivateDnsZone ? [
            {
                name: varWrklStoragePrivateEndpointName
                subnetResourceId: subnetResourceId
                service: 'file'
                privateDnsZoneResourceIds: [
                    vnetPrivateDnsZoneFilesId
                ]
            }
        ] : [
            {
                name: varWrklStoragePrivateEndpointName
                subnetResourceId: subnetResourceId
                service: 'file'
            }
        ]
        tags: tags
        diagnosticWorkspaceId: alaWorkspaceResourceId
        diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
    }
}

// Provision temporary VM and add it to domain.
module managementVM '../../../carml/1.2.0/Microsoft.Compute/virtualMachines/deploy.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
    name: 'Deploy-Mgmt-VM-${storagePurpose}-${time}'
    params: {
        name: managementVmName
        location: sessionHostLocation
        timeZone: timeZone
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
        adminPassword: avdWrklKeyVaultget.getSecret('avdVmLocalUserPassword')
        nicConfigurations: [
            {
                nicSuffix: 'nic-01-'
                deleteOption: 'Delete'
                enableAcceleratedNetworking: false
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
        // Join domain
        allowExtensionOperations: true
        extensionDomainJoinPassword: avdWrklKeyVaultget.getSecret('avdDomainJoinUserPassword')
        extensionDomainJoinConfig: {
            enabled: true
            settings: {
                name: identityDomainName
                ouPath: !empty(sessionHostOuPath) ? sessionHostOuPath : null
                user: domainJoinUserName
                restart: 'true'
                options: '3'
            }
        }
        tags: tags
    }
    dependsOn: [
        storageAndFile
    ]
}

// Introduce delay for management VM to be ready.
module managementVmDelay '../../../carml/1.0.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
    name: 'AVD-Management-VM-${storagePurpose}-Delay-${time}'
    params: {
        name: '${storagePurpose}-userManagedIdentityDelay-${time}'
        location: sessionHostLocation
        azPowerShellVersion: '6.2'
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
        managementVM
    ]
} 

// Custom Extension call in on the DSC script to join Azure storage account to domain. 
module addShareToDomainScript '../../vm-custom-extensions/add-azure-files-to-domain-script.bicep' = { //if(identityServiceProvider == 'ADDS')  {
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
    name: 'Add-${storagePurpose}-Storage-Setup-${time}'
    params: {
        location: sessionHostLocation
        name: managementVM.outputs.name
        file: storageToDomainScript
        ScriptArguments: varStorageToDomainScriptArgs
        baseScriptUri: storageToDomainScriptUri
    }
    dependsOn: [
        storageAndFile
        managementVmDelay
    ]
}

// Run deployment script to remove the VM --> 0.2 release. 
// needs user managed identity --> Virtual machine contributor role assignment. Deployment script to assume the identity to delete VM. Include NIC and disks (force)
 
// =========== //
//   Outputs   //
// =========== //

output storageAccountName string = storageAndFile.outputs.name
output fileShareName string = varFileShareName
