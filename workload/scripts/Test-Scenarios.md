# Test Scenarios for SKU Zone Availability Validator

This document provides example scenarios for testing the SKU Zone Availability Validator.

## Prerequisites

Before running these tests, ensure:
1. Azure PowerShell module is installed (`Az.Compute`)
2. You are authenticated to Azure (`Connect-AzAccount`)
3. You have read permissions on the target subscription

## Test Scenarios

### Scenario 1: Basic SKU Validation (Successful)

Test if a commonly available SKU is present in a region.

**Command:**
```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-subscription-id" `
    -Location "eastus" `
    -VmSize "Standard_D4s_v3"
```

**Expected Result:**
- Status: SUCCESS
- SKU Available: Yes
- Available Zones: Listed (if supported)
- Quota increase link provided

### Scenario 2: SKU with Zone Validation (Successful)

Test if a SKU is available in specific zones.

**Command:**
```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-subscription-id" `
    -Location "eastus" `
    -VmSize "Standard_D4ads_v5" `
    -Zones @('1','2','3')
```

**Expected Result:**
- Status: SUCCESS
- SKU Available: Yes
- Zone 1: Available
- Zone 2: Available
- Zone 3: Available

### Scenario 3: SKU Not Available in Region (Failed)

Test with a SKU that doesn't exist or is not available in the region.

**Command:**
```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-subscription-id" `
    -Location "eastus" `
    -VmSize "Standard_InvalidSku_v99" `
    -SuggestAlternatives
```

**Expected Result:**
- Status: FAILED
- SKU Available: No
- Error message: "SKU 'Standard_InvalidSku_v99' is not available in region 'eastus'"
- No alternative SKUs found (or similar SKUs suggested)

### Scenario 4: SKU Available but Not in All Zones (Partial)

Test with a SKU that exists but may not be available in all zones.

**Command:**
```powershell
# Some regions may have zone restrictions for certain SKUs
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-subscription-id" `
    -Location "centralus" `
    -VmSize "Standard_D2s_v3" `
    -Zones @('1','2','3')
```

**Expected Result:**
- Status: SUCCESS or PARTIAL (depending on actual availability)
- SKU Available: Yes
- Zone validation results for each zone
- Warning if not all zones are available

### Scenario 5: SKU Without Zone Support

Test with a SKU that doesn't support availability zones.

**Command:**
```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-subscription-id" `
    -Location "westus" `
    -VmSize "Standard_A2_v2"
```

**Expected Result:**
- Status: SUCCESS
- SKU Available: Yes
- Zone Support: Not available (No infrastructure redundancy)

### Scenario 6: Alternative SKU Suggestions

Test the alternative SKU suggestion feature.

**Command:**
```powershell
.\Test-AvdSkuZoneAvailability.ps1 `
    -SubscriptionId "your-subscription-id" `
    -Location "eastus" `
    -VmSize "Standard_D16ads_v5" `
    -SuggestAlternatives
```

**Expected Result:**
- Status: SUCCESS or FAILED (depending on availability)
- If available: Validation details
- If not available: List of similar alternative SKUs with zone information

## Testing Portal UI Integration

### Test 1: Baseline Deployment Portal UI

1. Navigate to Azure Portal
2. Use the "Deploy to Azure" button for baseline deployment
3. Go through the deployment wizard
4. On the "Session Hosts" step:
   - Select a region
   - Choose a VM size
   - Observe the availability zones dropdown is dynamically filtered
   - Note the SKU/Zone validation info box
   - Note the quota increase info box

**Expected Behavior:**
- Zones dropdown only shows zones compatible with selected SKU
- Information boxes appear with helpful guidance
- Links to validator documentation and quota increase are present

### Test 2: Brownfield New Session Hosts Portal UI

1. Navigate to Azure Portal
2. Use the "Deploy to Azure" button for new session hosts
3. Follow wizard to session hosts configuration
4. Select region and VM size
5. Observe availability section

**Expected Behavior:**
- Dynamic zone filtering based on SKU
- Information boxes with validation guidance
- Quota increase links available

## Automated Testing (PowerShell)

To run basic syntax and structure validation:

```powershell
# Test 1: Check script exists and has valid syntax
$scriptPath = ".\Test-AvdSkuZoneAvailability.ps1"
if (Test-Path $scriptPath) {
    Write-Host "✓ Script file exists" -ForegroundColor Green
} else {
    Write-Host "✗ Script file not found" -ForegroundColor Red
    exit 1
}

# Test 2: Validate script can be loaded
try {
    $null = Get-Command $scriptPath -ErrorAction Stop
    Write-Host "✓ Script syntax is valid" -ForegroundColor Green
} catch {
    Write-Host "✗ Script syntax error: $_" -ForegroundColor Red
    exit 1
}

# Test 3: Check script has expected parameters
$params = (Get-Command $scriptPath).Parameters.Keys
$expectedParams = @('SubscriptionId', 'Location', 'VmSize', 'Zones', 'SuggestAlternatives')
$expectedParams | ForEach-Object {
    if ($params -contains $_) {
        Write-Host "✓ Parameter $_ exists" -ForegroundColor Green
    } else {
        Write-Host "✗ Parameter $_ missing" -ForegroundColor Red
    }
}

# Test 4: Validate help content exists
$help = Get-Help $scriptPath
if ($help.Synopsis -and $help.Synopsis.Trim()) {
    Write-Host "✓ Help documentation exists and has content" -ForegroundColor Green
} else {
    Write-Host "✗ Help documentation missing or empty" -ForegroundColor Red
}
```

## Integration Testing Checklist

- [ ] Script executes without syntax errors
- [ ] Script validates parameters correctly
- [ ] Script handles invalid subscription ID gracefully
- [ ] Script handles invalid region name gracefully
- [ ] Script handles invalid SKU name gracefully
- [ ] Script returns structured output
- [ ] Alternative SKU suggestion works
- [ ] Quota increase URL is generated correctly
- [ ] Portal UI shows validation info boxes
- [ ] Portal UI zone filtering works dynamically
- [ ] Documentation links in portal UI are accessible
- [ ] Quota increase links in portal UI work correctly

## Success Criteria

The implementation is successful if:

1. **Functional Requirements:**
   - Script successfully validates SKU availability
   - Script correctly identifies available zones
   - Script detects zone restrictions
   - Script suggests alternative SKUs when requested
   - Script provides quota increase links

2. **User Experience:**
   - Portal UI provides clear guidance
   - Information is presented at the right time in wizard
   - Links to documentation and support are accessible
   - Error messages are clear and actionable

3. **Documentation:**
   - README provides clear usage instructions
   - Examples cover common scenarios
   - Troubleshooting guide is updated
   - Main repository README references the feature

## Known Limitations

1. **Quota Validation:**
   - Script does not directly query subscription quota limits
   - Users must manually check quota through Azure portal or API

2. **Real-time Availability:**
   - SKU availability is queried at runtime but doesn't reflect real-time capacity
   - Capacity issues may still cause deployment failures even if SKU is "available"

3. **Portal UI:**
   - Zone filtering is client-side only
   - No server-side pre-deployment validation beyond standard ARM validation

4. **Regional Variations:**
   - SKU availability varies by region and changes over time
   - Documentation should be updated periodically

## Support and Troubleshooting

If tests fail:

1. Verify Azure PowerShell module version: `Get-Module -Name Az.Compute -ListAvailable`
2. Check authentication: `Get-AzContext`
3. Verify subscription access: `Get-AzSubscription`
4. Check region name format: Use `Get-AzLocation` for valid names
5. Review error messages in script output
6. Check Azure service health for regional issues

For additional support, refer to:
- [SKU Zone Validator README](./SkuZoneValidator-Readme.md)
- [Baseline Troubleshooting Guide](../docs/baseline-troubleshooting-guide.md)
- [GitHub Issues](https://github.com/Azure/avdaccelerator/issues)
