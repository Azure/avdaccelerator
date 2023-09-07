$customDataFile ='C:\AzureData\CustomData.bin'
$localCongifFile ='C:\Azure-GDVM\GameDevVMConfig.ini'

$logFile = 'C:\Users\Public\Desktop\INSTALLED_SOFTWARE.txt'

function GetConfigValue([string] $name){

    $value=''

    if (Test-Path -Path $customDataFile) {
        $inputValues= Get-Content -Path $customDataFile -Raw | ConvertFrom-StringData
        if ($inputValues.ContainsKey($name) -and $inputValues[$name] ) {
            $value= $inputValues[$name]
        }
    }

    if (-Not $value) {
        if (Test-Path -Path $localCongifFile) {
            $inputValues= Get-Content -Path $localCongifFile -Raw | ConvertFrom-StringData
            if ($inputValues.ContainsKey($name) -and $inputValues[$name] ) {
                $value= $inputValues[$name]
            }
        }
    }

    return $value
}

#remove Teradici
function Remove-Teradici() {
    
    $teradiciSetup = 'C:\Teradici'
    if ( Test-Path -Path $teradiciSetup ) {   
        Remove-Item -Path $teradiciSetup -Recurse -Force
    }

    $teradiciUninstall = 'C:\Program Files\Teradici\PCoIP Agent\uninst.exe'
    if ( Test-Path -Path $teradiciUninstall ) {   
        Start-Process $teradiciUninstall -ArgumentList '/S /NoPostReboot' -Wait
    }

    (Get-Content $logFile | Where-Object { -not $_.Contains('- Teradici') }) | Set-Content $logFile
}

if (-not ((Test-Path -Path $customDataFile) -or (Test-Path -Path $localCongifFile))) { exit }
if (((GetConfigValue('deployedFromSolutionTemplate')) -eq 'True') -and $PSCommandPath.StartsWith('C:\Azure-GDVM')) { exit }

if ($PSCommandPath.StartsWith('C:\Azure-GDVM')) { Set-Location -Path 'C:\Azure-GDVM' }

$fileShareStorageAccount = GetConfigValue('fileShareStorageAccount')
$fileShareStorageAccountKey = GetConfigValue('fileShareStorageAccountKey')
$fileShareName = GetConfigValue('fileShareName')


$gdkVersion = GetConfigValue('gdkVersion')
$useVmToSysprepCustomImage = GetConfigValue('useVmToSysprepCustomImage')

$remoteAccessTechnology = GetConfigValue('remoteAccessTechnology')
$avdRegKey = GetConfigValue('avdRegistrationKey')

try {

    $ueVersion = ''
    $ueEditor = ''

 
    ./Task-CompleteUESetup.ps1 -ueVersion $ueVersion -ueEditor $ueEditor

    ./Task-CreateDataDisk.ps1

    ./Task-MountFileShare.ps1 -storageAccount $fileShareStorageAccount `
                              -storageAccountKey $fileShareStorageAccountKey `
                              -fileShareName $fileShareName

    ./Task-ConfigureLoginScripts.ps1 -gdkVersion $gdkVersion -ueVersion $ueVersion -ueEditor $ueEditor -useVmToSysprepCustomImage $useVmToSysprepCustomImage


    switch ($remoteAccessTechnology) {
        "RDP" { Remove-Teradici; if ($avdRegKey) { ./Task-AvdRegistration.ps1 -RegistrationToken $avdRegKey } }

    }
}
catch [Exception] {
    throw $_.Exception.Message
}
finally {
    if (Test-Path -Path $customDataFile) { Remove-Item -Path C:\AzureData -Recurse -Force }
    if (Test-Path -Path $localCongifFile) { Remove-Item -Path $localCongifFile -Force }
}


