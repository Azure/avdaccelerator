# API Management Service Portal Settings `[Microsoft.ApiManagement/service/portalsettings]`

This module deploys API Management Service Portal Setting.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.ApiManagement/service/portalsettings` | 2021-08-01 |

## Parameters

**Required parameters**
| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `apiManagementServiceName` | string |  | The name of the of the API Management service. |
| `name` | string | `[delegation, signin, signup]` | Portal setting name |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `properties` | object | `{object}` | Portal setting properties. |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the API management service portal setting |
| `resourceGroupName` | string | The resource group the API management service portal setting was deployed into |
| `resourceId` | string | The resource ID of the API management service portal setting |

## Template references

- ['service/portalsettings' Parent Documentation](https://docs.microsoft.com/en-us/azure/templates/Microsoft.ApiManagement/service)
