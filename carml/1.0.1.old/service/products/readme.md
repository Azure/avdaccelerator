# API Management Service Products `[Microsoft.ApiManagement/service/products]`

This module deploys API Management Service Products.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.ApiManagement/service/products` | 2021-08-01 |
| `Microsoft.ApiManagement/service/products/apis` | 2021-08-01 |
| `Microsoft.ApiManagement/service/products/groups` | 2021-08-01 |

### Resource dependency

The following resources are required to be able to deploy this resource.

- `Microsoft.ApiManagement/service`

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `apiManagementServiceName` | string | The name of the of the API Management service. |
| `name` | string | Product Name. |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `apis` | _[apis](apis/readme.md)_ array | `[]` | Array of Product APIs. |
| `approvalRequired` | bool | `False` | Whether subscription approval is required. If false, new subscriptions will be approved automatically enabling developers to call the products APIs immediately after subscribing. If true, administrators must manually approve the subscription before the developer can any of the products APIs. Can be present only if subscriptionRequired property is present and has a value of false. |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `groups` | _[groups](groups/readme.md)_ array | `[]` | Array of Product Groups. |
| `productDescription` | string | `''` | Product description. May include HTML formatting tags. |
| `state` | string | `'published'` | whether product is published or not. Published products are discoverable by users of developer portal. Non published products are visible only to administrators. Default state of Product is notPublished. - notPublished or published |
| `subscriptionRequired` | bool | `False` | Whether a product subscription is required for accessing APIs included in this product. If true, the product is referred to as "protected" and a valid subscription key is required for a request to an API included in the product to succeed. If false, the product is referred to as "open" and requests to an API included in the product can be made without a subscription key. If property is omitted when creating a new product it's value is assumed to be true. |
| `subscriptionsLimit` | int | `1` | Whether the number of subscriptions a user can have to this product at the same time. Set to null or omit to allow unlimited per user subscriptions. Can be present only if subscriptionRequired property is present and has a value of false. |
| `terms` | string | `''` | Product terms of use. Developers trying to subscribe to the product will be presented and required to accept these terms before they can complete the subscription process. |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `apiResourceIds` | array | The Resources IDs of the API management service product APIs |
| `groupResourceIds` | array | The Resources IDs of the API management service product groups |
| `name` | string | The name of the API management service product |
| `resourceGroupName` | string | The resource group the API management service product was deployed into |
| `resourceId` | string | The resource ID of the API management service product |

## Template references

- [Service/Products](https://docs.microsoft.com/en-us/azure/templates/Microsoft.ApiManagement/2021-08-01/service/products)
- [Service/Products/Apis](https://docs.microsoft.com/en-us/azure/templates/Microsoft.ApiManagement/2021-08-01/service/products/apis)
- [Service/Products/Groups](https://docs.microsoft.com/en-us/azure/templates/Microsoft.ApiManagement/2021-08-01/service/products/groups)
