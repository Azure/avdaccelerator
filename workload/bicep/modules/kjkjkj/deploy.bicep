targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@description('Resource Group Name for Azure Files.')
param storageObjectsRgName string

@description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@description('Resource Group Name for management VM.')
param serviceObjectsRgName string

@description('Storage account name.')
param storageAccountName string

@description('Storage account file share name.')
param fileShareName string

@description('Private endpoint subnet ID.')
param privateEndpointSubnetId string

@description('Location where to deploy compute services.')
param sessionHostLocation string

@description('File share SMB multichannel.')
param fileShareMultichannel bool

@description('AD domain name.')
param identityDomainName string

@description('AD domain GUID.')
param identityDomainGuid string

@description('Keyvault name to get credentials from.')
param wrklKvName string

@description('AVD session host domain join credentials.')
param domainJoinUserName string

@description('Azure Files storage account SKU.')
param storageSku string

@description('*Azure File share quota')
param fileShareQuotaSize int

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

// =========== //
// Variable declaration //
// =========== //
var varAzureCloudName = environment().name
var varStoragePurposeLower = toLower(storagePurpose)
var varAvdFileShareLogsDiagnostic = [
    'allLogs'
]
var varAvdFileShareMetricsDiagnostic = [
    'Transaction'
]
var varWrklStoragePrivateEndpointName = 'pe-${storageAccountName}-file'
var vardirectoryServiceOptions = (identityServiceProvider == 'AADDS') ? 'AADDS': (identityServiceProvider == 'AAD') ? 'AADKERB': 'None'
var varStorageToDomainScriptArgs = '-DscPath ${dscAgentPackageLocation} -StorageAccountName ${storageAccountName} -StorageAccountRG ${storageObjectsRgName} -StoragePurpose ${storagePurpose} -DomainName ${identityDomainName} -IdentityServiceProvider ${identityServiceProvider} -AzureCloudEnvironment ${varAzureCloudName} -SubscriptionId ${workloadSubsId} -DomainAdminUserName ${domainJoinUserName} -CustomOuPath ${storageCustomOuPath} -OUName ${ouStgPath} -CreateNewOU ${createOuForStorageString} -ShareName ${fileShareName} -ClientId ${managedIdentityClientId}'
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
        name: storageAccountName
        location: sessionHostLocation
        skuName: storageSku
        allowBlobPublicAccess: false
        publicNetworkAccess: deployPrivateEndpoint ? 'Disabled' : 'Enabled'
        kind: ((storageSku =~ 'Premium_LRS') || (storageSku =~ 'Premium_ZRS')) ? 'FileStorage' : 'StorageV2'
        azureFilesIdentityBasedAuthentication: {
            directoryServiceOptions: vardirectoryServiceOptions
            activeDirectoryProperties: (identityServiceProvider == 'AAD') ? {
                domainGuid: identityDomainGuid
                domainName: identityDomainName
            }: {}
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
                    name: fileShareName
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
        privateEndpoints: deployPrivateEndpoint ? [
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
        ] : []
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

// Custom Extension call in on the DSC script to join Azure storage account to domain. 
module addShareToDomainScript './.bicep/azureFilesDomainJoin.bicep' = {
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
    ]
}

// =========== //
//   Outputs   //
// =========== //
