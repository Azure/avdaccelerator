param(
    
    [parameter(Mandatory=$true)]
	[array]
	$AVDResourceIDs
)

$ErrorActionPreference = 'Stop'

# Object for collecting output
$DeploymentScriptOutputs = @{}



Class HPInfo{
    [string]$HostPoolName
    [string]$HostPoolResId
	[string]$VMResourceGroup
    [array] $VMNames
    [array] $VMResourceIDs
}

$AllHPInfo = @()

# =================================================================================================
# AVD Host Pool RG Names
# =================================================================================================
Foreach ($HostPoolID in $AVDResourceIDs) {
	$HostPoolobj = New-Object HPInfo
	$HostPoolName = ($HostPoolID -split '/')[8]
	$HostPoolRG = ($HostPoolID -split '/')[4]
	$HostPoolSubID = ($HostPoolID -split '/')[2]   	
	$NoSessinHosts = $true
	$HostPool = Get-AzWvdHostPool -ResourceGroupName $HostPoolRG -SubscriptionId $HostPoolSubID -Name $HostPoolName

	$SessionHostNames = Get-AzWvdSessionHost -SubscriptionId $HostPoolSubID -ResourceGroupName $HostPoolRG -HostPoolName $HostPoolName
	foreach($sessionHost in $SessionHostNames){
		If ($sessionHost.Name -ne 'null') {
			$VMRefName = ($sessionHost.Name -split '/')[1]  
			$DotLocation = $VMRefName.IndexOf('.')
			If ($DotLocation -ne -1) { $VM = $VMRefName.Substring(0, $DotLocation)}
			else{$VM = $VMRefName}
			$VMinfo = Get-AzVM -Name $VM
			$VMResID = $VMinfo.Id
			$VMResGroup = "/" + (($VMResID -split '/')[1..4] -join '/')
			If($VMResID.Count -gt 0){
				$HostPoolobj.VMNames += $VM
				$HostPoolobj.VMResourceIDs += $VMResID	
				$HostPoolobj.VMResourceGroup = $VMResGroup
				$NoSessionHosts = $false			
			}
		}
	}
	$HostPoolobj.HostPoolName += $HostPoolName
	$HostPoolobj.HostPoolResId += $HostPoolID
	If($NoSessionHosts)  {
		$HostPoolobj.VMNames = @()
		$HostPoolobj.VMResourceGroup = ""
	}
	$AllHPinfo += $HostPoolobj
}


$AllHPInfo = $AllHPInfo | ConvertTo-Json -Depth 20

$DeploymentScriptOutputs["HostPoolInfo"] = $AllHPInfo
