# Budgets `[Microsoft.Consumption/budgets]`

This module deploys budgets for subscriptions.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Deployment examples](#Deployment-examples)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Consumption/budgets` | [2019-05-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Consumption/2019-05-01/budgets) |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `amount` | int | The total amount of cost or usage to track with the budget. |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `actionGroups` | array | `[]` |  | List of action group resource IDs that will receive the alert. |
| `category` | string | `'Cost'` | `[Cost, Usage]` | The category of the budget, whether the budget tracks cost or usage. |
| `contactEmails` | array | `[]` |  | The list of email addresses to send the budget notification to when the thresholds are exceeded. |
| `contactRoles` | array | `[]` |  | The list of contact roles to send the budget notification to when the thresholds are exceeded. |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `endDate` | string | `''` |  | The end date for the budget. If not provided, it will default to 10 years from the start date. |
| `location` | string | `[deployment().location]` |  | Location deployment metadata. |
| `name` | string | `''` |  | The name of the budget. |
| `resetPeriod` | string | `'Monthly'` | `[Annually, BillingAnnual, BillingMonth, BillingQuarter, Monthly, Quarterly]` | The time covered by a budget. Tracking of the amount will be reset based on the time grain. BillingMonth, BillingQuarter, and BillingAnnual are only supported by WD customers. |
| `startDate` | string | `[format('{0}-{1}-01T00:00:00Z', utcNow('yyyy'), utcNow('MM'))]` |  | The start date for the budget. Start date should be the first day of the month and cannot be in the past (except for the current month). |
| `thresholds` | array | `[50, 75, 90, 100, 110]` |  | Percent thresholds of budget for when to get a notification. Can be up to 5 thresholds, where each must be between 1 and 1000. |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the budget. |
| `resourceId` | string | The resource ID of the budget. |
| `subscriptionName` | string | The subscription the budget was deployed into. |

## Cross-referenced modules

_None_

## Deployment examples

The following module usage examples are retrieved from the content of the files hosted in the module's `.test` folder.
   >**Note**: The name of each example is based on the name of the file from which it is taken.
   >**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

<h3>Example 1: Parameters</h3>

<details>

<summary>via Bicep module</summary>

```bicep
module budgets './Microsoft.Consumption/budgets/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-budgets'
  params: {
    // Required parameters
    amount: 500
    // Non-required parameters
    contactEmails: [
      'dummy@contoso.com'
    ]
    thresholds: [
      50
      75
      90
      100
      110
    ]
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "amount": {
      "value": 500
    },
    // Non-required parameters
    "contactEmails": {
      "value": [
        "dummy@contoso.com"
      ]
    },
    "thresholds": {
      "value": [
        50,
        75,
        90,
        100,
        110
      ]
    }
  }
}
```

</details>
<p>
