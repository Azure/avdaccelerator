<#
	.SYNOPSIS
		Domain Join Storage Account
	
	.DESCRIPTION
		In case of AD_DS scenario, domain join storage account as a machine on the domain.
#>
param(
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $StorageAccountName,
	
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $StorageAccountRG,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $ClientId,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $SubscriptionId,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $ShareName,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $StoragePurpose,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $StorageAccountFqdn
)

$ErrorActionPreference = "Stop"

. (Join-Path $ScriptPath "Logger.ps1")

Write-Log "Turning off Windows firewall. "
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowershellGet -MinimumVersion 2.2.4.1 -Force
Install-Module -Name Az.Accounts -Force
Install-Module -Name Az.Storage -Force
Install-Module -Name Az.Network -Force
Install-Module -Name Az.Resources -Force

Write-Log "Connecting to managed identity account"
Connect-AzAccount -Identity -AccountId $ClientId

Write-Log "Setting Azure subscription to $SubscriptionId"
Select-AzSubscription -SubscriptionId $SubscriptionId

if ($StoragePurpose -eq 'fslogix') {
	$DriveLetter = 'Y'
}
if ($StoragePurpose -eq 'msix') {
	$DriveLetter = 'X'
}
Write-Log "Mounting $StoragePurpose storage account on Drive $DriveLetter"

$FileShareLocation = '\\' + $StorageAccountFqdn + '\' + $ShareName
$connectTestResult = Test-NetConnection -ComputerName $StorageAccountFqdn -Port 445

Write-Log "Test connection access to port 445 for $StorageAccountFqdn was $connectTestResult"

Try {
	Write-Log "Mounting Profile storage $StorageAccountName as a drive $DriveLetter"
	if (-not (Get-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue)) {
		$UserStorage = "/user:Azure\$StorageAccountName"
		Write-Log "User storage: $UserStorage"
		$StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $StorageAccountRG -AccountName $StorageAccountName) | Where-Object { $_.KeyName -eq "key1" }
		Write-Log "File Share location: $FileShareLocation"
		net use ${DriveLetter}: $FileShareLocation $UserStorage $StorageKey.Value
		#$StorageKey1 = ConvertTo-SecureString $StorageKey.value -AsPlainText -Force
		#$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("Azure\stfsly206dorg", $StorageKey1)
		#New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root $FileShareLocation -Credential $credential
	}
	else {
		Write-Log "Drive $DriveLetter already mounted."
	}
}
Catch {
	Write-Log -Err "Error while mounting profile storage as drive $DriveLetter"
	Write-Log -Err $_.Exception.Message
	Throw $_
}

Try {
	Write-Log "setting up NTFS permission for FSLogix"
	icacls ${DriveLetter}: /remove "BUILTIN\Administrators"
	icacls ${DriveLetter}: /grant "Creator Owner:(OI)(CI)(IO)(M)"
	icacls ${DriveLetter}: /remove "Authenticated Users"
	icacls ${DriveLetter}: /remove "Builtin\Users"
	Write-Log "ACLs set"

	Write-Log "Unmounting drive"
	# Remove-PSDrive -Name $DriveLetter -Force
	net use ${DriveLetter} /delete
	Write-Log "Drive unmounted"
}
Catch {
	Write-Log -Err "Error while setting up NTFS permission for FSLogix"
	Write-Log -Err $_.Exception.Message
	Throw $_
}
