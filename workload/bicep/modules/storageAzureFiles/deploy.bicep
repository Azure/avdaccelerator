metadata name = 'AVD LZA storage'
metadata description = 'This module deploys storage account, azure files. domain join logic'
metadata owner = 'Azure/avdaccelerator'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Optional. AVD Accelerator will deploy with private endpoints by default.')
param deployPrivateEndpoint bool

@sys.description('Object ID for the domain join user principal in Entra ID.')
param domainJoinUserObjectId string

@sys.description('Storage account file share name.')
param fileShareName string

@sys.description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Required, The encryption type for Azure Files.')
param kerberosEncryption string

@sys.description('Location where to deploy resources.')
param location string

@sys.description('File share SMB multichannel.')
param fileShareMultichannel bool

@sys.description('*Azure File share quota')
param fileShareQuotaSize int

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('AD domain GUID.')
param identityDomainGuid string

@sys.description('Managed Identity Client ID')
param managedIdentityClientId string

@sys.description('Name for management virtual machine. for tools and to join Azure Files to domain.')
param managementVmName string

@sys.description('OU Storage Path')
param ouStgPath string

@sys.description('Private endpoint subnet ID.')
param privateEndpointSubnetId string

@sys.description('Identity name array to grant RBAC role to access AVD application group and NTFS permissions.')
param securityPrincipalName string

@sys.description('Resource Group Name for management VM.')
param serviceObjectsRgName string

@sys.description('Storage account name.')
param storageAccountName string

@sys.description('Custom OU path for storage.')
param storageCustomOuPath string

@sys.description('Resource Group Name for Azure Files.')
param storageObjectsRgName string

@sys.allowed([
  'AppAttach'
  'Fslogix'
])
@sys.description('Sets purpose of the storage account.')
param storagePurpose string

@sys.description('Azure Files storage account SKU.')
param storageSku string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('VMs subnet ID.')
param vmsSubnetId string

@sys.description('Use Azure private DNS zones for private endpoints.')
param vnetPrivateDnsZoneFilesId string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param workloadSubsId string

@sys.description('Keyvault name to get credentials from.')
param wrklKvName string

// =========== //
// Variable declaration //
// =========== //

var varWrklStoragePrivateEndpointName = 'pe-${storageAccountName}-file'
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
  name: wrklKvName
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
}

// Assign the domain join user the Storage File Data SMB Share Elevated Contributor role on the storage resource group.
module ntfsPermissionsRoleAssignment '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = if (endsWith(identityServiceProvider, 'DS')) {
  scope: resourceGroup('${workloadSubsId}', '${storageObjectsRgName}')
  name: 'DomainJoin-RoleAssignment-${storagePurpose}-${time}'
  params: {
    roleDefinitionIdOrName: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a7264617-510b-434b-a828-9731dc254ea7') // Storage File Data SMB Share Elevated Contributor
    principalId: domainJoinUserObjectId
    principalType: 'User'
  }
}

// Provision the storage account and Azure Files.
module storageAndFile '../../../../avm/1.0.0/res/storage/storage-account/main.bicep' = {
  scope: resourceGroup('${workloadSubsId}', '${storageObjectsRgName}')
  name: 'Storage-${storagePurpose}-${time}'
  params: {
    name: storageAccountName
    location: location
    skuName: storageSku
    allowBlobPublicAccess: false
    publicNetworkAccess: deployPrivateEndpoint ? 'Disabled' : 'Enabled'
    kind: ((storageSku == 'Premium_LRS') || (storageSku == 'Premium_ZRS')) ? 'FileStorage' : 'StorageV2'
    largeFileSharesState: (storageSku == 'Standard_LRS') || (storageSku == 'Standard_ZRS') ? 'Enabled' : 'Disabled'
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
                id: vmsSubnetId
                action: 'Allow'
            }
        ]
        ipRules: []
    }
    fileServices: {
      shares: [
        {
          name: fileShareName
          shareQuota: fileShareQuotaSize * 100 //Portal UI steps scale
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
            subnetResourceId: privateEndpointSubnetId
            customNetworkInterfaceName: 'nic-01-${varWrklStoragePrivateEndpointName}'
            service: 'file'
            privateDnsZoneGroupName: split(vnetPrivateDnsZoneFilesId, '/')[8]
            privateDnsZoneResourceIds: [
              vnetPrivateDnsZoneFilesId
            ]
          }
        ]
      : []
    tags: tags
    diagnosticSettings: varDiagnosticSettings
  }
}

// Custom Extension call in on the DSC script to join Azure storage account to domain. 
module addShareToDomainScript './.bicep/azureFilesDomainJoin.bicep' = if (endsWith(identityServiceProvider, 'DS')) {
  scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
  name: 'Add-${storagePurpose}-Storage-Setup-${time}'
  params: {
    domainJoinPassword: avdWrklKeyVaultget.getSecret('domainJoinUserPassword')
    domainJoinUserName: avdWrklKeyVaultget.getSecret('domainJoinUserName')
    identityServiceProvider: identityServiceProvider
    kerberosEncryption: kerberosEncryption
    location: location
    organizationalUnitPath: empty(storageCustomOuPath) ? ouStgPath : storageCustomOuPath
    securityPrincipalName: securityPrincipalName
    shareName: fileShareName
    storageAccountName: storageAccountName
    storageAccountResourceGroupName: storageObjectsRgName
    storagePurpose: storagePurpose
    tags: tags
    userAssignedIdentityClientId: managedIdentityClientId
    virtualMachineName: managementVmName
  }
  dependsOn: [
    storageAndFile
  ]
}

// =========== //
// Outputs //
// =========== //
output storageAccountResourceId string = storageAndFile.outputs.resourceId
