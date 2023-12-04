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

	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[string]$SecurityPrincipalName,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $SubscriptionId,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $ShareName,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $CustomOuPath,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $IdentityServiceProvider,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $DomainName,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $OUName,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $StoragePurpose,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $StorageAccountFqdn,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $AzureCloudEnvironment
)

$ErrorActionPreference = "Stop"

. (Join-Path $ScriptPath "Logger.ps1")

if ($IdentityServiceProvider -ne 'AAD') {
	Write-Log "Forcing group policy updates"
	gpupdate /force

	Write-Log "Waiting for domain policies to be applied (1 minute)"
	Start-Sleep -Seconds 60
}

Write-Log "Turning off Windows firewall. "
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowershellGet -MinimumVersion 2.2.4.1 -Force
Install-Module -Name Az.Accounts -Force
Install-Module -Name Az.Storage -Force
Install-Module -Name Az.Network -Force
Install-Module -Name Az.Resources -Force

if ($IdentityServiceProvider -eq 'ADDS') {
	Write-Log "Installing AzFilesHybrid module"
	$AzFilesZipLocation = Get-ChildItem -Path $PSScriptRoot -Filter "AzFilesHybrid*.zip"
	Expand-Archive $AzFilesZipLocation.FullName -DestinationPath $PSScriptRoot -Force
	Set-Location $PSScriptRoot
	$AzFilesHybridPath = (Join-Path $PSScriptRoot "CopyToPSPath.ps1")
	& $AzFilesHybridPath
}

if ($IdentityServiceProvider -eq 'ADDS') {
	# Please note: ActiveDirectory powershell module is only available on AD joined machines.
	# To install it, RSAT administrative tools must be installed on the VM which will
	# install the ActiveDirectory powershell module. AzFilesHybrid module takes care of
	# installing the RSAT tool, ActiveDirectory powershell module.
	Import-Module -Name AzFilesHybrid -Force
	$ADModule = Get-Module -Name ActiveDirectory
	if (-not $ADModule) {
		Request-OSFeature -WindowsClientCapability "Rsat.ActiveDirectory.DS-LDS.Tools" -WindowsServerFeature "RSAT-AD-PowerShell"
		Import-Module -Name activedirectory -Force -Verbose
	}
	$IsStorageAccountDomainJoined = Get-ADObject -Filter 'ObjectClass -eq "Computer"' | Where-Object { $_.Name -eq $StorageAccountName }
	if ($IsStorageAccountDomainJoined) {
		Write-Log "Storage account $StorageAccountName is already domain joined."
		return
	}
}

Write-Log "Connecting to managed identity account"
Connect-AzAccount -Identity -AccountId $ClientId

Write-Log "Setting Azure subscription to $SubscriptionId"
Select-AzSubscription -SubscriptionId $SubscriptionId

if ($IdentityServiceProvider -eq 'ADDS') {
	Write-Log "Domain joining storage account $StorageAccountName in Resource group $StorageAccountRG"
	if ( $CustomOuPath -eq 'true') {
		#Join-AzStorageAccountForAuth -ResourceGroupName $StorageAccountRG -StorageAccountName $StorageAccountName -DomainAccountType 'ComputerAccount' -OrganizationalUnitDistinguishedName $OUName -OverwriteExistingADObject
		Join-AzStorageAccount -ResourceGroupName $StorageAccountRG -StorageAccountName $StorageAccountName -OrganizationalUnitDistinguishedName $OUName -DomainAccountType 'ComputerAccount' -EncryptionType 'AES256' -OverwriteExistingADObject #-SamAccountName $SamAccountName
		Write-Log -Message "Successfully domain joined the storage account $StorageAccountName to custom OU path $OUName"
	}
 else {
		#Join-AzStorageAccountForAuth -ResourceGroupName $StorageAccountRG -StorageAccountName $StorageAccountName -DomainAccountType 'ComputerAccount' -OrganizationalUnitName $OUName -OverwriteExistingADObject
		Join-AzStorageAccount -ResourceGroupName $StorageAccountRG -StorageAccountName $StorageAccountName -OrganizationalUnitName $OUName -DomainAccountType 'ComputerAccount' -EncryptionType 'AES256' -OverwriteExistingADObject #-SamAccountName $SamAccountName
		Write-Log -Message "Successfully domain joined the storage account $StorageAccountName to default OU path $OUName"
	}
}

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
	Write-Log "setting up NTFS permission for FSLogix or App attach"
	icacls ${DriveLetter}: /inheritance:r
	icacls ${DriveLetter}: /remove "BUILTIN\Administrators"
	icacls ${DriveLetter}: /grant "Creator Owner:(OI)(CI)(IO)(M)"
	icacls ${DriveLetter}: /remove "BUILTIN\Users"
	Write-Log "ACLs set"
	#AVD group permissions
	if ($SecurityPrincipalName -eq 'none' -or $IdentityServiceProvider -eq 'AAD') {
		Write-Log "AD group not provided or using Microsoft Entra ID joined session hosts, ACLs for AD group not set"
	}
	else {
		icacls ${DriveLetter}: /remove "Authenticated Users"
		$Group = $DomainName + '\' + $SecurityPrincipalName
		icacls ${DriveLetter}: /grant "${Group}:(M)"
		Write-Log "AD group $Group ACLs set"
	}
	# Write-Log "Unmounting drive"
	# # Remove-PSDrive -Name $DriveLetter -Force
	# net use ${DriveLetter} /delete
	# Write-Log "Drive unmounted"
}
Catch {
	Write-Log -Err "Error while setting up NTFS permission for FSLogix or App attach"
	Write-Log -Err $_.Exception.Message
	Throw $_
}
