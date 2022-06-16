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
	[string] $DomainName,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $OUName,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $CreateNewOU,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $AzureCloudEnvironment
)

$ErrorActionPreference = "Stop"

. (Join-Path $ScriptPath "Logger.ps1")

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowershellGet -MinimumVersion 2.2.4.1 -Force
Install-Module -Name Az.Accounts -Force
Install-Module -Name Az.Storage -Force
Install-Module -Name Az.Network -Force
Install-Module -Name Az.Resources -Force

Write-Log "Installing AzFilesHybrid module"
$AzFilesZipLocation = Get-ChildItem -Path $PSScriptRoot -Filter "AzFilesHybrid*.zip"
Expand-Archive $AzFilesZipLocation.FullName -DestinationPath $PSScriptRoot -Force
Set-Location $PSScriptRoot
$AzFilesHybridPath = (Join-Path $PSScriptRoot "CopyToPSPath.ps1")
& $AzFilesHybridPath

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

$IsStorageAccountDomainJoined = Get-ADObject -Filter 'ObjectClass -eq "Computer"' | Where-Object {$_.Name -eq $StorageAccountName}
if ($IsStorageAccountDomainJoined) {
    Write-Log "Storage account $StorageAccountName is already domain joined."
    return
}

if ( $CreateNewOU -eq 'true') {
Write-Log "Creating AD Organizational unit $OUName'"
Get-ADOrganizationalUnit -Filter 'Name -like $OUName'
$OrganizationalUnit = Get-ADOrganizationalUnit -Filter 'Name -like $OUName '
if (-not $OrganizationalUnit) {
	foreach($DCName in $DomainName.split('.')) {
		$OUPath = $OUPath + ',DC=' + $DCName
	}

	$OUPath = $OUPath.substring(1)
	New-ADOrganizationalUnit -name $OUName -path $OUPath
}

	}

Write-Log "Domain joining storage account $StorageAccountName in Resource group $StorageAccountRG"
# Add-AzAccount -Environment $AzureCloudEnvironment -identity
Connect-AzAccount -Identity -AccountId $ClientId

Write-Log "Setting Azure subscription to $SubscriptionId"
Select-AzSubscription -SubscriptionId $SubscriptionId

Join-AzStorageAccountForAuth -ResourceGroupName $StorageAccountRG -StorageAccountName $StorageAccountName -DomainAccountType 'ComputerAccount' -OrganizationalUnitName $OUName -OverwriteExistingADObject
Write-Log -Message "Successfully domain joined the storage account $StorageAccountName"

## Setting default permissions 
#$defaultPermission = "None|StorageFileDataSmbShareContributor|StorageFileDataSmbShareReader|StorageFileDataSmbShareElevatedContributor" # Set the default permission of your choice

$defaultPermission = "StorageFileDataSmbShareContributor" # Set the default permission of your choice
Write-Log "Setting up the default permission of $defaultPermission to storage account $StorageAccountName in $StorageAccountRG"
$account = Set-AzStorageAccount -ResourceGroupName $StorageAccountRG -AccountName $StorageAccountName -DefaultSharePermission $defaultPermission
$account.AzureFilesIdentityBasedAuth

# Remove Administrators from full control 

$DriveLetter = "Y"
$FileShareLocation = '\\'+ $StorageAccountName + 'file.core.windows.net\\'+$ShareName

Try {
    Write-Log "Mounting Profile storage $StorageAccountName as a drive $DriveLetter"
    if (-not (Get-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue)) {
        $UserStorage = "/user:Azure\$StorageAccountName"
        
        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $StorageAccountRG -AccountName $StorageAccountName) | Where-Object {$_.KeyName -eq "key1"}
        net use ${DriveLetter}: $FileShareLocation $UserStorage $StorageKey.Value
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
    $Commands = "icacls ${DriveLetter}: /remove ('BUILTIN\Administrators')"
    Invoke-Expression -Command $Commands
    Write-Log "ACLs set"
}
Catch {
    Write-Log -Err "Error while setting up NTFS permission for FSLogix"
    Write-Log -Err $_.Exception.Message
    Throw $_
}
