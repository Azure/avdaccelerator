# Service Bus Namespace Disaster Recovery Config `[Microsoft.ServiceBus/namespaces/disasterRecoveryConfigs]`

This module deploys a disaster recovery config for a service bus Namespace

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.ServiceBus/namespaces/disasterRecoveryConfigs` | 2017-04-01 |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `namespaceName` | string | Name of the parent Service Bus Namespace for the Service Bus Queue. |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `alternateName` | string | `''` | Primary/Secondary eventhub namespace name, which is part of GEO DR pairing |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `name` | string | `'default'` | The name of the disaster recovery config |
| `partnerNamespaceResourceID` | string | `''` | Resource ID of the Primary/Secondary event hub namespace name, which is part of GEO DR pairing |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the disaster recovery config. |
| `resourceGroupName` | string | The name of the Resource Group the disaster recovery config was created in. |
| `resourceId` | string | The Resource ID of the disaster recovery config. |

## Template references

- [Namespaces/Disasterrecoveryconfigs](https://docs.microsoft.com/en-us/azure/templates/Microsoft.ServiceBus/2017-04-01/namespaces/disasterRecoveryConfigs)
