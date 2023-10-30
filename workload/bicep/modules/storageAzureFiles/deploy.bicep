targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@sys.description('Resource Group Name for Azure Files.')
param storageObjectsRgName string

@sys.description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Resource Group Name for management VM.')
param serviceObjectsRgName string

@sys.description('Storage account name.')
param storageAccountName string

@sys.description('Storage account file share name.')
param fileShareName string

@sys.description('Private endpoint subnet ID.')
param privateEndpointSubnetId string

@sys.description('Location where to deploy compute services.')
param sessionHostLocation string

@sys.description('File share SMB multichannel.')
param fileShareMultichannel bool

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('AD domain GUID.')
param identityDomainGuid string

@sys.description('Keyvault name to get credentials from.')
param wrklKvName string

@sys.description('AVD session host domain join credentials.')
param domainJoinUserName string

@sys.description('Azure Files storage account SKU.')
param storageSku string

@sys.description('*Azure File share quota')
param fileShareQuotaSize int

@sys.description('Use Azure private DNS zones for private endpoints.')
param vnetPrivateDnsZoneFilesId string

@sys.description('Script name for adding storage account to Active Directory.')
param storageToDomainScript string

@sys.description('URI for the script for adding the storage account to Active Directory.')
param storageToDomainScriptUri string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Name for management virtual machine. for tools and to join Azure Files to domain.')
param managementVmName string

@sys.description('Optional. AVD Accelerator will deploy with private endpoints by default.')
param deployPrivateEndpoint bool

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('Sets purpose of the storage account.')
param storagePurpose string

//parameters for domain join
@sys.description('Sets location of DSC Agent.')
param dscAgentPackageLocation string

@sys.description('Custom OU path for storage.')
param storageCustomOuPath string

@sys.description('OU Storage Path')
param ouStgPath string

@sys.description('Managed Identity Client ID')
param managedIdentityClientId string

@sys.description('Identity name array to grant RBAC role to access AVD application group and NTFS permissions.')
param securityPrincipalName string

@sys.description('storage account FDQN.')
param storageAccountFqdn string

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
var varDirectoryServiceOptions = (identityServiceProvider == 'AADDS') ? 'AADDS': (identityServiceProvider == 'AAD') ? 'AADKERB': 'None'
var varSecurityPrincipalName = !empty(securityPrincipalName)? securityPrincipalName : 'none'
var varStorageToDomainScriptArgs = '-DscPath ${dscAgentPackageLocation} -StorageAccountName ${storageAccountName} -StorageAccountRG ${storageObjectsRgName} -StoragePurpose ${storagePurpose} -DomainName ${identityDomainName} -IdentityServiceProvider ${identityServiceProvider} -AzureCloudEnvironment ${varAzureCloudName} -SubscriptionId ${workloadSubsId} -DomainAdminUserName ${domainJoinUserName} -CustomOuPath ${storageCustomOuPath} -OUName ${ouStgPath} -ShareName ${fileShareName} -ClientId ${managedIdentityClientId} -SecurityPrincipalName ${varSecurityPrincipalName} -StorageAccountFqdn ${storageAccountFqdn} '
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
            directoryServiceOptions: varDirectoryServiceOptions
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
                    shareQuota: fileShareQuotaSize * 100 //Portal UI steps scale
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
    }
}

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
