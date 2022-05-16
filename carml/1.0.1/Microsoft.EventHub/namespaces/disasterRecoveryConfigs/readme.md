# EventHub Namespace Disaster Recovery Config `[Microsoft.EventHub/namespaces/disasterRecoveryConfigs]`

This module deploys an EventHub Namespace Disaster Recovery Config

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.EventHub/namespaces/disasterRecoveryConfigs` | 2017-04-01 |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the disaster recovery config |
| `namespaceName` | string | The name of the event hub namespace |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `partnerNamespaceId` | string | `''` | Resource ID of the Primary/Secondary event hub namespace name, which is part of GEO DR pairing |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the disaster recovery config. |
| `resourceGroupName` | string | The name of the resource group the disaster recovery config was created in. |
| `resourceId` | string | The resource ID of the disaster recovery config. |

## Template references

- [Namespaces/Disasterrecoveryconfigs](https://docs.microsoft.com/en-us/azure/templates/Microsoft.EventHub/2017-04-01/namespaces/disasterRecoveryConfigs)
