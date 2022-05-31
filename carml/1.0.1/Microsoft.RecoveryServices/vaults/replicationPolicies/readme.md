# RecoveryServices Vaults ReplicationPolicies `[Microsoft.RecoveryServices/vaults/replicationPolicies]`

This module deploys a Replication Policy for Disaster Recovery scenario.

> **Note**: this version of the module only supports the `instanceType: 'A2A'` scenario.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.RecoveryServices/vaults/replicationPolicies` | 2021-12-01 |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the replication policy |
| `recoveryVaultName` | string | Name of the Azure Recovery Service Vault |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `appConsistentFrequencyInMinutes` | int | `60` |  | The app consistent snapshot frequency (in minutes). |
| `crashConsistentFrequencyInMinutes` | int | `5` |  | The crash consistent snapshot frequency (in minutes). |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `multiVmSyncStatus` | string | `'Enable'` | `[Enable, Disable]` | A value indicating whether multi-VM sync has to be enabled. |
| `recoveryPointHistory` | int | `1440` |  | The duration in minutes until which the recovery points need to be stored. |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the replication policy. |
| `resourceGroupName` | string | The name of the resource group the replication policy was created in. |
| `resourceId` | string | The resource ID of the replication policy. |

## Template references

- [Vaults/Replicationpolicies](https://docs.microsoft.com/en-us/azure/templates/Microsoft.RecoveryServices/2021-12-01/vaults/replicationPolicies)
