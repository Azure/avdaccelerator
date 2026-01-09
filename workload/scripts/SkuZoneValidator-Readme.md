# SKU Zone Availability Validator

## Overview

The SKU Zone Availability Validator is a PowerShell script that validates Azure VM SKU availability and quota for Azure Virtual Desktop (AVD) deployments. It helps prevent deployment failures by checking SKU and zone availability before provisioning resources.

## Purpose

This validator addresses common deployment failures caused by:
- **SKU absence** in a particular region
- **Zone unavailability** for a specific SKU
- **Insufficient quota** in the target region/zone

By running this validation before deployment, you can:
- Verify SKU availability in your target region
- Confirm zone support for your chosen SKU
- Identify compatible zones
- Get recommendations for alternative SKUs
- Access quota increase workflow links

## Prerequisites

- Azure PowerShell module (`Az.Compute`)
- Azure subscription access
- Appropriate permissions to query Azure resources

### Installing Azure PowerShell

```powershell
Install-Module -Name Az -AllowClobber -Scope CurrentUser
```

## Usage

### Basic Validation

Check if a SKU is available in a region:

```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-subscription-id" `
    -Location "eastus" `
    -VmSize "Standard_D4ads_v5"
```

### Validate Specific Zones

Check if a SKU is available in specific availability zones:

```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-subscription-id" `
    -Location "eastus" `
    -VmSize "Standard_D4ads_v5" `
    -Zones @('1','2','3')
```

### Get Alternative SKU Suggestions

If the requested SKU is not available, get suggestions for similar SKUs:

```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-subscription-id" `
    -Location "eastus" `
    -VmSize "Standard_D4ads_v5" `
    -SuggestAlternatives
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `SubscriptionId` | Yes | Azure subscription ID where deployment will occur |
| `Location` | Yes | Azure region for session hosts (e.g., 'eastus', 'westeurope') |
| `VmSize` | Yes | VM SKU size to validate (e.g., 'Standard_D4ads_v5') |
| `Zones` | No | Array of availability zones to validate (e.g., @('1','2','3')) |
| `SuggestAlternatives` | No | Switch to suggest alternative similar SKUs if not available |

## Output

The script provides:

1. **SKU Availability Status** - Whether the SKU exists in the region
2. **Zone Information** - Available zones for the SKU
3. **Zone Validation** - Validation results for requested zones
4. **Restrictions** - Any location or zone restrictions
5. **Alternative SKUs** - Suggestions if original SKU is unavailable (with `-SuggestAlternatives`)
6. **Quota Increase Link** - Direct link to request quota increase

### Example Output

```
========================================
SKU Zone Availability Validator
========================================

Setting subscription context: xxxx-xxxx-xxxx-xxxx
Querying available SKUs in region: eastus
Target VM Size: Standard_D4ads_v5
Found 428 VM SKUs in region

SKU Validation Results:
  SKU Name: Standard_D4ads_v5
  Region: eastus
  SKU Available: Yes
  Available Zones: 1, 2, 3

  Validating Requested Zones:
    Zone 1: Available
    Zone 2: Available
    Zone 3: Available

  Quota Information:
    To request quota increase, visit:
    https://portal.azure.com/#view/Microsoft_Azure_Support/...

========================================
Validation Status: SUCCESS
========================================
```

## Integration with Portal UI

The validator logic is also integrated into the Azure portal UI definitions:

- **Baseline Deployment** (`portal-ui-baseline.json`)
  - Automatically filters available zones based on SKU selection
  - Shows enhanced validation messages
  - Provides quota increase links

- **Brownfield New Session Hosts** (`portalUiNewSessionHosts.json`)
  - Dynamic zone validation
  - SKU compatibility checks

## Best Practices

1. **Run Before Deployment** - Always validate SKU availability before starting a deployment
2. **Check All Zones** - If using availability zones, validate all intended zones
3. **Alternative Planning** - Use `-SuggestAlternatives` to have backup SKU options
4. **Quota Planning** - Check quota requirements early and request increases if needed
5. **Region Selection** - Consider multiple regions if primary region has limitations

## Troubleshooting

### Common Issues

**"Unable to retrieve SKU information"**
- Verify the region name is correct (use `Get-AzLocation` to list valid regions)
- Check Azure PowerShell module is up to date
- Ensure you have permissions to query compute resources

**"SKU not found in region"**
- The SKU may not be available in that region
- Use `-SuggestAlternatives` to find similar SKUs
- Consider a different region

**"Some requested zones are not available"**
- The SKU may only support certain zones
- Review the available zones in the output
- Adjust zone selection to match available zones

## Related Resources

- [Azure Virtual Desktop Documentation](https://docs.microsoft.com/azure/virtual-desktop/)
- [Azure VM Sizes](https://docs.microsoft.com/azure/virtual-machines/sizes)
- [Availability Zones](https://docs.microsoft.com/azure/availability-zones/az-overview)
- [Quota Management](https://docs.microsoft.com/azure/azure-portal/supportability/regional-quota-requests)

## Support

For issues or questions:
- Open an issue on the [AVD Accelerator GitHub repository](https://github.com/Azure/avdaccelerator/issues)
- Review the [troubleshooting guide](../docs/baseline-troubleshooting-guide.md)
