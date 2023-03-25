# Quota Scaling for Azure Files Premium
# Scaling the quota is neccessary for Azure Files Premium since the customer is billed based on the quota size,
# not the consumed space like Azure Files Standard.

[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[string]$EnvironmentName,
	
	[Parameter(Mandatory)]
	[string]$FileShareName,
	
	[Parameter(Mandatory)]
	[int]$QuotaIncreaseAmountInGb,

	[Parameter(Mandatory)]
	[int]$QuotaIncreaseThresholdInGb,

	[Parameter(Mandatory)]
	[string]$StorageAccountName,

	[Parameter(Mandatory)]
	[string]$StorageAccountResourceGroupName,
	
	[Parameter(Mandatory)]
	[string]$StorageAccountSubscriptionId,

	[Parameter(Mandatory)]
	[string]$TenantId
)

$ErrorActionPreference = 'Stop'

#Connect to Azure and Import Az Module
Import-Module -Name 'Az.Accounts','Az.Storage'
Connect-AzAccount -Environment $EnvironmentName -Tenant $TenantId -Subscription $StorageAccountSubscriptionId -Identity | Out-Null

# Get file share
$Share = Get-AzRmStorageShare -ResourceGroupName $StorageAccountResourceGroupName -StorageAccountName $StorageAccountName -Name $FileShareName -GetShareUsage

# Get provisioned capacity and used capacity
$ProvisionedCapacity = $Share.QuotaGiB
$UsedCapacity = $Share.ShareUsageBytes
Write-Output "[$StorageAccountName] [$FileShareName] Share Capacity: $($ProvisionedCapacity)GB"
Write-Output "[$StorageAccountName] [$FileShareName] Share Usage: $([math]::Round($UsedCapacity/1GB, 0))GB"

# Get storage account
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $StorageAccountResourceGroupName -AccountName $StorageAccountName


# No increase if no usage
if($UsedCapacity -eq 0)
{
	Write-Output "[$StorageAccountName] [$FileShareName] Share Usage is 0GB. No Changes."
}
# Increase file share quota
else
{
	if (($ProvisionedCapacity - ($UsedCapacity / ([Math]::Pow(2,30)))) -lt $QuotaIncreaseThresholdInGb) {
		Write-Output "[$StorageAccountName] [$FileShareName] Share Usage has surpassed the Share Quota remaining threshold of $($QuotaIncreaseThresholdInGb)GB. Increasing the file share quota by $($QuotaIncreaseAmountInGb)GB." 
		$Quota = $ProvisionedCapacity + $QuotaIncreaseAmountInGb
		Update-AzRmStorageShare -StorageAccount $StorageAccount -Name $FileShareName -QuotaGiB $Quota | Out-Null
		Write-Output "[$StorageAccountName] [$FileShareName] New Capacity: $($Quota)GB"
	}
	else {
		Write-Output "[$StorageAccountName] [$FileShareName] Share Usage is below Share Quota remaining threshold of $($QuotaIncreaseThresholdInGb)GB. No Changes."
	}
}
