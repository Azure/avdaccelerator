# Deployed from resources.bicep 
# Code for Runbook associated with Action Account deployment
# Collects Azure Files Storage data and writes output in following format:
# AzFiles, Subscription ,RG ,StorAcct ,Share ,Quota ,GB Used ,%Available

<#
//Kusto Query for Log Analtyics
AzureDiagnostics 
| where Category has "JobStreams"
| where StreamType_s has "Output"
| extend Results=split(ResultDescription,',')
#>

[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[string]$CloudEnvironment,
    [Parameter(Mandatory)]
	[array]$StorageAccountResourceIDs
)

Connect-AzAccount -Identity -Environment $CloudEnvironment | Out-Null
Import-Module -Name 'Az.Accounts'
Import-Module -Name 'Az.Storage'

$SubName = (Get-azSubscription -SubscriptionId ($StorageAccountResourceIDs -split '/')[2]).Name

# Foreach storage account
Foreach ($storageAcct in $storageAccountResourceIDs) {
    
    $resourceGroup = ($storageAcct -split '/')[4]
    $storageAcctName = ($storageAcct -split '/')[8]
    #Write-Host "Working on Storage:" $storageAcctName "in" $resourceGroup
 
    # $shares = Get-AzStorageShare -ResourceGroupName $resourceGroup -StorageAccountName $storageAcctName -Name 'profiles' -GetShareUsage
	$shares = Get-AzRmStorageShare -ResourceGroupName $ResourceGroup -StorageAccountName $storageAcctName

    # Foreach Share
    Foreach ($share in $shares) {
        $shareName = $share.Name
        $share = Get-AzRmStorageShare -ResourceGroupName $ResourceGroup -StorageAccountName $storageAcctName -Name $shareName -GetShareUsage
        #Write-Host "Share: " $shareName
        $shareQuota = $share.QuotaGiB #GB
        $shareUsageInGB = $share.ShareUsageBytes / 1073741824 # Bytes to GB
        
        $RemainingPercent = 100 - ($shareUsageInGB / $shareQuota)
        #Write-Host "..." $shareUsageInGB "of" $shareQuota "GB used"
        #Write-Host "..." $RemainingPercent "% Available"
        # Add file share resource Id
        $shareResourceId = $share.Id
        # Compile results 
        # AzFiles / Subscription / RG / StorAcct / Share / Quota / GB Used / %Available
        $Data = @('AzFiles', $SubName, $resourceGroup, $storageAcctName, $shareName, $shareQuota.ToString(), $shareUsageInGB.ToString(), $RemainingPercent.ToString(), $shareResourceId)
        $i = 0
        ForEach ($Item in $Data) {
            If ($i -ne $Data.Length - 1) {
                # Ensure we don't add the trailing comma if last item
                $Output += $Item + ','
                $i += 1
            }
            else { $Output += $Item }
        }

        Write-Output $Output
        $Output = $Null
        $Data = $Null
    } # end for each share

} # end for each storage acct