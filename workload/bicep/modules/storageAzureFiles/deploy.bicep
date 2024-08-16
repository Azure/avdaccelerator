targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Virtual machine time zone.')
param computeTimeZone string

@description('Resource Group Name for Azure Files.')
param storageObjectsRgName string

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@description('Resource Group Name for Azure Files.')
param serviceObjectsRgName string

@description('AVD subnet ID.')
param avdSubnetId string

@description('Enable accelerated networking on the session host VMs.')
param enableAcceleratedNetworking bool

@description('Private endpoint subnet ID.')
param privateEndpointSubnetId string

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

@description('File share SMB multichannel.')
param fileShareMultichannel bool

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

@description('Azure Files storage account SKU.')
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

@description('Tags to be applied to resources')
param tags object

@description('Name for management virtual machine. for tools and to join Azure Files to domain.')
param managementVmName string

@description('Optional. AVD Accelerator will deploy with private endpoints by default.')
param deployPrivateEndpoint bool

@description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@description('Diagnostic logs retention.')
param diagnosticLogsRetentionInDays int

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@description('Sets purpose of the storage account.')
param storagePurpose string

@description('AVD resources custom naming.')
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

@description('Custom OU path for storage.')
param storageCustomOuPath string

@description('OU Storage Path')
param ouStgPath string

@description('If OU for Azure Storage needs to be created - set to true and ensure the domain join credentials have priviledge to create OU and create computer objects or join to domain.')
param createOuForStorageString string

@description('Managed Identity Client ID')
param managedIdentityClientId string

@maxLength(64)
@description('Storage account profile container file share prefix custom name.')
param fileShareCustomName string


// =========== //
// Variable declaration //
// =========== //
var varAzureCloudName = environment().name
var varStoragePurposeLower = toLower(storagePurpose)
var varAvdFileShareLogsDiagnostic = [
    'allLogs'
    //'StorageRead'
    //'StorageWrite'
    //'StorageDelete'
]
var varAvdFileShareMetricsDiagnostic = [
    'Transaction'
]
var varFileShareName = useCustomNaming ? fileShareCustomName : '${varStoragePurposeLower}-pc-${deploymentPrefixLowercase}-001'
var varWrklStoragePrivateEndpointName = 'pe-${varStorageName}-file'
//var varStoragePurposeLowerPrefix = substring(varStoragePurposeLower, 0,2)
var varStoragePurposeAcronym = (storagePurpose == 'fslogix') ? 'fsl': ((storagePurpose == 'msix') ? 'msx': '')
var varStorageName = useCustomNaming ? '${storageAccountPrefixCustomName}${varStoragePurposeAcronym}${deploymentPrefixLowercase}${namingUniqueStringSixChar}' : 'st${varStoragePurposeAcronym}${deploymentPrefixLowercase}${namingUniqueStringSixChar}'
var varStorageToDomainScriptArgs = '-DscPath ${dscAgentPackageLocation} -StorageAccountName ${varStorageName} -StorageAccountRG ${storageObjectsRgName} -StoragePurpose ${storagePurpose} -DomainName ${identityDomainName} -IdentityServiceProvider ${identityServiceProvider} -AzureCloudEnvironment ${varAzureCloudName} -SubscriptionId ${workloadSubsId} -DomainAdminUserName ${domainJoinUserName} -CustomOuPath ${storageCustomOuPath} -OUName ${ouStgPath} -CreateNewOU ${createOuForStorageString} -ShareName ${varFileShareName} -ClientId ${managedIdentityClientId}'

// =========== //
// Deployments //
// =========== //

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
    name: wrklKvName
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
}

// Provision the storage account and Azure Files.
module storageAndFile '../../../../carml/1.3.0/Microsoft.Storage/storageAccounts/deploy.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${storageObjectsRgName}')
    name: 'Storage-${storagePurpose}-${time}'
    params: {
        name: varStorageName
        location: sessionHostLocation
        skuName: storageSku
        allowBlobPublicAccess: false
        publicNetworkAccess: deployPrivateEndpoint ? 'Disabled' : 'Enabled'
        kind: ((storageSku =~ 'Premium_LRS') || (storageSku =~ 'Premium_ZRS')) ? 'FileStorage' : 'StorageV2'
        azureFilesIdentityBasedAuthentication: (identityServiceProvider == 'AADDS') ? {
            directoryServiceOptions: 'AADDS'
        }: {
            directoryServiceOptions: 'None'
        }
        accessTier: 'Hot'
        networkAcls: deployPrivateEndpoint ? {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        } : {}
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
        privateEndpoints: deployPrivateEndpoint ? (vnetPrivateDnsZone ? [
            {
                name: varWrklStoragePrivateEndpointName
                subnetResourceId: privateEndpointSubnetId
                customNetworkInterfaceName: 'nic-01-${varWrklStoragePrivateEndpointName}'
                service: 'file'
                privateDnsZoneGroup: {
                    privateDNSResourceIds: [
                        vnetPrivateDnsZoneFilesId
                    ]                    
                }
            }
        ] : [
            {
                name: varWrklStoragePrivateEndpointName
                subnetResourceId: privateEndpointSubnetId
                customNetworkInterfaceName: 'nic-01-${varWrklStoragePrivateEndpointName}'
                service: 'file'
            }
        ]) : []
        tags: tags
        diagnosticWorkspaceId: alaWorkspaceResourceId
        diagnosticLogsRetentionInDays: diagnosticLogsRetentionInDays
    }
}

// Call on the VM.
//resource managementVMget 'Microsoft.Compute/virtualMachines@2022-11-01' existing = {
//    name: managementVmName
//    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
//}

// Provision temporary VM and add it to domain.
module managementVm '../../../../carml/1.3.0/Microsoft.Compute/virtualMachines/deploy.bicep' = {
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

// Introduce wait for management VM to be ready.
module managementVmWait '../../../../carml/1.3.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = {
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

// Custom Extension call in on the DSC script to join Azure storage account to domain. 
module addShareToDomainScript './.bicep/azureFilesDomainJoin.bicep' = if(identityServiceProvider == 'ADDS' || identityServiceProvider == 'AADDS')  {
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
    name: 'Add-${storagePurpose}-Storage-Setup-${time}'
    params: {
        location: sessionHostLocation
        name: managementVmName
        file: storageToDomainScript
        scriptArguments: varStorageToDomainScriptArgs
        domainJoinUserPassword: avdWrklKeyVaultget.getSecret('domainJoinUserPassword')
        baseScriptUri: storageToDomainScriptUri
    }
    dependsOn: [
        storageAndFile
        managementVmWait
    ]
}
 
// =========== //
//   Outputs   //
// =========== //

output storageAccountName string = storageAndFile.outputs.name
output fileShareName string = varFileShareName
