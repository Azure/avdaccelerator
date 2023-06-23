# Work in PROGRESS - Will be runbook for Automation Account
# to collect Host Pool information and output to Log Analytics

[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[string]$CloudEnvironment,
    [Parameter(Mandatory)]
    [string]$SubscriptionId
)

Connect-AzAccount -Identity -Environment $CloudEnvironment | Out-Null

$AVDHostPools = Get-AzWvdHostPool -SubscriptionId $SubscriptionId

# $HostPoolInfoObj= @()
$Output = @()

Foreach($AVDHostPool in $AVDHostPools){
	$HPName = $AVDHostPool.Name
    $HPResGroup = ($AVDHostPool.Id -split '/')[4]
    $HPType = $AVDHostPool.HostPoolType
    $HPMaxSessionLimit = $AVDHostPool.MaxSessionLimit
    $HPNumSessionHosts = (Get-AzWvdSessionHost -HostPoolName $HPName -ResourceGroupName $HPResGroup).count
    $HPUsrSession = (Get-AzWvdUserSession -HostPoolName $HPName -ResourceGroupName $HPResGroup).count
    $HPUsrDisonnected = (Get-AzWvdUserSession -HostPoolName $HPName -ResourceGroupName $HPResGroup | Where-Object {$_.sessionState -eq "Disconnected" -AND $_.userPrincipalName -ne $null}).count
    $HPUsrActive = (Get-AzWvdUserSession -HostPoolName $HPName -ResourceGroupName $HPResGroup | Where-Object {$_.sessionState -eq "Active" -AND $_.userPrincipalName -ne $null}).count
    # Max allowed Sessions - Based on Total given unavailable may be on scaling plan
    $HPSessionsAvail = ($HPMaxSessionLimit * $HPNumSessionHosts)-$HPUsrSession
    if($HPUsrSession -ne 0)	{
		$HPLoadPercent = ($HPUsrSession/($HPMaxSessionLimit * $HPNumSessionHosts))*100
	}
	Else {$HPLoadPercent = 0}
	$Output += $HPName + "|" + $HPResGroup + "|" + $HPType + "|" + $HPMaxSessionLimit  + "|" + $HPNumSessionHosts + "|" + $HPUsrSession  + "|" + $HPUsrDisonnected  + "|" + $HPUsrActive + "|" + $HPSessionsAvail + "|" + $HPLoadPercent
    <#$HostPoolInfoObj += [PSCustomObject]@{
        HPName              = $HPName
        HPResGroup          = $HPResGroup
        HPType              = $HPType.ToString()
        HPMaxSessionLimit   = $HPMaxSessionLimit
        HPNumSessionHosts   = $HPNumSessionHosts
        HPUsrSessions       = $HPUsrSession
        HPSessionsAvail     = $HPSessionsAvail
        HPUsrActive         = $HPUsrActive
        HPUsrDisconn        = $HPUsrDisonnected
    }
	#>
}
# $Output = ConvertTo-Json -InputObject $HostPoolInfoObj
Write-Output $Output