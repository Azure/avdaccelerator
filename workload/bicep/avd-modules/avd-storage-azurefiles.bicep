targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Resource Group name for the session hosts.')
param avdComputeObjectsRgName string

@description('Optional. AVD workload subscription ID, multiple subscriptions scenario.')
param avdWorkloadSubsId string

@description('Required. Virtual machine time zone.')
param avdTimeZone string

@description('Resource Group Name for Azure Files.')
param avdStorageObjectsRgName string

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param avdIdentityServiceProvider string

@description('Resource Group Name for Azure Files.')
param avdServiceObjectsRgName string

@description('AVD subnet ID.')
param avdSubnetId string

@description('Optional. Create new virtual network.')
param createAvdVnet bool

@description('Required. Location where to deploy compute services.')
param avdSessionHostLocation string

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@description('Session host VM size.')
param avdSessionHostsSize string

@description('OS disk type for session host.')
param avdSessionHostDiskType string

@description('Market Place OS image')
param marketPlaceGalleryWindowsManagementVm object

@description('Set to deploy image from Azure. Compute Gallery')
param useSharedImage bool

@description('Source custom image ID.')
param avdImageTemplateDefinitionId string

@description('*Managed Identity Resource ID.')
param avdManagedIdentityResourceId string

@description('*File share SMB multichannel.')
param avdFileShareMultichannel bool

@description('Subnet resource ID for the Azure Files private endpoint.')
param subnetResourceId string

@description('Local administrator username.')
param avdVmLocalUserName string

@description('Required. AD domain name.')
param avdIdentityDomainName string

@description('Required. Keyvault name to get credentials from.')
param avdWrklKvName string

@description('Required. AVD session host domain join credentials.')
param avdDomainJoinUserName string

@description('Optional. OU path to join AVd VMs.')
param sessionHostOuPath string

@description('Application Security Group (ASG) for the session hosts.')
param avdApplicationSecurityGroupResourceId string

@description('*Azure Files storage account SKU.')
param storageSku string

@description('*Azure File share quota')
param avdFileShareQuotaSize int

@description('Use Azure private DNS zones for private endpoints.')
param avdVnetPrivateDnsZone bool

@description('Use Azure private DNS zones for private endpoints.')
param avdVnetPrivateDnsZoneFilesId string

@description('Script name for adding storage account to Active Directory.')
param storageToDomainScript string

@description('URI for the script for adding the storage account to Active Directory.')
param storageToDomainScriptUri string

@description('Required. Tags to be applied to resources')
param avdTags object

@description('Optional. Log analytics workspace for diagnostic logs.')
param avdAlaWorkspaceResourceId string

@description('Optional. Diagnostic logs retention.')
param avdDiagnosticLogsRetentionInDays int

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@description('Sets purpose of the storage account.')
param storagePurpose string

@description('Required. AVD resources custom naming. (Default: false)')
param useCustomNaming bool

@description('Sets purpose of the storage account.')
param storageAccountPrefixCustomName string

@description('Deployment Prefix set in main template, in lowercase.')
param avdDeploymentPrefixLowercase string

@description('Sets purpose of the storage account.')
param avdNamingUniqueStringSixChar string


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
@description('Optional. AVD fslogix storage account profile container file share prefix custom name. (Default: storagePurpose-pc-app1-001)')
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

var varFileShareName = useCustomNaming ? fileShareCustomName : '${varStoragePurposeLower}-pc-${avdDeploymentPrefixLowercase}-001'
var varAvdWrklStoragePrivateEndpointName = 'pe-${varStorageName}-file'
var varStoragePurposeLower = toLower(storagePurpose)
var varStoragePurposeLowerPrefix = substring(varStoragePurposeLower, 0,2)

var varStorageName = useCustomNaming ? '${storageAccountPrefixCustomName}${varStoragePurposeLower}${avdDeploymentPrefixLowercase}${avdNamingUniqueStringSixChar}' : 'stavd${varStoragePurposeLower}${avdDeploymentPrefixLowercase}${avdNamingUniqueStringSixChar}'
var varManagementVmName = 'vm-mgmt-${varStoragePurposeLowerPrefix}-${avdDeploymentPrefixLowercase}'

var varStorageToDomainScriptArgs = '-DscPath ${dscAgentPackageLocation} -StorageAccountName ${varStorageName} -StorageAccountRG ${avdStorageObjectsRgName} -DomainName ${avdIdentityDomainName} -IdentityServiceProvider ${avdIdentityServiceProvider} -AzureCloudEnvironment AzureCloud -SubscriptionId ${avdWorkloadSubsId} -DomainAdminUserName ${avdDomainJoinUserName} -DomainAdminUserPassword ${domainJoinUserPassword} -CustomOuPath ${avdStorageCustomOuPath} -OUName ${avdOuStgPath} -CreateNewOU ${avdCreateOuForStorageString} -ShareName ${varFileShareName} -ClientId ${managedIdentityClientId} -Verbose'

// =========== //
// Deployments //
// =========== //

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
    name: avdWrklKvName
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
}

// Provision the storage account and Azure Files.
module storageAndFile '../../../carml/1.2.0/Microsoft.Storage/storageAccounts/deploy.bicep' = {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdStorageObjectsRgName}')
    name: 'AVD-${storagePurpose}-${time}'
    params: {
        name: varStorageName
        location: avdSessionHostLocation
        storageAccountSku: storageSku
        allowBlobPublicAccess: false
        storageAccountKind: ((storageSku =~ 'Premium_LRS') || (storageSku =~ 'Premium_ZRS')) ? 'FileStorage' : 'StorageV2'
        azureFilesIdentityBasedAuthentication: (avdIdentityServiceProvider == 'AADDS') ? {
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
                    sharedQuota: avdFileShareQuotaSize * 100 //Portal UI steps scale
                }
            ]
            protocolSettings: avdFileShareMultichannel ? {
                smb: {
                    multichannel: {
                        enabled: avdFileShareMultichannel
                    }
                }
            } : {}
            diagnosticWorkspaceId: avdAlaWorkspaceResourceId
            diagnosticLogCategoriesToEnable: varAvdFileShareLogsDiagnostic
            diagnosticMetricsToEnable: varAvdFileShareMetricsDiagnostic
        }
        privateEndpoints: avdVnetPrivateDnsZone ? [
            {
                name: varAvdWrklStoragePrivateEndpointName
                subnetResourceId: subnetResourceId
                service: 'file'
                privateDnsZoneResourceIds: [
                    avdVnetPrivateDnsZoneFilesId
                ]
            }
        ] : [
            {
                name: varAvdWrklStoragePrivateEndpointName
                subnetResourceId: subnetResourceId
                service: 'file'
            }
        ]
        tags: avdTags
        diagnosticWorkspaceId: avdAlaWorkspaceResourceId
        diagnosticLogsRetentionInDays: avdDiagnosticLogsRetentionInDays
    }
}

// Provision temporary VM and add it to domain.
module managementVM '../../../carml/1.2.0/Microsoft.Compute/virtualMachines/deploy.bicep' = {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'Deploy-Mgmt-VM-${storagePurpose}-${time}'
    params: {
        name: varManagementVmName
        location: avdSessionHostLocation
        timeZone: avdTimeZone
        systemAssignedIdentity: false
        userAssignedIdentities: {
            '${avdManagedIdentityResourceId}': {}
        }
        encryptionAtHost: encryptionAtHost
        availabilityZone: []
        osType: 'Windows'
        //licenseType: 'Windows_Client'
        vmSize: avdSessionHostsSize
        imageReference: useSharedImage ? json('{\'id\': \'${avdImageTemplateDefinitionId}\'}') : marketPlaceGalleryWindowsManagementVm
        //imageReference: marketPlaceGalleryWindowsManagementVm
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
                nicSuffix: 'nic-01-'
                deleteOption: 'Delete'
                enableAcceleratedNetworking: false
                ipConfigurations: createAvdVnet ? [
                    {
                        name: 'ipconfig01'
                        subnetId: avdSubnetId
                        applicationSecurityGroups: avdApplicationSecurityGroupResourceId
                    }
                ] : [
                    {
                        name: 'ipconfig01'
                        subnetId: avdSubnetId
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
                name: avdIdentityDomainName
                ouPath: !empty(sessionHostOuPath) ? sessionHostOuPath : null
                user: avdDomainJoinUserName
                restart: 'true'
                options: '3'
            }
        }
        tags: avdTags
    }
    dependsOn: [
        storageAndFile
    ]
}

// Introduce delay for management VM to be ready.
module managementVmDelay '../../../carml/1.0.0/Microsoft.Resources/deploymentScripts/deploy.bicep' = {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'AVD-Management-VM-${storagePurpose}-Delay-${time}'
    params: {
        name: '${storagePurpose}-userManagedIdentityDelay-${time}'
        location: avdSessionHostLocation
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
module addShareToDomainScript '../../vm-custom-extensions/add-azure-files-to-domain-script.bicep' = { //if(avdIdentityServiceProvider == 'ADDS')  {
    scope: resourceGroup('${avdWorkloadSubsId}', '${avdServiceObjectsRgName}')
    name: 'Add-${storagePurpose}-Storage-Setup-${time}'
    params: {
        location: avdSessionHostLocation
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
