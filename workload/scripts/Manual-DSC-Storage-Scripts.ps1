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

Write-Host "Add domain join account as local administrator"
if ($IdentityServiceProvider -ne 'AAD') {
        Add-LocalGroupMember -Group "Administrators" -Member $AdminUserName
        Write-Host "Domain join account added to local administrators group"
}
else {
        Write-Host "Using AAD, no domain join account to add to local administrators group"
}

Write-Host "Downloading the DSCStorageScripts.zip from $DscPath"
$DscArhive = "DSCStorageScripts.zip"
$appName = 'DSCStorageScripts-' + $StoragePurpose
$drive = 'C:\Packages'
New-Item -Path $drive -Name $appName -ItemType Directory -ErrorAction SilentlyContinue

Write-Host "Setting DSC local path to $LocalPath"
$LocalPath = $drive + '\DSCStorageScripts-' + $StoragePurpose
$OutputPath = $LocalPath + '\' + $DscArhive
Invoke-WebRequest -Uri $DscPath -OutFile $OutputPath

Write-Host "Expanding the archive $DscArchive" 
Expand-Archive -LiteralPath $OutputPath -DestinationPath $Localpath -Force -Verbose

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

Write-Host "Executing the commmand $DscCompileCommand" 
Invoke-Expression -Command $DscCompileCommand

$MofFolder = 'DomainJoinFileShare'
$MofPath = $LocalPath + '\' + $MofFolder
Write-Host "Generated MOF files here: $MofPath"

Write-Host "Applying MOF files. DSC configuration"
Set-WSManQuickConfig -Force -Verbose
Start-DscConfiguration -Path $MofPath -Wait -Verbose -force

Write-Host "DSC extension run clean up"
Remove-Item -Path $MofPath -Force -Recurse