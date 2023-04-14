# Key Vault Key `[Microsoft.KeyVault/vaults/keys]`

This module deploys a key vault key.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/roleAssignments` | 2021-04-01-preview |
| `Microsoft.KeyVault/vaults/keys` | 2019-09-01 |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `keyVaultName` | string | The name of the key vault |
| `name` | string | The name of the key |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `attributesEnabled` | bool | `True` |  | Determines whether the object is enabled. |
| `attributesExp` | int | `-1` |  | Expiry date in seconds since 1970-01-01T00:00:00Z. For security reasons, it is recommended to set an expiration date whenever possible. |
| `attributesNbf` | int | `-1` |  | Not before date in seconds since 1970-01-01T00:00:00Z. |
| `curveName` | string | `'P-256'` | `[P-256, P-256K, P-384, P-521]` | The elliptic curve name. |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `keyOps` | array | `[]` | `[decrypt, encrypt, import, sign, unwrapKey, verify, wrapKey]` | Array of JsonWebKeyOperation |
| `keySize` | int | `-1` |  | The key size in bits. For example: 2048, 3072, or 4096 for RSA. |
| `kty` | string | `'EC'` | `[EC, EC-HSM, RSA, RSA-HSM]` | The type of the key. |
| `roleAssignments` | array | `[]` |  | Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' |
| `tags` | object | `{object}` |  | Resource tags. |


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

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the key. |
| `resourceGroupName` | string | The name of the resource group the key was created in. |
| `resourceId` | string | The resource ID of the key. |

## Template references

- [Roleassignments](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/roleAssignments)
- [Vaults/Keys](https://docs.microsoft.com/en-us/azure/templates/Microsoft.KeyVault/2019-09-01/vaults/keys)
