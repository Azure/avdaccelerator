# AVD Applications `[Microsoft.DesktopVirtualization/applicationGroups/applications]`

This module deploys AVD Applications.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.DesktopVirtualization/applicationGroups/applications` | 2021-07-12 |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `appGroupName` | string | Name of the Application Group to create the application(s) in. |
| `filePath` | string | Specifies a path for the executable file for the application. |
| `friendlyName` | string | Friendly name of Application.. |
| `name` | string | Name of the Application to be created in the Application Group. |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `commandLineArguments` | string | `''` |  | Command-Line Arguments for Application. |
| `commandLineSetting` | string | `'DoNotAllow'` | `[Allow, DoNotAllow, Require]` | Specifies whether this published application can be launched with command-line arguments provided by the client, command-line arguments specified at publish time, or no command-line arguments at all. |
| `description` | string | `''` |  | Description of Application.. |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `iconIndex` | int | `0` |  | Index of the icon. |
| `iconPath` | string | `''` |  | Path to icon. |
| `showInPortal` | bool | `False` |  | Specifies whether to show the RemoteApp program in the RD Web Access server. |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `applicationResourceIds` | string | The resource ID of the deployed Application. |
| `name` | string | The Name of the Application Group to register the Application in. |
| `resourceGroupName` | string | The name of the Resource Group the AVD Application was created in. |

## Template references

- [Applicationgroups/Applications](https://docs.microsoft.com/en-us/azure/templates/Microsoft.DesktopVirtualization/2021-07-12/applicationGroups/applications)
