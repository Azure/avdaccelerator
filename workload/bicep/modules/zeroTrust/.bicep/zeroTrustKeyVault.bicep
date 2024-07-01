targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('AVD Resource Group Name for the service objects.')
param rgName string

@sys.description('Deploy private endpoints for key vault and storage.')
param deployPrivateEndpointKeyvaultStorage bool

@sys.description('Key vault name')
param kvName string

@sys.description('Private endpoint subnet resource ID')
param privateEndpointsubnetResourceId string

@sys.description('Key vault private endpoint name.')
param ztKvPrivateEndpointName string

@sys.description('Private DNS zone for key vault private endpoint')
param keyVaultprivateDNSResourceId string

@sys.description('This value is used to set the expiration date on the disk encryption key.')
param diskEncryptionKeyExpirationInDays int

@sys.description('This value is used to set the expiration date on the disk encryption key.')
param diskEncryptionKeyExpirationInEpoch int

@sys.description('Encryption set name')
param diskEncryptionSetName string

//@sys.description('Zero trust managed identity')
//param ztManagedIdentityResourceId string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@description('Specifies the SKU for the vault.')
param vaultSku string

@sys.description('Enable purge protection on the key vault')
param enableKvPurgeProtection bool = true
// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Key vault for Zero Trust.
module ztKeyVault '../../../../../avm/1.0.0/res/key-vault/vault/main.bicep' = {
    scope: resourceGroup('${subscriptionId}', '${rgName}')
    name: 'ZT-KeyVault-${time}'
    params: {
        name: kvName
        location: location
        enableRbacAuthorization: true
        enablePurgeProtection: enableKvPurgeProtection
        softDeleteRetentionInDays: 7
        sku: vaultSku
        publicNetworkAccess: 'Disabled'
        networkAcls: {
            bypass: 'AzureServices'
            defaultAction: 'Deny'
            virtualNetworkRules: []
            ipRules: []
        }
        privateEndpoints: deployPrivateEndpointKeyvaultStorage ? [
            {
                name: ztKvPrivateEndpointName
                subnetResourceId: privateEndpointsubnetResourceId
                customNetworkInterfaceName: 'nic-01-${ztKvPrivateEndpointName}'
                service: 'vault'
                privateDnsZoneGroup: {
                    privateDNSResourceIds: [
                        keyVaultprivateDNSResourceId
                    ]
                }
            }
        ] : []
        tags: tags
    }
    dependsOn: []
}

// Disk Encryption Key for Zero Trust.
module ztKeyVaultKey '../../../../../avm/1.0.0/res/key-vault/vault/key/main.bicep' = {
    scope: resourceGroup('${subscriptionId}', '${rgName}')
    name: 'ZT-KeyVaultKey-${time}'
    params: {
        attributesEnabled: true
        attributesExp: diskEncryptionKeyExpirationInEpoch
        keySize: 4096
        keyVaultName: ztKeyVault.outputs.name
        kty: 'RSA'
        name: 'DiskEncryptionKey'
        rotationPolicy: {
            attributes: {
                expiryTime: 'P${string(diskEncryptionKeyExpirationInDays)}D'
            }
            lifetimeActions: [
                {
                    action: {
                        type: 'notify'
                    }
                    trigger: {
                        timeBeforeExpiry: 'P10D'
                    }
                }
                {
                    action: {
                        type: 'rotate'
                    }
                    trigger: {
                        timeAfterCreate: 'P${string(diskEncryptionKeyExpirationInDays - 7)}D'
                    }
                }
            ]
        }
        tags: tags
    }
}

// Disk Encryption Set for Zero Trust.
module ztDiskEncryptionSet '../../../../../avm/1.0.0/res/compute/disk-encryption-set/main.bicep' = {
    scope: resourceGroup('${subscriptionId}', '${rgName}')
    name: 'ZT-DiskEncryptionSet-${time}'
    params: {
        keyName: ztKeyVaultKey.outputs.name
        keyVaultResourceId: ztKeyVault.outputs.resourceId
        location: location
        name: diskEncryptionSetName
        rotationToLatestKeyVersionEnabled: true
        managedIdentities: {
            systemAssigned: true
        }
        tags: tags
    }
}

// =========== //
// Outputs //
// =========== //

output ztDiskEncryptionSetResourceId string = ztDiskEncryptionSet.outputs.resourceId
output ztDiskEncryptionSetPrincipalId string = ztDiskEncryptionSet.outputs.systemAssignedMIPrincipalId
