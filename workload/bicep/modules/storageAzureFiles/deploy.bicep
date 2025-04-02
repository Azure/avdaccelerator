metadata name = 'AVD LZA storage'
metadata description = 'This module deploys storage account, azure files. domain join logic'
metadata owner = 'Azure/avdaccelerator'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subId string

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
param privateEndpointSubnetResourceId string

@sys.description('VMs subnet ID.')
param vmsSubnetResourceId string

@sys.description('Location where to deploy resources.')
param location string

@sys.description('File share SMB multichannel.')
param fileShareMultichannel bool

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('AD domain GUID.')
param identityDomainGuid string

@sys.description('Key Vault Resource ID.')
param keyVaultResourceId string

@sys.description('AVD session host domain join credentials.')
param domainJoinUserName string

@sys.description('AVD session host local admin credentials.')
param vmLocalUserName string

@sys.description('Azure Files storage account SKU.')
param storageSku string

@sys.description('*Azure File share quota')
param fileShareQuotaSize int

@sys.description('Use Azure private DNS zones for private endpoints.')
param privateDnsZoneFilesResourceId string

@sys.description('Script name for adding storage account to Active Directory.')
param storageToDomainScript string

@sys.description('URI for the script for adding the storage account to Active Directory.')
param storageToDomainScriptUri string

@sys.description('Tags to be applied to resources')
param tags object = {}

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
param storageOuPath string

@sys.description('Managed Identity Client ID')
param managedIdentityClientId string

@sys.description('Identity name array to grant RBAC role to access AVD application group and NTFS permissions.')
param securityPrincipalName string

@sys.description('storage account FDQN.')
param storageAccountFqdn string

// =========== //
// Variable declaration //
// =========== //

var varKeyVaultSubId = split(keyVaultResourceId, '/')[2]
var varKeyVaultRgName = split(keyVaultResourceId, '/')[4]
var varKeyVaultName = split(keyVaultResourceId, '/')[8]
var varAzureCloudName = environment().name
var varWrklStoragePrivateEndpointName = 'pe-${storageAccountName}-file'
var varSecurityPrincipalName = !empty(securityPrincipalName) ? securityPrincipalName : 'none'
var varAdminUserName = contains(identityServiceProvider, 'EntraID') 
  ? vmLocalUserName 
  : domainJoinUserName
var varStorageToDomainScriptArgs = '-DscPath ${dscAgentPackageLocation} -StorageAccountName ${storageAccountName} -StorageAccountRG ${storageObjectsRgName} -StoragePurpose ${storagePurpose} -DomainName ${identityDomainName} -IdentityServiceProvider ${identityServiceProvider} -AzureCloudEnvironment ${varAzureCloudName} -SubscriptionId ${subId} -AdminUserName ${varAdminUserName} -CustomOuPath ${storageCustomOuPath} -OUName ${storageOuPath} -ShareName ${fileShareName} -ClientId ${managedIdentityClientId} -SecurityPrincipalName "${varSecurityPrincipalName}" -StorageAccountFqdn ${storageAccountFqdn} '
var varDiagnosticSettings = !empty(alaWorkspaceResourceId)
  ? [
      {
        workspaceResourceId: alaWorkspaceResourceId
        logCategoriesAndGroups: []
      }
    ]
  : []
  
// =========== //
// Deployments //
// =========== //

// Call on the KV.
resource avdWrklKeyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: varKeyVaultName
  scope: resourceGroup('${varKeyVaultSubId}', '${varKeyVaultRgName}')
}

// Provision the storage account and Azure Files.
module storageAndFile '../../../../avm/1.0.0/res/storage/storage-account/main.bicep' = {
  scope: resourceGroup('${subId}', '${storageObjectsRgName}')
  name: 'Storage-${storagePurpose}-${time}'
  params: {
    name: storageAccountName
    location: location
    skuName: storageSku
    allowBlobPublicAccess: false
    publicNetworkAccess: deployPrivateEndpoint 
      ? 'Disabled' 
      : 'Enabled'
    kind: (storageSku == 'Premium_LRS' || storageSku == 'Premium_ZRS') 
      ? 'FileStorage' 
      : 'StorageV2'
    largeFileSharesState: (storageSku == 'Standard_LRS' || storageSku == 'Standard_ZRS') 
      ? 'Enabled' 
      : 'Disabled'
    azureFilesIdentityBasedAuthentication: identityServiceProvider != 'EntraID'
      ? {
          directoryServiceOptions: identityServiceProvider == 'EntraDS'
            ? 'AADDS'
            : identityServiceProvider == 'EntraIDKerberos' ? 'AADKERB' : 'none'
          activeDirectoryProperties: (identityServiceProvider == 'EntraIDKerberos')
            ? {
                domainGuid: identityDomainGuid
                domainName: identityDomainName
              }
            : {}
        }
      : null
    accessTier: 'Hot'
    networkAcls: deployPrivateEndpoint ? {
        bypass: 'AzureServices'
        defaultAction: 'Deny'
        virtualNetworkRules: []
        ipRules: []
    } : {
        bypass: 'AzureServices'
        defaultAction: 'Deny'
        virtualNetworkRules: [
            {
                id: vmsSubnetResourceId
                action: 'Allow'
            }
        ]
        ipRules: []
    }
    fileServices: {
      shares: [
        {
          name: fileShareName
          shareQuota: fileShareQuotaSize
        }
      ]
      protocolSettings: fileShareMultichannel
        ? {
            smb: {
              multichannel: {
                enabled: fileShareMultichannel
              }
            }
          }
        : {}
      diagnosticSettings: varDiagnosticSettings
    }
    privateEndpoints: deployPrivateEndpoint
      ? [
          {
            name: varWrklStoragePrivateEndpointName
            subnetResourceId: privateEndpointSubnetResourceId
            customNetworkInterfaceName: 'nic-01-${varWrklStoragePrivateEndpointName}'
            service: 'file'
            privateDnsZoneGroupName: split(privateDnsZoneFilesResourceId, '/')[8]
            privateDnsZoneResourceIds: [
              privateDnsZoneFilesResourceId
            ]
          }
        ]
      : []
    tags: tags
    diagnosticSettings: varDiagnosticSettings
  }
}

// Custom Extension call in on the DSC script to join Azure storage account to domain. 
module addShareToDomainScript '../sharedModules/smbUtilities.bicep' = if (identityServiceProvider != 'EntraID') {
  scope: resourceGroup('${subId}', '${serviceObjectsRgName}')
  name: 'Add-${storagePurpose}-Storage-Setup-${time}'
  params: {
    location: location
    virtualMachineName: managementVmName
    file: storageToDomainScript
    scriptArguments: varStorageToDomainScriptArgs
    adminUserPassword: contains(identityServiceProvider, 'EntraID')
      ? avdWrklKeyVaultget.getSecret('vmLocalUserPassword')
      : avdWrklKeyVaultget.getSecret('domainJoinUserPassword')
    baseScriptUri: storageToDomainScriptUri
  }
  dependsOn: [
    storageAndFile
  ]
}

// =========== //
// Outputs //
// =========== //

output storageAccountResourceId string = storageAndFile.outputs.resourceId
