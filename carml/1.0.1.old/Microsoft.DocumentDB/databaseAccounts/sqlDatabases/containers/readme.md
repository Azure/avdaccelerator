# DocumentDB Database Account SQL Databases Containers `[Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers]`

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers` | 2021-07-01-preview |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `databaseAccountName` | string | Name of the Database Account |
| `name` | string | Name of the container. |
| `sqlDatabaseName` | string | Name of the SQL Database  |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `kind` | string | `'Hash'` | `[Hash, MultiHash, Range]` | Indicates the kind of algorithm used for partitioning |
| `paths` | array | `[]` |  | List of paths using which data within the container can be partitioned |
| `tags` | object | `{object}` |  | Tags of the SQL Database resource. |
| `throughput` | int | `400` |  | Request Units per second |


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
| `name` | string | The name of the container. |
| `resourceGroupName` | string | The name of the resource group the container was created in. |
| `resourceId` | string | The resource ID of the container. |

## Template references

- [Databaseaccounts/Sqldatabases/Containers](https://docs.microsoft.com/en-us/azure/templates/Microsoft.DocumentDB/2021-07-01-preview/databaseAccounts/sqlDatabases/containers)
