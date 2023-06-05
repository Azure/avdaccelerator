targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Location where to deploy compute services.')
param location string

@description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@description('Enables a zero trust configuration on the session host disks.')
param diskZeroTrust bool

@description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@description('Managed identity for zero trust setup.')
param managedIdentityName string

@description('This value is used to set the expiration date on the disk encryption key.')
param keyExpiration int

@description('This value is used to set the expiration date on the disk encryption key.')
param diskEncryptionKeyExpirationInDays int

@description('Deploy private endpoints for key vault and storage.')
param deployPrivateEndpointKeyvaultStorage bool

@description('Key vault private endpoint name.')
param ztKvPrivateEndpointName string

@description('Private endpoint subnet resource ID')
param privateEndpointsubnetResourceId string

@description('Tags to be applied to resources')
param tags object

@description('Encryption set name')
param diskEncryptionSetName string

@description('Key vault name')
param ztKvName string

@description('Private DNS zone for key vault private endpoint')
param keyVaultprivateDNSResourceId string

@description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //
// call on the keyvault.

// Policy Definition for Managed Disk Network Access.
module ztPolicyDefinition '../../../../carml/1.3.0/Microsoft.Authorization/policyDefinitions/subscription/deploy.bicep' = if (diskZeroTrust) {
    name: 'ZT-Policy-Definition-${time}'
    params: {
        description: 'This policy definition sets the network access policy property to "DenyAll" and the public network access property to "Disabled" on all the managed disks within the assigned scope.'
        displayName: 'Zero Trust - Disable Managed Disk Network Access'
        location: location
        name: 'AVDACC-Zero-Trust-Disable-Managed-Disk-Network-Access'
        policyRule: {
            if: {
                field: 'type'
                equals: 'Microsoft.Compute/disks'
            }
            then: {
                effect: 'modify'
                details: {
                    roleDefinitionIds: [
                        '/providers/Microsoft.Authorization/roleDefinitions/60fc6e62-5479-42d4-8bf4-67625fcc2840'
                    ]
                    operations: [
                        {
                            operation: 'addOrReplace'
                            field: 'Microsoft.Compute/disks/networkAccessPolicy'
                            value: 'DenyAll'
                        }
                        {
                            operation: 'addOrReplace'
                            field: 'Microsoft.Compute/disks/publicNetworkAccess'
                            value: 'Disabled'
                        }
                    ]
                }
            }
        }
    }
}

// Policy Assignment for Managed Disk Network Access.
module ztPolicyAssignment '../../../../carml/1.3.0/Microsoft.Authorization/policyAssignments/subscription/deploy.bicep' = if (diskZeroTrust) {
    name: 'ZT-Policy-Assignment-${time}'
    params: {
        name: 'AVDACC-Zero-Trust-Disable-Managed-Disk-Network-Access'
        displayName: 'Zero Trust - Disable Managed Disk Network Access'
        description: 'This policy assignment sets the network access policy property to "DenyAll" and the public network access property to "Disabled" on all the managed disks within the assigned scope.'
        identity: 'SystemAssigned'
        location: location
        policyDefinitionId: ztPolicyDefinition.outputs.resourceId
        resourceSelectors: [
            {
                name: 'VirtualMachineDisks'
                selectors: [
                    {
                        in: [
                            'Microsoft.Compute/disks'
                        ]
                        kind: 'resourceType'
                    }
                ]
            }
        ]
    }
}

// User Assigned Identity for Zero Trust.
module ztManagedIdentity '../../../../carml/1.3.0/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
    name: 'ZT-Managed-ID-${time}'
    params: {
        location: location
        name: managedIdentityName
        tags: tags
    }
    dependsOn: [

    ]
}

// Policy Remediation Task for Zero Trust.
resource ztPolicyRemediationTask 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
    name: 'remediate-disks-network-access'
    properties: {
        failureThreshold: {
            percentage: 1
          }
          parallelDeployments: 10
          policyAssignmentId: ztPolicyAssignment.outputs.resourceId
          resourceCount: 500
    }
}

// Role Assignment for Zero Trust.
module ztRoleAssignment01 '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/resourceGroup/deploy.bicep' = if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
    name: 'ZT-RoleAssignment-${time}'
    params: {
        principalId: ztManagedIdentity.outputs.principalId
        roleDefinitionIdOrName: 'Key Vault Crypto Service Encryption User'
        principalType: 'ServicePrincipal'
    }
}

// Role Assignment for Zero Trust.
module ztRoleAssignment02 '../../../../carml/1.3.0/Microsoft.Authorization/roleAssignments/subscription/deploy.bicep' = if (diskZeroTrust) {
    name: 'ZT-RoleAssignment-${time}'
    params: {
        location: location
        principalId: ztPolicyAssignment.outputs.principalId
        roleDefinitionIdOrName: 'Disk Pool Operator'
        principalType: 'ServicePrincipal'
    }
}

// Zero trust key vault.
module ztKeyVault './.bicep/zeroTrustKeyVault.bicep' = if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
    params: {
        location: location
        deployPrivateEndpointKeyvaultStorage: deployPrivateEndpointKeyvaultStorage
        ztKvPrivateEndpointName: ztKvPrivateEndpointName
        privateEndpointsubnetResourceId: privateEndpointsubnetResourceId
        keyVaultprivateDNSResourceId: keyVaultprivateDNSResourceId
        keyExpiration: keyExpiration
        diskEncryptionKeyExpirationInDays: diskEncryptionKeyExpirationInDays
        diskEncryptionSetName: diskEncryptionSetName
        ztManagedIdentityResourceId: ztManagedIdentity.outputs.resourceId
        tags: tags
    }
}

