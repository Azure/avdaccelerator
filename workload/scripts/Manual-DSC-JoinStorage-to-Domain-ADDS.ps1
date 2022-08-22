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
        
	[Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $ShareName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AzureCloudEnvironment,
	
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $OUName,

	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $CreateNewOU,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainAdminUserName,
	
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $DomainAdminUserPassword

)
Write-Host "Downloading the DSCDomainJoinStorageScriptsADDS.zip from $DscPath"
$DscArhive="DSCDomainJoinStorageScriptsADDS.zip"
$appName = 'DSCDomainJoinStorageScriptsADDS'
$drive = 'C:\Packages'
New-Item -Path $drive -Name $appName -ItemType Directory -ErrorAction SilentlyContinue
$LocalPath = "C:\Packages\DSCDomainJoinStorageScriptsADDS"
$OutputPath = $LocalPath + '\' + $DscArhive
Invoke-WebRequest -Uri $DscPath -OutFile $OutputPath

Write-Host "Expanding the archive $DscArchive" 
Expand-Archive -LiteralPath 'C:\\Packages\\DSCDomainJoinStorageScriptsADDS\\DSCDomainJoinStorageScriptsADDS.zip' -DestinationPath $Localpath -Force -Verbose

Set-Location -Path $LocalPath

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module 'PSDscResources' -Force


$DscCompileCommand="./Configuration.ps1 -StorageAccountName " + $StorageAccountName +  " -StorageAccountRG " + $StorageAccountRG + " -ShareName " + $ShareName + " -SubscriptionId " + $SubscriptionId + " -ClientId " + $ClientId +" -DomainName " + $DomainName + " -AzureCloudEnvironment " + $AzureCloudEnvironment + " -OUName """ + $OUName + """ -CreateNewOU " + $CreateNewOU + " -DomainAdminUserName " + $DomainAdminUserName + " -DomainAdminUserPassword " + $DomainAdminUserPassword + " -Verbose"

Write-Host "Executing the commmand $DscCompileCommand" 
Invoke-Expression -Command $DscCompileCommand

$MofFolder='DomainJoinFileShare'
$MofPath=$LocalPath + '\' + $MofFolder
Write-Host "Generated MOF files here: $MofPath"

Write-Host "Applying MOF files. DSC configuration"
Set-WSManQuickConfig -Force -Verbose
Start-DscConfiguration -Path $MofPath -Wait -Verbose
