# Quick Start: SKU Zone Validator

## For Portal UI Users

### Using the Baseline Deployment Wizard

1. Click **Deploy to Azure** button in the [main README](../readme.md)
2. Follow the wizard to the **Session Hosts** step
3. Select your region and VM size
4. Look for the **information boxes** that appear:
   - **"SKU and Zone Validation"** - Explains zone filtering and provides guidance
   - **"Need more quota?"** - Link to request quota increase

The zones dropdown will **automatically filter** to show only zones where your selected VM size is available.

### If You Encounter Issues

**Scenario: No zones appear or deployment fails**

1. Check the SKU validation info box for guidance
2. Try a different VM size from the dropdown
3. Use the PowerShell validator (see below) to check availability
4. Request quota increase using the provided link

## For PowerShell Users

### Prerequisites

```powershell
# Install Azure PowerShell if not already installed
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Connect to Azure
Connect-AzAccount
```

### Basic Validation

Check if a VM size is available in your region:

```powershell
cd workload/scripts

.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -Location "eastus" `
    -VmSize "Standard_D4ads_v5"
```

### Validate Specific Zones

Check if a VM size is available in specific zones:

```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -Location "eastus" `
    -VmSize "Standard_D4ads_v5" `
    -Zones @('1','2','3')
```

### Get Alternative Recommendations

If your preferred SKU isn't available, find similar alternatives:

```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -Location "eastus" `
    -VmSize "Standard_D4ads_v5" `
    -SuggestAlternatives
```

## Common Scenarios

### Scenario 1: Planning a New Deployment

**Before starting the deployment:**

```powershell
# Validate your chosen SKU
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-sub-id" `
    -Location "westus2" `
    -VmSize "Standard_D8ads_v5" `
    -Zones @('1','2','3')
```

**Expected Output:**
- ✅ SKU Available: Yes
- ✅ Zones 1, 2, 3: Available
- Link to request quota increase

**Action:** Proceed with deployment using Portal UI

### Scenario 2: Deployment Failed - SKU Not Available

**Problem:** Portal deployment failed with "SKU not available" error

**Solution:**

```powershell
# Check alternatives
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-sub-id" `
    -Location "westus2" `
    -VmSize "Standard_D8ads_v5" `
    -SuggestAlternatives
```

**Expected Output:**
- List of similar SKUs (e.g., Standard_D8s_v4, Standard_D8ds_v5)
- Zone availability for each alternative

**Action:** Retry deployment with an available SKU

### Scenario 3: Deployment Failed - Quota Exceeded

**Problem:** Deployment failed with "quota exceeded" error

**Solution:**

1. Run validator to confirm SKU availability:
   ```powershell
   .\Test-AvdSkuZoneAvailability.ps1 `
       -SubscriptionId "your-sub-id" `
       -Location "eastus" `
       -VmSize "Standard_D4ads_v5"
   ```

2. Click the quota increase link provided in the output

3. Submit quota increase request with:
   - VM Series: D-Series
   - Region: East US
   - New vCPU limit: (calculate: VM size × number of VMs)

4. Wait for approval (typically hours to days)

5. Retry deployment

### Scenario 4: Multi-Region Planning

**Need:** Deploy AVD across multiple regions for DR

**Approach:**

```powershell
# Check primary region
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-sub-id" `
    -Location "eastus" `
    -VmSize "Standard_D4ads_v5"

# Check DR region
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-sub-id" `
    -Location "westus" `
    -VmSize "Standard_D4ads_v5"
```

**Action:** Ensure SKU is available in both regions before proceeding

## Best Practices

### Before Every Deployment

1. ✅ Run the validator with your target configuration
2. ✅ Verify zones match your requirements
3. ✅ Check quota is sufficient
4. ✅ Identify 2-3 alternative SKUs as backup

### For Production Deployments

1. ✅ Test in non-production first
2. ✅ Document your SKU selection rationale
3. ✅ Request quota ahead of time (don't wait for failures)
4. ✅ Plan for zone redundancy

### For Cost Optimization

1. ✅ Use validator to compare SKU availability across regions
2. ✅ Consider regions with broader SKU availability
3. ✅ Balance cost vs. availability zones (zones cost the same but provide better SLA)

## Troubleshooting

### Error: "Unable to retrieve SKU information"

**Cause:** Invalid region name or permissions issue

**Fix:**
```powershell
# Get valid region names
Get-AzLocation | Select-Object Location, DisplayName

# Use the "Location" value (lowercase, no spaces)
```

### Error: "SKU not found in region"

**Cause:** SKU doesn't exist or is not available in that region

**Fix:**
```powershell
# Use SuggestAlternatives flag
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-sub-id" `
    -Location "eastus" `
    -VmSize "Standard_D4ads_v5" `
    -SuggestAlternatives

# Or try a different region
```

### Warning: "Some requested zones are not available"

**Cause:** SKU exists but not in all zones

**Fix:**
- Review which zones are available in the output
- Adjust your zone selection to match available zones
- Or select a different SKU that supports all zones

## Getting Help

### Documentation
- [SKU Zone Validator README](./SkuZoneValidator-Readme.md) - Full documentation
- [Test Scenarios](./Test-Scenarios.md) - Detailed test cases
- [Troubleshooting Guide](../docs/baseline-troubleshooting-guide.md) - Common issues

### Support
- [GitHub Issues](https://github.com/Azure/avdaccelerator/issues) - Report bugs or request features
- [Azure Support](https://azure.microsoft.com/support/) - Quota increases and Azure-specific issues
- [AVD Documentation](https://docs.microsoft.com/azure/virtual-desktop/) - General AVD guidance

## Next Steps

1. **Familiarize** yourself with the validator
2. **Test** with your subscription and regions
3. **Integrate** into your deployment workflow
4. **Share** with your team

Happy deploying! 🚀
