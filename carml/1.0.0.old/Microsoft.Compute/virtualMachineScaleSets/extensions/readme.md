# virtual machine scale set Extensions `[Microsoft.Compute/virtualMachineScaleSets/extensions]`

This module deploys a virtual machine scale set extension.

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Compute/virtualMachineScaleSets/extensions` | 2021-07-01 |

## Parameters

| Parameter Name | Type | Default Value | Possible Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `autoUpgradeMinorVersion` | bool |  |  | Required. Indicates whether the extension should use a newer minor version if one is available at deployment time. Once deployed, however, the extension will not upgrade minor versions unless redeployed, even with this property set to true |
| `cuaId` | string |  |  | Optional. Customer Usage Attribution id (GUID). This GUID must be previously registered |
| `enableAutomaticUpgrade` | bool |  |  | Required. Indicates whether the extension should be automatically upgraded by the platform if there is a newer version of the extension available |
| `forceUpdateTag` | string |  |  | Optional. How the extension handler should be forced to update even if the extension configuration has not changed |
| `name` | string |  |  | Required. The name of the virtual machine scale set extension |
| `protectedSettings` | secureObject | `{object}` |  | Optional. Any object that contains the extension specific protected settings |
| `publisher` | string |  |  | Required. The name of the extension handler publisher |
| `settings` | object | `{object}` |  | Optional. Any object that contains the extension specific settings |
| `supressFailures` | bool |  |  | Optional. Indicates whether failures stemming from the extension will be suppressed (Operational failures such as not connecting to the VM will not be suppressed regardless of this value). The default is false |
| `type` | string |  |  | Required. Specifies the type of the extension; an example is "CustomScriptExtension" |
| `typeHandlerVersion` | string |  |  | Required. Specifies the version of the script handler |
| `virtualMachineScaleSetName` | string |  |  | Required. The name of the virtual machine scale set that extension is provisioned for |

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the extension |
| `resourceGroupName` | string | The name of the Resource Group the extension was created in. |
| `resourceId` | string | The ResourceId of the extension |

## Template references

- [Virtualmachinescalesets/Extensions](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Compute/2021-07-01/virtualMachineScaleSets/extensions)
