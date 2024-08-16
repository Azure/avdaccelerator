param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $dscPath,  

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $subscriptionId,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $serviceObjectsRgName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $computeObjectsRgName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $storageObjectsRgName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $networkObjectsRgName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $monitoringObjectsRgName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $azureCloudEnvironment,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $managementVmName
)
        
Write-Host "Downloading the DSC package from $DscPath"
$DscArhive="postDeploymentTempResourcesCleanUp.zip"
$appName = 'DSCCleanUpScript'
$drive = 'C:\Packages'
New-Item -Path $drive -Name $appName -ItemType Directory -ErrorAction SilentlyContinue

Write-Host "Setting DSC local path to $LocalPath"
$LocalPath = $drive+'\DSCCleanUpScript'
$OutputPath = $LocalPath + '\' + $DscArhive
Invoke-WebRequest -Uri $DscPath -OutFile $OutputPath

Write-Host "Expanding the archive $DscArchive" 
Expand-Archive -LiteralPath $OutputPath -DestinationPath $Localpath -Force -Verbose

Set-Location -Path $LocalPath

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module 'PSDscResources' -Force

$DscCompileCommand="./configuration.ps1 -subscriptionId " + $subscriptionId +  " -serviceObjectsRgName " + $serviceObjectsRgName +" -computeObjectsRgName " + $computeObjectsRgName + " -storageObjectsRgName " + $storageObjectsRgName + " -networkObjectsRgName " + $networkObjectsRgName +" -monitoringObjectsRgName " + $monitoringObjectsRgName + " -azureCloudEnvironment " + $azureCloudEnvironment + " managementVmName " + $managementVmName + " -Verbose"

Write-Host "Executing the commmand $DscCompileCommand" 
Invoke-Expression -Command $DscCompileCommand

$MofFolder='TempResourcesCleanUp'
$MofPath=$LocalPath + '\' + $MofFolder
Write-Host "Generated MOF files here: $MofPath"

Write-Host "Applying MOF files. DSC configuration"
Set-WSManQuickConfig -Force -Verbose
Start-DscConfiguration -Path $MofPath -Wait -Verbose -force

Write-Host "DSC extension run clean up"
Remove-Item -Path $MofPath -Force -Recurse