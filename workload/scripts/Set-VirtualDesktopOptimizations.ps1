##############################################################
#  Set Virtual Desktop Optimizations
##############################################################

# Set Variables
$ErrorActionPreference = 'Stop'
$Directory = 'optimize'
$Drive = 'C:\'
$WorkingDirectory = $Drive + '\' + $Directory
$Url = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip'
$Zip = 'Windows_VDI_Optimize-main.zip'
$OutputPath = $LocalPath + '\' + $Zip

try 
{
    Write-Host 'Virtual Desktop Optimization Tool (VDOT): Begin Prerequisites'

    # Create directory for VDOT
    New-Item -Path $Drive -Name $Directory -ItemType 'Directory' -ErrorAction 'SilentlyContinue'
    Set-Location $WorkingDirectory
    Write-Host 'Created the local directory'

    # Download VDOT
    Invoke-WebRequest -Uri $Url -OutFile $OutputPath
    Write-Host "Downloaded VDOT repo to $WorkingDirectory"

    # Extract VDOT
    Expand-Archive -LiteralPath $OutputPath -DestinationPath $WorkingDirectory -Force -Verbose
    Write-Host "Extracted VDOT from ZIP file"

    Set-ExecutionPolicy -ExecutionPolicy 'RemoteSigned' -Scope 'Process'
    Write-Host "Set Execution Policy"
    
    Set-Location -Path "$WorkingDirectory\Virtual-Desktop-Optimization-Tool-main"
    Write-Host "Set location"
    
    # Patch: overide setting 'Set-NetAdapterAdvancedProperty'(see readme.md)
    $UpdatePath = "$WorkingDirectory\Virtual-Desktop-Optimization-Tool-main\Windows_VDOT.ps1"
    ((Get-Content -Path $UpdatePath -Raw) -replace 'Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB', '#Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB') | Set-Content -Path $UpdatePath
    Write-Host 'Disabled Set-NetAdapterAdvancedProperty'
    
    # Patch: overide the REG UNLOAD, needs GC before, otherwise will Access Deny unload(see readme.md)
    <#[System.Collections.ArrayList]$File = Get-Content $UpdatePath
    $Insert = @()
    for ($i = 0; $i -lt $File.count; $i++) {
        if ($File[$i] -like '*& REG UNLOAD HKLM\DEFAULT*') {
            $Insert += $i - 1
        }
    }
    
    # Add gc and sleep
    $Insert | ForEach-Object { $File.insert($_, "                 Write-Host 'Patch closing handles and runnng GC before reg unload' `n              `$newKey.Handle.close()` `n              [gc]::collect() `n                Start-Sleep -Seconds 15 ") }
    Set-Content $UpdatePath $File
    Start-Sleep -Seconds 60 #>

    Write-Host 'Virtual Desktop Optimization Tool (VDOT): Completed Prerequisites'
    Write-Host 'Virtual Desktop Optimization Tool (VDOT): Begin Tool Execution'
    .\Windows_VDOT.ps1 -Optimizations 'All'-AdvancedOptimizations 'All' -AcceptEULA -Verbose
    Write-Host 'Virtual Desktop Optimization Tool (VDOT): Completed Tool Execution'  
}
catch 
{
    Write-Host $_.Exception
    throw
}




