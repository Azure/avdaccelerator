# Load Balancers Backend Address Pools `[Microsoft.Network/loadBalancers/backendAddressPools]`

This module deploys load balancer backend address pools.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/loadBalancers/backendAddressPools` | 2021-05-01 |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `loadBalancerName` | string | The name of the parent load balancer |
| `name` | string | The name of the backend address pool |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `loadBalancerBackendAddresses` | array | `[]` | An array of backend addresses. |
| `tunnelInterfaces` | array | `[]` | An array of gateway load balancer tunnel interfaces. |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the backend address pool |
| `resourceGroupName` | string | The resource group the backend address pool was deployed into |
| `resourceId` | string | The resource ID of the backend address pool |

## Template references

- [Loadbalancers/Backendaddresspools](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-05-01/loadBalancers/backendAddressPools)
