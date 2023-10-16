$SubscriptionId = "c6aa1fdc-66a8-446e-8b37-7794cd545e44"
Connect-AzAccount -Subscription $SubscriptionId
Set-AzContext -Subscription $SubscriptionId
# Disconnect-AzAccount

$dcrname = 'Microsoft-VMInsights-Health-eastus'
$rgname = 'lab1hprg'



$resources = (Get-AzDataCollectionRuleAssociation -ResourceGroupName $rgname -RuleName $dcrname).Id
$resources | ForEach-Object {
    Write-Host $_.Split("/")[4] $_.Split("/")[8]
    $RGName = $_.Split("/")[4]
    $vmName = $_.Split("/")[8]
    Add-Content -Path c:\temp\AMA_VMs.txt -Value "$RGName $vmName"
}

# Check which LAW DCR is pointing to, from LAW run 
# Heartbeat | where Category == "Azure Monitor Agent" | distinct Computer