<#
LAST UPDTATE: July 2023
-- Added info for Personal Host Pool Info regarding need for alert where assigned but unhealthy
#>


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
    $HPPerUnhlthy = $null
    $HPNumPerUnhlthy = $null
    $HPPerHostUnhlthy = $null
	$HPName = $AVDHostPool.Name
    $HPResGroup = ($AVDHostPool.Id -split '/')[4]
    $HPType = $AVDHostPool.HostPoolType
    $HPMaxSessionLimit = $AVDHostPool.MaxSessionLimit
    $HPSessionHosts = Get-AzWvdSessionHost -HostPoolName $HPName -ResourceGroupName $HPResGroup
    $HPUsrSessions = Get-AzWvdUserSession -HostPoolName $HPName -ResourceGroupName $HPResGroup
    $HPNumSessionHosts = $HPSessionHosts.count
    $HPUsrSession = $HPUsrSessions.count
    $HPUsrDisonnected = ($HPUsrSessions | Where-Object {$_.sessionState -eq "Disconnected" -AND $_.userPrincipalName -ne $null}).count
    $HPUsrActive = ($HPUsrSessions | Where-Object {$_.sessionState -eq "Active" -AND $_.userPrincipalName -ne $null}).count
    If($HPType -eq "Personal"){
        $HPPerUnhlthy = $HPSessionHosts | Where-Object {$_.AssignedUser -ne $null -AND $_.Status -ne "Available"}
        $HPNumPerUnhlthy = $HPPerUnhlthy.count
        $HostList = New-Object PSObject
        foreach($item in $HPPerUnhlthy){
            $HostList | Add-Member -Type NoteProperty -Name SessionHost -Value ($item.name -split '/')[1]
            $HostList | Add-Member -Type NoteProperty -Name AssignedUser -Value $item.AssignedUser
            }
        $HPPerHostUnhlthy = $HostList | ConvertTo-Json
        }
   
    #Adding number of hosts available and allowing sessions, and Host Pool resource ID
    $HP_ResID = $AVDHostPool.Id
    $HPNumHostsAllowingSessions = (Get-AzWvdSessionHost -HostPoolName $HPName -ResourceGroupName $HPResGroup | where {$_.AllowNewSession}).count
    $HPNumHostsAvailable = (Get-AzWvdSessionHost -HostPoolName $HPName -ResourceGroupName $HPResGroup | where {$_.Status -eq "Available"}).count
    $HPNumHostsAvailableAndAllowingSessions = (Get-AzWvdSessionHost -HostPoolName $HPName -ResourceGroupName $HPResGroup | where {$_.Status -eq "Available" -and $_.AllowNewSession}).count
    #Changing how we calculate available sessions to be based on number of hosts that are available and allowing sessions, instead of total number of hosts

# Max allowed Sessions - Based on Total given unavailable may be on scaling plan
    #$HPSessionsAvail = ($HPMaxSessionLimit * $HPNumSessionHosts)-$HPUsrSession
    #if($HPUsrSession -ne 0)	{
	#	$HPLoadPercent = ($HPUsrSession/($HPMaxSessionLimit * $HPNumSessionHosts))*100
	#}
    $HPSessionsAvail = ($HPMaxSessionLimit * $HPNumHostsAvailableAndAllowingSessions)-$HPUsrSession
    if($HPUsrSession -ne 0)	{
		$HPLoadPercent = ($HPUsrSession/($HPMaxSessionLimit * $HPNumHostsAvailableAndAllowingSessions))*100
	}
	Else {$HPLoadPercent = 0}
    $Output += $HPName + "|" + $HPResGroup + "|" + $HPType + "|" + $HPMaxSessionLimit  + "|" + $HPNumSessionHosts + "|" + $HPUsrSession  + "|" + $HPUsrDisonnected  + "|" + $HPUsrActive + "|" + $HPSessionsAvail + "|" + $HPLoadPercent + "|" + $HPNumPerUnhlthy + "|" + $HPPerHostUnhlthy  + "|" + $HP_ResID
}

# $Output = ConvertTo-Json -InputObject $HostPoolInfoObj
Write-Output $Output