targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('Enables a zero trust configuration on the session host disks.')
param diskZeroTrust bool

@sys.description('AVD Resource Group Name for the service objects.')
param serviceObjectsRgName string

@sys.description('AVD Resource Group Name for the service objects.')
param computeObjectsRgName string

@sys.description('Managed identity for zero trust setup.')
param managedIdentityName string

@sys.description('This value is used to set the expiration date on the disk encryption key.')
param diskEncryptionKeyExpirationInDays int

@sys.description('This value is used to set the expiration date on the disk encryption key.')
param diskEncryptionKeyExpirationInEpoch int

@sys.description('Deploy private endpoints for key vault and storage.')
param deployPrivateEndpointKeyvaultStorage bool

@sys.description('Key vault private endpoint name.')
param ztKvPrivateEndpointName string

@sys.description('Private endpoint subnet resource ID')
param privateEndpointsubnetResourceId string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Tags to be added to key vault')
param kvTags object

@sys.description('Encryption set name')
param diskEncryptionSetName string

@sys.description('Key vault name')
param ztKvName string

@sys.description('Private DNS zone for key vault private endpoint')
param keyVaultprivateDNSResourceId string

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('Enable purge protection on the key vault')
param enableKvPurgeProtection bool = true

@sys.description('Specifies the SKU for the vault.')
param vaultSku string

// =========== //
// Variable declaration //
// =========== //
var varCustomPolicyDefinitions = [
    {
        deploymentName: 'ZT-Disk'
        libDefinition: json(loadTextContent('../../../policies/zeroTrust/policyDefinitions/policy-definition-es-vm-disk-zero-trust.json'))
    }
]
// =========== //
// Deployments //
// =========== //
// call on the keyvault.

// Policy Definition for Managed Disk Network Access.
module ztPolicyDefinitions '../azurePolicies/policyDefinitionsSubscriptions.bicep' = [for customPolicyDefinition in varCustomPolicyDefinitions: if (diskZeroTrust) {
    scope: subscription('${subscriptionId}')
    name: 'Policy-Defin-${customPolicyDefinition.deploymentName}-${time}'
    params: {
        description: customPolicyDefinition.libDefinition.properties.description
        displayName: customPolicyDefinition.libDefinition.properties.displayName
        name: customPolicyDefinition.libDefinition.name
        metadata: customPolicyDefinition.libDefinition.properties.metadata
        mode: customPolicyDefinition.libDefinition.properties.mode
        parameters: customPolicyDefinition.libDefinition.properties.parameters
        policyRule: customPolicyDefinition.libDefinition.properties.policyRule
    }
}]

// Policy Assignment for Managed Disk Network Access.
module ztPolicyAssignmentServiceObjects '../../../../avm/1.0.0/ptn/authorization/policy-assignment/modules/resource-group.bicep' = [for (customPolicyDefinition, i) in varCustomPolicyDefinitions: if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
    name: 'Pol-Assign-ServObj${customPolicyDefinition.deploymentName}-${time}'
    params: {
        name: customPolicyDefinition.libDefinition.name
        displayName: customPolicyDefinition.libDefinition.properties.displayName
        description: customPolicyDefinition.libDefinition.properties.description
        identity: 'SystemAssigned'
        location: location
        policyDefinitionId: diskZeroTrust ? ztPolicyDefinitions[i].outputs.resourceId : ''
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
}]

// Policy Remediation Task for Zero Trust.
module ztPolicyServBojRemediationTask '../../../../avm/1.0.0/ptn/policy-insights/remediation/modules/resource-group.bicep' = [for (customPolicyDefinition, i) in varCustomPolicyDefinitions: if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
    name: 'Remm-ServObj-${customPolicyDefinition.deploymentName}-${i}'
    params: {
        name: '${customPolicyDefinition.deploymentName}-${i}'
        policyAssignmentId: ztPolicyAssignmentServiceObjects[i].outputs.resourceId
    }
}]

// Policy Assignment for Managed Disk Network Access.
module ztPolicyAssignmentCompute '../../../../avm/1.0.0/ptn/authorization/policy-assignment/modules/resource-group.bicep' = [for (customPolicyDefinition, i) in varCustomPolicyDefinitions: if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'Pol-Assign-Comp-${customPolicyDefinition.deploymentName}-${time}'
    params: {
        name: customPolicyDefinition.libDefinition.name
        displayName: customPolicyDefinition.libDefinition.properties.displayName
        description: customPolicyDefinition.libDefinition.properties.description
        identity: 'SystemAssigned'
        location: location
        policyDefinitionId: diskZeroTrust ? ztPolicyDefinitions[i].outputs.resourceId : ''
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
}]

// Policy Remediation Task for Zero Trust.
module ztPolicyComputeRemediationTask '../../../../avm/1.0.0/ptn/policy-insights/remediation/modules/resource-group.bicep' = [for (customPolicyDefinition, i) in varCustomPolicyDefinitions: if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'Remm-Comp-${customPolicyDefinition.deploymentName}-${i}'
    params: {
        name: '${customPolicyDefinition.deploymentName}-${i}'
        policyAssignmentId: ztPolicyAssignmentCompute[i].outputs.resourceId
    }
}]

// Role Assignment for Zero Trust.
module ztRoleAssignmentCompute '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = [for (customPolicyDefinition, i) in varCustomPolicyDefinitions: if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'ZT-RA-Comp-${customPolicyDefinition.deploymentName}-${time}'
    params: {
        principalId: diskZeroTrust ? ztPolicyAssignmentCompute[i].outputs.principalId : ''
        roleDefinitionIdOrName: '/providers/Microsoft.Authorization/roleDefinitions/60fc6e62-5479-42d4-8bf4-67625fcc2840'
        principalType: ''
    }
}]

// Role Assignment for Zero Trust.
module ztRoleAssignmentServObj '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = [for (customPolicyDefinition, i) in varCustomPolicyDefinitions: if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
    name: 'ZT-RA-ServObj-${customPolicyDefinition.deploymentName}-${time}'
    params: {
        principalId: diskZeroTrust ? ztPolicyAssignmentServiceObjects[i].outputs.principalId : ''
        roleDefinitionIdOrName: '/providers/Microsoft.Authorization/roleDefinitions/60fc6e62-5479-42d4-8bf4-67625fcc2840'
        principalType: ''
    }
}]

// Role Assignment for Zero Trust.
module ztRoleAssignment '../../../../avm/1.0.0/ptn/authorization/role-assignment/modules/resource-group.bicep' = if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
    name: 'ZT-RA-${time}'
    params: {
        principalId: diskZeroTrust ? ztKeyVault.outputs.ztDiskEncryptionSetPrincipalId : ''
        roleDefinitionIdOrName: '/providers/Microsoft.Authorization/roleDefinitions/e147488a-f6f5-4113-8e2d-b22465e65bf6' //'Key Vault Crypto Service Encryption User'
        principalType: ''
    }
}

// Zero trust key vault.
module ztKeyVault './.bicep/zeroTrustKeyVault.bicep' = if (diskZeroTrust) {
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
    name: 'ZT-Key-Vault-${time}'
    params: {
        location: location
        subscriptionId: subscriptionId
        rgName: serviceObjectsRgName
        kvName: ztKvName
        vaultSku: vaultSku
        deployPrivateEndpointKeyvaultStorage: deployPrivateEndpointKeyvaultStorage
        ztKvPrivateEndpointName: ztKvPrivateEndpointName
        privateEndpointsubnetResourceId: privateEndpointsubnetResourceId
        keyVaultprivateDNSResourceId: keyVaultprivateDNSResourceId
        diskEncryptionKeyExpirationInDays: diskEncryptionKeyExpirationInDays
        diskEncryptionKeyExpirationInEpoch: diskEncryptionKeyExpirationInEpoch
        diskEncryptionSetName: diskEncryptionSetName
//        ztManagedIdentityResourceId: diskZeroTrust ? ztManagedIdentity.outputs.resourceId : ''
        tags: union(tags, kvTags)
        enableKvPurgeProtection: enableKvPurgeProtection
    }
}

// =========== //
// Outputs //
// =========== //

output ztDiskEncryptionSetResourceId string = diskZeroTrust ? ztKeyVault.outputs.ztDiskEncryptionSetResourceId : ''
