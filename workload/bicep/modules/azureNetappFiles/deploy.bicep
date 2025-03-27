metadata name = 'AVD LZA storage'
metadata description = 'This module deploys ANF account, capacity pool and volumes'
metadata owner = 'Azure/avdaccelerator'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('Workload subscription ID')
param subId string

@sys.description('Resource Group Name where to deploy Azure NetApp Files.')
param storageObjectsRgName string

@sys.description('ANF account name.')
param accountName string

@sys.description('Capacity pool volume name.')
param capacityPoolName string

@sys.description('Capacity pool volume name.')
param createFslogixStorage bool

@sys.description('Capacity pool volume name.')
param createAppAttachStorage bool

@sys.description('ANF volumes.')
param volumes array

@sys.description('ANF SMB prefix.')
param smbServerNamePrefix string

@sys.description('DNS servers IPs.')
param dnsServers string

@sys.description('Location where to deploy resources.')
param location string

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('Organizational Unit (OU) storage path for domain join.')
param storageOuPath string

@sys.description('Keyvault resource ID to get credentials from.')
param keyVaultResourceId string

@sys.description('AVD session host domain join credentials.')
param domainJoinUserName string

@sys.description('ANF performance tier.')
param performance string

@sys.description('ANF capacity pool size in TiBs.')
param capacityPoolSize int = 4

@sys.description('Tags to be applied to resources')
param tags object = {}

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //
var varKeyVaultSubId = split(keyVaultResourceId, '/')[2]
var varKeyVaultRgName = split(keyVaultResourceId, '/')[4]
var varKeyVaultName = split(keyVaultResourceId, '/')[8]

// =========== //
// Deployments //
// =========== //

// Call on the KV.
resource keyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
    name: varKeyVaultName
    scope: resourceGroup('${varKeyVaultSubId}', '${varKeyVaultRgName}')
}

// Provision the Azure NetApp Files.
module azureNetAppFiles '../../../../avm/1.1.0/res/net-app/net-app-account/main.bicep' = {
    scope: resourceGroup('${subId}', '${storageObjectsRgName}')
    name: 'Storage-ANF-${time}'
    params: {
        name: accountName
        adName: accountName
        domainName: identityDomainName
        domainJoinUser: domainJoinUserName
        domainJoinPassword: keyVaultget.getSecret('domainJoinUserPassword')
        //domainJoinOU: replace(storageOuPath, '"', '\\"')
        dnsServers: dnsServers
        smbServerNamePrefix: smbServerNamePrefix
        location: location
        // aesEncryption: *************
        // customerManagedKey: *************
        capacityPools:[
            {
                name: capacityPoolName
                serviceLevel: performance
                size: capacityPoolSize * 1073741824
                volumes: volumes
            }
        ]
        tags: tags
        
    }
}

// =========== //
// Outputs //
// =========== //
output anfFslogixVolumeResourceId string = createFslogixStorage 
    ? azureNetAppFiles.outputs.capacityPoolResourceIds[0].volumeResourceIds[0] 
    : ''
output anfAppAttachVolumeResourceId string = (createAppAttachStorage && createFslogixStorage)
    ? azureNetAppFiles.outputs.capacityPoolResourceIds[1].volumeResourceIds[1] 
    : ((createAppAttachStorage && !createFslogixStorage) 
        ? azureNetAppFiles.outputs.capacityPoolResourceIds[0].volumeResourceIds[0] 
        : '')
