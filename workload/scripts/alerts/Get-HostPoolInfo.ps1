# Runbook for Automation Account
# to collect Host Pool information and output to Log Analytics
# (Derived from AVD Alerts Solution)
# June 2023 - added additonal Personal Host Pool logging

[CmdletBinding(SupportsShouldProcess)]
param(
	[Parameter(Mandatory)]
	[string]$CloudEnvironment,
    [Parameter(Mandatory)]
    [string]$SubscriptionId
)

Connect-AzAccount -Identity -Environment $CloudEnvironment | Out-Null

$AVDHostPools = Get-AzWvdHostPool -SubscriptionId $SubscriptionId

Foreach($AVDHostPool in $AVDHostPools){
	$HPName = $AVDHostPool.Name
    $HPResGroup = ($AVDHostPool.Id -split '/')[4]
    $HPType = $AVDHostPool.HostPoolType
    $HPMaxSessionLimit = $AVDHostPool.MaxSessionLimit
    $SessionHosts = Get-AzWvdSessionHost -HostPoolName $HPName -ResourceGroupName $HPResGroup
    $UserSessions = Get-AzWvdUserSession -HostPoolName $HPName -ResourceGroupName $HPResGroup
    $HPNumSessionHosts = $SessionHosts.count
    $HPUsrSession = $UserSessions.count
    $HPUsrDisonnected = ($SessionHosts | Where-Object {$_.sessionState -eq "Disconnected" -AND $_.userPrincipalName -ne $null}).count
    $HPUsrActive = ($UserSessions | Where-Object {$_.sessionState -eq "Active" -AND $_.userPrincipalName -ne $null}).count
    $PersonalHostError = $false
    $Machine = $null
    $User = $null
    $VMRG = $null

    If($HPType -eq "Personal"){
        Foreach($Sessionhost in $SessionHosts){
            # If Status not Available and Assigned log
            If(($Sessionhost.Status -ne "Available") -AND ($null -ne $Sessionhost.AssignedUser)){            
                $PersonalHostError = $true
                $User = $SessionHost.AssignedUser
                $VMRG = ($SessionHost.ResourceId -split '/')[4]
                $Machine = ($SessionHost.ResourceId -split '/')[8]
            }
        }
    }
    # Max allowed Sessions - Based on Total given unavailable may be on scaling plan
    $HPSessionsAvail = ($HPMaxSessionLimit * $HPNumSessionHosts)-$HPUsrSession
    if($HPUsrSession -ne 0)	{
		$HPLoadPercent = ($HPUsrSession/($HPMaxSessionLimit * $HPNumSessionHosts))*100
	}
	Else {$HPLoadPercent = 0}
	Write-Output "$HPName|$HPResGroup|$HPType|$HPMaxSessionLimit|$HPNumSessionHosts|$HPUsrSession|$HPUsrDisonnected|$HPUsrActive|$HPSessionsAvail|$HPLoadPercent|$PersonalHostError|$VMRG|$Machine|$User"
}