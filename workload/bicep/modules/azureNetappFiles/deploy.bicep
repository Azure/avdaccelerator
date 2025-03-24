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

@sys.description('Required, The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('ANF account name.')
param anfAccountName string

@sys.description('Capacity pool volume name.')
param anfCapacityPoolName string

@sys.description('ANF volume name.')
param anfVolumeName string

@sys.description('ANF subnet ID.')
param anfSubnetId string

@sys.description('DNS servers IPs.')
param dnsServers string

@sys.description('Location where to deploy resources.')
param location string

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('Keyvault resource ID to get credentials from.')
param kvResourceId string

@sys.description('AVD session host domain join credentials.')
param domainJoinUserName string

@sys.description('AVD session host local admin credentials.')
param vmLocalUserName string

@sys.description('ANF performance tier.')
param anfPerformance string

@sys.description('ANF capacity pool size in TiBs.')
param capacityPoolSize int = 4

@sys.description('ANF volume quota size in GiBs.')
param volumeSize int

@sys.description('Script name for adding storage account to Active Directory.')
param storageToDomainScript string

@sys.description('URI for the script for adding the storage account to Active Directory.')
param storageToDomainScriptUri string

@sys.description('Tags to be applied to resources')
param tags object = {}

@sys.description('Name for management virtual machine. for tools and to join Azure Files to domain.')
param managementVmName string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('Storage service provider.')
param storageService string

@sys.description('Sets purpose of the storage account.')
param storagePurpose string

//parameters for domain join
@sys.description('Sets location of DSC Agent.')
param dscAgentPackageLocation string

@sys.description('Custom OU path for storage.')
param storageCustomOuPath string

@sys.description('OU Storage Path')
param ouStgPath string = ''

@sys.description('Managed Identity Client ID')
param managedIdentityClientId string

// =========== //
// Variable declaration //
// =========== //
var varAzureCloudName = environment().name
var varAdminUserName = (identityServiceProvider == 'EntraID') ? vmLocalUserName : domainJoinUserName
var varStorageToDomainScriptArgs = '-StorageService ${storageService} -DscPath ${dscAgentPackageLocation} -StoragePurpose ${storagePurpose} -DomainName ${identityDomainName} -IdentityServiceProvider ${identityServiceProvider} -AzureCloudEnvironment ${varAzureCloudName} -SubscriptionId ${workloadSubsId} -AdminUserName ${varAdminUserName} -CustomOuPath ${storageCustomOuPath} -OUName ${ouStgPath} -ShareName ${fileShareName} -ClientId ${managedIdentityClientId} -SecurityPrincipalName "${varSecurityPrincipalName}" -StorageFqdn ${StorageFqdn} '
var varKvSubId = split(kvResourceId, '/')[2]
var varKvRgName = split(kvResourceId, '/')[4]
var varKvName = split(kvResourceId, '/')[8]


// =========== //
// Deployments //
// =========== //

// Call on the KV.
resource keyVaultget 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
    name: varKvName
    scope: resourceGroup('${varKvSubId}', '${varKvRgName}')
}

// Provision the Azure NetApp Files.
module azureNetAppFiles '../../../../avm/1.1.0/res/net-app/net-app-account/main.bicep' = {
    scope: resourceGroup('${subId}', '${storageObjectsRgName}')
    name: 'Storage-${storagePurpose}-${time}'
    params: {
        name: anfAccountName
        adName: anfAccountName
        domainName: identityDomainName
        domainJoinUser: domainJoinUserName
        domainJoinPassword: keyVaultget.getSecret('domainJoinUserPassword')
        domainJoinOU: ouStgPath
        dnsServers: dnsServers
        smbServerNamePrefix: anfAccountName
        location: location
        // aesEncryption: *************
        // customerManagedKey: *************
        capacityPools:[
            {
                name: anfCapacityPoolName
                serviceLevel: anfPerformance
                size: capacityPoolSize * 1099511627776 // Convert TiBs to bytes 
                encryptionType: 'Single'
                volumes: [
                    {
                        name: anfVolumeName
                        coolAccess: false
                        encryptionKeySource: 'Microsoft.NetApp'
                        zones: []
                        serviceLevel: anfPerformance
                        networkFeatures: 'Standard'
                        usageThreshold: volumeSize * 1073741824 // Convert GiBs to bytes
                        protocolTypes: [
                            'CIFS'
                        ]
                        subnetResourceId: anfSubnetId
                        creationToken: anfVolumeName
                        smbContinuouslyAvailable: true
                        securityStyle: 'ntfs'
                    }
                ]
            }
        ]
        tags: tags
    }
}

// Custom Extension call in on the DSC script to set NTFS permissions. 
module addShareToDomainScript './.bicep/azureFilesDomainJoin.bicep' = {
    scope: resourceGroup('${workloadSubsId}', '${serviceObjectsRgName}')
    name: 'Add-${storagePurpose}-Storage-Setup-${time}'
    params: {
        location: location
        virtualMachineName: managementVmName
        file: storageToDomainScript
        scriptArguments: varStorageToDomainScriptArgs
        adminUserPassword: (identityServiceProvider == 'EntraID') ? avdWrklKeyVaultget.getSecret('vmLocalUserPassword') : 
        baseScriptUri: storageToDomainScriptUri
    }
    dependsOn: [
        storageAndFile
    ]
}
