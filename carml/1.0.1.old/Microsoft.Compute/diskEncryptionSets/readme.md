# Disk Encryption Sets `[Microsoft.Compute/diskEncryptionSets]`

This template deploys a disk encryption set.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/roleAssignments` | 2021-04-01-preview |
| `Microsoft.Compute/diskEncryptionSets` | 2021-04-01 |
| `Microsoft.KeyVault/vaults/accessPolicies` | 2021-06-01-preview |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `keyUrl` | string | Key URL (with version) pointing to a key or secret in KeyVault. |
| `keyVaultId` | string | Resource ID of the KeyVault containing the key or secret. |
| `name` | string | The name of the disk encryption set that is being created. |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `encryptionType` | string | `'EncryptionAtRestWithPlatformAndCustomerKeys'` | `[EncryptionAtRestWithCustomerKey, EncryptionAtRestWithPlatformAndCustomerKeys]` | The type of key used to encrypt the data of the disk. For security reasons, it is recommended to set encryptionType to EncryptionAtRestWithPlatformAndCustomerKeys |
| `location` | string | `[resourceGroup().location]` |  | Resource location. |
| `roleAssignments` | array | `[]` |  | Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' |
| `rotationToLatestKeyVersionEnabled` | bool | `False` |  | Set this flag to true to enable auto-updating of this disk encryption set to the latest key version. |
| `tags` | object | `{object}` |  | Tags of the disk encryption resource. |


### Parameter Usage: `roleAssignments`

Create a role assignment for the given resource. If you want to assign a service principal / managed identity that is created in the same deployment, make sure to also specify the `'principalType'` parameter and set it to `'ServicePrincipal'`. This will ensure the role assignment waits for the principal's propagation in Azure.

```json
"roleAssignments": {
    "value": [
        {
            "roleDefinitionIdOrName": "Reader",
            "description": "Reader Role Assignment",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012", // object 1
                "78945612-1234-1234-1234-123456789012" // object 2
            ]
        },
        {
            "roleDefinitionIdOrName": "/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012" // object 1
            ],
            "principalType": "ServicePrincipal"
        }
    ]
}
```

### Parameter Usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

```json
"tags": {
    "value": {
        "Environment": "Non-Prod",
        "Contact": "test.user@testcompany.com",
        "PurchaseOrder": "1234",
        "CostCenter": "7890",
        "ServiceName": "DeploymentValidation",
        "Role": "DeploymentValidation"
    }
}
```

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `keyVaultName` | string | The name of the key vault with the disk encryption key |
| `name` | string | The name of the disk encryption set |
| `resourceGroupName` | string | The resource group the disk encryption set was deployed into |
| `resourceId` | string | The resource ID of the disk encryption set |
| `systemAssignedPrincipalId` | string | The principal ID of the disk encryption set |

## Template references

- [Diskencryptionsets](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Compute/2021-04-01/diskEncryptionSets)
- [Roleassignments](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/roleAssignments)
- [Vaults/Accesspolicies](https://docs.microsoft.com/en-us/azure/templates/Microsoft.KeyVault/2021-06-01-preview/vaults/accessPolicies)
