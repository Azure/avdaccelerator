# SQL Managed Instances Database `[Microsoft.Sql/managedInstances/databases]`

This template deploys a SQL Managed Instances Database.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | 2017-04-01 |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview |
| `Microsoft.Sql/managedInstances/databases` | 2021-05-01-preview |
| `Microsoft.Sql/managedInstances/databases/backupLongTermRetentionPolicies` | 2021-02-01-preview |
| `Microsoft.Sql/managedInstances/databases/backupShortTermRetentionPolicies` | 2017-03-01-preview |

### Deployment prerequisites

The SQL Managed Instance Database is deployed on a SQL Managed Instance.

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `managedInstanceName` | string | The name of the SQL managed instance. |
| `name` | string | The name of the SQL managed instance database. |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `backupLongTermRetentionPoliciesObj` | _[backupLongTermRetentionPolicies](backupLongTermRetentionPolicies/readme.md)_ object | `{object}` |  | The configuration for the backup long term retention policy definition |
| `backupShortTermRetentionPoliciesObj` | _[backupShortTermRetentionPolicies](backupShortTermRetentionPolicies/readme.md)_ object | `{object}` |  | The configuration for the backup short term retention policy definition |
| `catalogCollation` | string | `'SQL_Latin1_General_CP1_CI_AS'` |  | Collation of the managed instance. |
| `collation` | string | `'SQL_Latin1_General_CP1_CI_AS'` |  | Collation of the managed instance database. |
| `createMode` | string | `'Default'` | `[Default, RestoreExternalBackup, PointInTimeRestore, Recovery, RestoreLongTermRetentionBackup]` | Managed database create mode. PointInTimeRestore: Create a database by restoring a point in time backup of an existing database. SourceDatabaseName, SourceManagedInstanceName and PointInTime must be specified. RestoreExternalBackup: Create a database by restoring from external backup files. Collation, StorageContainerUri and StorageContainerSasToken must be specified. Recovery: Creates a database by restoring a geo-replicated backup. RecoverableDatabaseId must be specified as the recoverable database resource ID to restore. |
| `diagnosticEventHubAuthorizationRuleId` | string | `''` |  | Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| `diagnosticEventHubName` | string | `''` |  | Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. |
| `diagnosticLogCategoriesToEnable` | array | `[SQLInsights, QueryStoreRuntimeStatistics, QueryStoreWaitStatistics, Errors]` | `[SQLInsights, QueryStoreRuntimeStatistics, QueryStoreWaitStatistics, Errors]` | The name of logs that will be streamed. |
| `diagnosticLogsRetentionInDays` | int | `365` |  | Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely. |
| `diagnosticSettingsName` | string | `[format('{0}-diagnosticSettings', parameters('name'))]` |  | The name of the diagnostic setting, if deployed. |
| `diagnosticStorageAccountId` | string | `''` |  | Resource ID of the diagnostic storage account. |
| `diagnosticWorkspaceId` | string | `''` |  | Resource ID of the diagnostic log analytics workspace. |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `location` | string | `[resourceGroup().location]` |  | Location for all resources. |
| `lock` | string | `'NotSpecified'` | `[CanNotDelete, NotSpecified, ReadOnly]` | Specify the type of lock. |
| `longTermRetentionBackupResourceId` | string | `''` |  | Conditional. The name of the Long Term Retention backup to be used for restore of this managed database. |
| `recoverableDatabaseId` | string | `''` |  | Conditional. The resource identifier of the recoverable database associated with create operation of this database. |
| `restorableDroppedDatabaseId` | string | `''` |  | Conditional. The restorable dropped database resource ID to restore when creating this database. |
| `restorePointInTime` | string | `''` |  | Conditional. If createMode is PointInTimeRestore, this value is required. Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database. |
| `sourceDatabaseId` | string | `''` |  | Conditional. The resource identifier of the source database associated with create operation of this database. |
| `storageContainerSasToken` | string | `''` |  | Conditional. If createMode is RestoreExternalBackup, this value is required. Specifies the storage container sas token. |
| `storageContainerUri` | string | `''` |  | Conditional. If createMode is RestoreExternalBackup, this value is required. Specifies the uri of the storage container where backups for this restore are stored. |
| `tags` | object | `{object}` |  | Tags of the resource. |


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
| `name` | string | The name of the deployed database |
| `resourceGroupName` | string | The resource group the database was deployed into |
| `resourceId` | string | The resource ID of the deployed database |

## Template references

- [Diagnosticsettings](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)
- [Locks](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2017-04-01/locks)
- [Managedinstances/Databases](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Sql/2021-05-01-preview/managedInstances/databases)
- [Managedinstances/Databases/Backuplongtermretentionpolicies](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Sql/2021-02-01-preview/managedInstances/databases/backupLongTermRetentionPolicies)
- [Managedinstances/Databases/Backupshorttermretentionpolicies](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Sql/2017-03-01-preview/managedInstances/databases/backupShortTermRetentionPolicies)
