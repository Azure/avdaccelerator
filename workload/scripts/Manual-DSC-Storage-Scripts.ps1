param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $DscPath,  

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StorageAccountName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StorageAccountRG,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $SubscriptionId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ClientId,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$SecurityPrincipalName,
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShareName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $CustomOuPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $IdentityServiceProvider,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AzureCloudEnvironment,
	
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $OUName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AdminUserName,
	
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AdminUserPassword,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StorageAccountFqdn,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $StoragePurpose
)

if ($IdentityServiceProvider -ne 'EntraID') {
        # The $AdminUserName might be in UPN format instead of NTLM format
        # If that happens, Add-LocalGroupMember succeeds, but Get-LocalGroupMember fails
        [string]$CheckAdminUserName = $AdminUserName
        If ($CheckAdminUserName -match '^(?<user>.+)@.+$') {
                # Convert the username to check in NTLM format
                $CheckAdminUserName = "$((Get-WmiObject Win32_NTDomain).DomainName)\\$($Matches['user'])"
        }

        # Check if the domain join account is already in the local Administrators group
        $Member = Get-LocalGroupMember -Group "Administrators" -Member $CheckAdminUserName -ErrorAction SilentlyContinue

        # If the domain join account is not in the local Administrators group
        if (! $Member) {
                Write-Host "Add domain join account '$AdminUserName' as local Administrator"
                Add-LocalGroupMember -Group "Administrators" -Member $AdminUserName
                Write-Host "Domain join account added to local Administrators group"
        }
        else {
                Write-Host "Domain join account '$AdminUserName' already in local Administrators group"
        }
}
else {
        Write-Host "Using EntraID, no domain join account to add to local Administrators group"
}

Write-Host "Downloading the DSCStorageScripts.zip from $DscPath"
$DscArchive = "DSCStorageScripts.zip"
$appName = 'DSCStorageScripts-' + $StoragePurpose
$drive = 'C:\Packages'
New-Item -Path $drive -Name $appName -ItemType Directory -ErrorAction SilentlyContinue

$LocalPath = $drive + '\DSCStorageScripts-' + $StoragePurpose
Write-Host "Setting DSC local path to $LocalPath"
$OutputPath = $LocalPath + '\' + $DscArchive
Invoke-WebRequest -Uri $DscPath -OutFile $OutputPath

Write-Host "Expanding the archive $DscArchive" 
Expand-Archive -LiteralPath $OutputPath -DestinationPath $LocalPath -Force -Verbose

Set-Location -Path $LocalPath

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module 'PSDscResources' -Force

# Handling special characters on password
function Set-EscapeCharacters {
        Param(
                [parameter(Mandatory = $true, Position = 0)]
                [String]
                $string
        )
        $string = $string -replace '\*', '`*'
        $string = $string -replace '\\', '`\'
        $string = $string -replace '\~', '`~'
        $string = $string -replace '\;', '`;'
        $string = $string -replace '\(', '`('
        $string = $string -replace '\%', '`%'
        $string = $string -replace '\?', '`?'
        $string = $string -replace '\.', '`.'
        $string = $string -replace '\:', '`:'
        $string = $string -replace '\@', '`@'
        $string = $string -replace '\/', '`/'
        $string = $string -replace '\$', '`$'
        $string
}
$AdminUserPasswordEscaped = Set-EscapeCharacters $AdminUserPassword

$DscCompileCommand = "./Configuration.ps1 -StorageAccountName """ + $StorageAccountName + """ -StorageAccountRG """ + $StorageAccountRG + """ -StoragePurpose """ + $StoragePurpose + """ -StorageAccountFqdn """ + $StorageAccountFqdn + """ -ShareName """ + $ShareName + """ -SubscriptionId """ + $SubscriptionId + """ -ClientId """ + $ClientId + """ -SecurityPrincipalName """ + $SecurityPrincipalName + """ -DomainName """ + $DomainName + """ -IdentityServiceProvider """ + $IdentityServiceProvider + """ -AzureCloudEnvironment """ + $AzureCloudEnvironment + """ -CustomOuPath " + $CustomOuPath + " -OUName """ + $OUName + """ -AdminUserName """ + $AdminUserName + """ -AdminUserPassword """ + $AdminUserPasswordEscaped + """ -Verbose"

Write-Host "Executing the command $DscCompileCommand" 
Invoke-Expression -Command $DscCompileCommand

$MofFolder = 'DomainJoinFileShare'
$MofPath = $LocalPath + '\' + $MofFolder
Write-Host "Generated MOF files here: $MofPath"

Write-Host "Applying MOF files. DSC configuration"
Set-WSManQuickConfig -Force -Verbose
Start-DscConfiguration -Path $MofPath -Wait -Verbose -force

Write-Host "DSC extension run clean up"
Remove-Item -Path $MofPath -Force -Recurse