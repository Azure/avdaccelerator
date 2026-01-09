<#
.SYNOPSIS
    Validates Azure VM SKU availability and quota in specified regions and zones for AVD deployments.

.DESCRIPTION
    This script validates whether a specified VM SKU is available in the target region and zones.
    It checks:
    - SKU availability in the specified region
    - Zone-specific availability for the SKU
    - Available zones for the SKU
    - Suggests alternative SKUs if the requested SKU is not available
    - Provides quota increase link if needed

.PARAMETER SubscriptionId
    The Azure subscription ID where the deployment will occur.

.PARAMETER Location
    The Azure region where session hosts will be deployed (e.g., 'eastus', 'westeurope').

.PARAMETER VmSize
    The VM SKU size to validate (e.g., 'Standard_D4ads_v5', 'Standard_D8s_v3').

.PARAMETER Zones
    Optional array of availability zones to validate (e.g., @('1','2','3')).
    If not specified, all available zones will be checked.

.PARAMETER SuggestAlternatives
    If true, suggests alternative similar SKUs if the specified SKU is not available.

.EXAMPLE
    .\Test-AvdSkuZoneAvailability.ps1 -SubscriptionId "xxxx-xxxx-xxxx-xxxx" -Location "eastus" -VmSize "Standard_D4ads_v5"

.EXAMPLE
    .\Test-AvdSkuZoneAvailability.ps1 -SubscriptionId "xxxx-xxxx-xxxx-xxxx" -Location "eastus" -VmSize "Standard_D4ads_v5" -Zones @('1','2') -SuggestAlternatives

.NOTES
    Author: AVD Accelerator Team
    Version: 1.0.0
    
    This script requires:
    - Azure PowerShell module (Az.Compute)
    - Appropriate permissions to query Azure resources
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$VmSize,

    [Parameter(Mandatory = $false)]
    [string[]]$Zones,

    [Parameter(Mandatory = $false)]
    [switch]$SuggestAlternatives
)

#region Helper Functions

function Write-ValidationResult {
    param(
        [string]$Status,
        [string]$Message,
        [object]$Details = $null
    )
    
    $result = @{
        Status = $Status
        Message = $Message
        Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    }
    
    if ($Details) {
        $result.Details = $Details
    }
    
    return $result
}

function Get-SimilarSkus {
    param(
        [string]$VmSize,
        [array]$AvailableSkus
    )
    
    # Extract VM family and size characteristics
    $sizePattern = $VmSize -replace 'Standard_', ''
    $familyMatch = if ($sizePattern -match '^([A-Z]+\d+)') { $Matches[1] } else { '' }
    
    # Find similar SKUs (same family or similar vCPU count)
    $similarSkus = $AvailableSkus | Where-Object {
        $_.ResourceType -eq 'virtualMachines' -and
        $_.Name -like "*$familyMatch*" -and
        $_.Name -ne $VmSize
    } | Select-Object -First 5
    
    return $similarSkus
}

function Get-QuotaIncreaseUrl {
    param(
        [string]$SubscriptionId,
        [string]$Location,
        [string]$VmSize
    )
    
    $baseUrl = "https://portal.azure.com/#view/Microsoft_Azure_Support/NewSupportRequestV3Blade"
    $params = @(
        "issueType=quota"
        "subscriptionId=$SubscriptionId"
        "topicId=06bfd9d3-516b-d5c6-5802-169c800dec89"
    )
    
    return "$baseUrl`?" + ($params -join '&')
}

#endregion

#region Main Validation Logic

try {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "SKU Zone Availability Validator" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    # Set subscription context
    Write-Host "Setting subscription context: $SubscriptionId" -ForegroundColor Yellow
    $null = Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
    
    # Normalize location (remove spaces, convert to lowercase)
    $normalizedLocation = $Location.ToLower().Replace(' ', '')
    
    Write-Host "Querying available SKUs in region: $Location" -ForegroundColor Yellow
    Write-Host "Target VM Size: $VmSize" -ForegroundColor Yellow
    
    # Get all SKUs in the region
    $allSkus = Get-AzComputeResourceSku -Location $normalizedLocation | Where-Object { $_.ResourceType -eq 'virtualMachines' }
    
    if ($null -eq $allSkus -or $allSkus.Count -eq 0) {
        $result = Write-ValidationResult -Status "ERROR" -Message "Unable to retrieve SKU information for region: $Location. Please verify the region name is correct."
        Write-Host "`n$($result.Message)" -ForegroundColor Red
        return $result
    }
    
    Write-Host "Found $($allSkus.Count) VM SKUs in region" -ForegroundColor Green
    
    # Find the specific SKU
    $targetSku = $allSkus | Where-Object { $_.Name -eq $VmSize }
    
    if ($null -eq $targetSku) {
        Write-Host "`nERROR: SKU '$VmSize' not found in region '$Location'" -ForegroundColor Red
        
        $details = @{
            RequestedSku = $VmSize
            Region = $Location
            SkuAvailable = $false
        }
        
        if ($SuggestAlternatives) {
            Write-Host "`nSearching for alternative SKUs..." -ForegroundColor Yellow
            $alternatives = Get-SimilarSkus -VmSize $VmSize -AvailableSkus $allSkus
            
            if ($alternatives.Count -gt 0) {
                Write-Host "`nSuggested Alternative SKUs:" -ForegroundColor Cyan
                $alternativeList = @()
                foreach ($alt in $alternatives) {
                    $altZones = $alt.LocationInfo.Zones
                    $zoneInfo = if ($altZones) { "Zones: $($altZones -join ', ')" } else { "No zone support" }
                    Write-Host "  - $($alt.Name) ($zoneInfo)" -ForegroundColor White
                    $alternativeList += @{
                        Name = $alt.Name
                        Zones = $altZones
                    }
                }
                $details.AlternativeSkus = $alternativeList
            }
        }
        
        $result = Write-ValidationResult -Status "FAILED" -Message "SKU '$VmSize' is not available in region '$Location'" -Details $details
        Write-Host "`nValidation Result: FAILED" -ForegroundColor Red
        return $result
    }
    
    # Check for restrictions
    $restrictions = $targetSku.Restrictions
    if ($restrictions) {
        $locationRestrictions = $restrictions | Where-Object { $_.Type -eq 'Location' }
        if ($locationRestrictions) {
            Write-Host "`nWARNING: SKU has location restrictions" -ForegroundColor Yellow
            foreach ($restriction in $locationRestrictions) {
                Write-Host "  Reason: $($restriction.ReasonCode)" -ForegroundColor Yellow
            }
        }
    }
    
    # Get zone information
    $locationInfo = $targetSku.LocationInfo | Where-Object { $_.Location -eq $normalizedLocation }
    $availableZones = $locationInfo.Zones
    
    Write-Host "`nSKU Validation Results:" -ForegroundColor Cyan
    Write-Host "  SKU Name: $VmSize" -ForegroundColor White
    Write-Host "  Region: $Location" -ForegroundColor White
    Write-Host "  SKU Available: Yes" -ForegroundColor Green
    
    $validationStatus = "SUCCESS"
    $validationMessage = "SKU '$VmSize' is available in region '$Location'"
    
    $details = @{
        RequestedSku = $VmSize
        Region = $Location
        SkuAvailable = $true
        AvailableZones = @()
        RequestedZones = @()
        ZoneValidation = @()
    }
    
    if ($availableZones -and $availableZones.Count -gt 0) {
        Write-Host "  Available Zones: $($availableZones -join ', ')" -ForegroundColor Green
        $details.AvailableZones = $availableZones
        
        # Validate requested zones if specified
        if ($Zones -and $Zones.Count -gt 0) {
            Write-Host "`n  Validating Requested Zones:" -ForegroundColor Cyan
            $details.RequestedZones = $Zones
            
            $allZonesValid = $true
            foreach ($zone in $Zones) {
                $isValid = $availableZones -contains $zone
                $status = if ($isValid) { "Available" } else { "NOT Available"; $allZonesValid = $false }
                $color = if ($isValid) { "Green" } else { "Red" }
                Write-Host "    Zone $zone`: $status" -ForegroundColor $color
                
                $details.ZoneValidation += @{
                    Zone = $zone
                    Available = $isValid
                }
            }
            
            if (-not $allZonesValid) {
                $validationStatus = "PARTIAL"
                $validationMessage = "SKU '$VmSize' is available in region '$Location', but not in all requested zones"
                Write-Host "`nWARNING: Some requested zones are not available for this SKU" -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "  Zone Support: Not available (No infrastructure redundancy)" -ForegroundColor Yellow
        $validationMessage += " (no zone support available)"
    }
    
    # Check for zone restrictions
    if ($restrictions) {
        $zoneRestrictions = $restrictions | Where-Object { $_.Type -eq 'Zone' }
        if ($zoneRestrictions) {
            Write-Host "`n  WARNING: SKU has zone restrictions" -ForegroundColor Yellow
            foreach ($restriction in $zoneRestrictions) {
                Write-Host "    Reason: $($restriction.ReasonCode)" -ForegroundColor Yellow
                if ($restriction.RestrictionInfo.Zones) {
                    Write-Host "    Restricted Zones: $($restriction.RestrictionInfo.Zones -join ', ')" -ForegroundColor Yellow
                    $details.RestrictedZones = $restriction.RestrictionInfo.Zones
                }
            }
        }
    }
    
    # Provide quota increase link
    Write-Host "`n  Quota Information:" -ForegroundColor Cyan
    $quotaUrl = Get-QuotaIncreaseUrl -SubscriptionId $SubscriptionId -Location $Location -VmSize $VmSize
    Write-Host "    To request quota increase, visit:" -ForegroundColor White
    Write-Host "    $quotaUrl" -ForegroundColor Blue
    $details.QuotaIncreaseUrl = $quotaUrl
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Validation Status: $validationStatus" -ForegroundColor $(if ($validationStatus -eq "SUCCESS") { "Green" } elseif ($validationStatus -eq "PARTIAL") { "Yellow" } else { "Red" })
    Write-Host "========================================" -ForegroundColor Cyan
    
    $result = Write-ValidationResult -Status $validationStatus -Message $validationMessage -Details $details
    return $result
}
catch {
    $errorMessage = "Error during SKU validation: $($_.Exception.Message)"
    Write-Host "`nERROR: $errorMessage" -ForegroundColor Red
    Write-Host "Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    
    $result = Write-ValidationResult -Status "ERROR" -Message $errorMessage -Details @{
        Exception = $_.Exception.Message
        StackTrace = $_.ScriptStackTrace
    }
    return $result
}

#endregion
