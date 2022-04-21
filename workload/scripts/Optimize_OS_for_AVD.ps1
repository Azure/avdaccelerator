# OS Optimizations for WVD
Write-Host 'AIB Customization: OS Optimizations for WVD'
$appName = 'optimize'
$drive = 'C:\'
New-Item -Path $drive -Name $appName -ItemType Directory -ErrorAction SilentlyContinue
$LocalPath = $drive + '\' + $appName
Set-Location $LocalPath
Write-Host 'Created the local directory'
$osOptURL = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip'
$osOptURLexe = 'Windows_10_VDI_Optimize-main.zip'
$outputPath = $LocalPath + '\' + $osOptURLexe
Write-Host 'Loading up the repo to local folder'
Invoke-WebRequest -Uri $osOptURL -OutFile $outputPath
Write-Host 'AIB Customization: Starting OS Optimizations script'
Expand-Archive -LiteralPath 'C:\\Optimize\\Windows_10_VDI_Optimize-main.zip' -DestinationPath $Localpath -Force -Verbose
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
Set-Location -Path C:\\Optimize\\Virtual-Desktop-Optimization-Tool-main

# instrumentation
$osOptURL = 'https://raw.githubusercontent.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/main/Win10_VirtualDesktop_Optimize.ps1'
$osOptURLexe = 'optimize.ps1'
Invoke-WebRequest -Uri $osOptURL -OutFile $osOptURLexe

# Patch: overide the Win10_VirtualDesktop_Optimize.ps1 - setting 'Set-NetAdapterAdvancedProperty'(see readme.md)
Write-Host 'Patch: Disabling Set-NetAdapterAdvancedProperty'
$updatePath = 'C:\optimize\Virtual-Desktop-Optimization-Tool-main\Win10_VirtualDesktop_Optimize.ps1'
 ((Get-Content -Path $updatePath -Raw) -replace 'Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB', '#Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB') | Set-Content -Path $updatePath



Write-Host 'Patch: Disabling Set-NetAdapterAdvancedProperty in Windows_VDOT.ps1'
$updatePath = 'C:\optimize\Virtual-Desktop-Optimization-Tool-main\Windows_VDOT.ps1'
 ((Get-Content -Path $updatePath -Raw) -replace 'Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB', '#Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB') | Set-Content -Path $updatePath


# Patch: overide the REG UNLOAD, needs GC before, otherwise will Access Deny unload(see readme.md)

[System.Collections.ArrayList]$file = Get-Content $updatePath
$insert = @()
for ($i = 0; $i -lt $file.count; $i++) {
    if ($file[$i] -like '*& REG UNLOAD HKLM\DEFAULT*') {
        $insert += $i - 1
    }
}

#add gc and sleep
$insert | ForEach-Object { $file.insert($_, "                 Write-Host 'Patch closing handles and runnng GC before reg unload' `n              `$newKey.Handle.close()` `n              [gc]::collect() `n                Start-Sleep -Seconds 15 ") }

### Setting the RDP Shortpath.
Write-Host 'Configuring RDP ShortPath'

$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'

if (Test-Path $WinstationsKey) {
    New-ItemProperty -Path $WinstationsKey -Name 'fUseUdpPortRedirector' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force
    New-ItemProperty -Path $WinstationsKey -Name 'UdpPortNumber' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 3390 -Force
}

Write-Host 'Settin up the Windows Firewall Rue for RDP ShortPath'
New-NetFirewallRule -DisplayName 'Remote Desktop - Shortpath (UDP-In)' -Action Allow -Description 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]' -Group '@FirewallAPI.dll,-28752' -Name 'RemoteDesktop-UserMode-In-Shortpath-UDP' -PolicyStore PersistentStore -Profile Domain, Private -Service TermService -Protocol udp -LocalPort 3390 -Program '%SystemRoot%\system32\svchost.exe' -Enabled:True

### Setting the Screen Protection

Write-Host 'Configuring Screen Protection'

$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'

if (Test-Path $WinstationsKey) {
    New-ItemProperty -Path $WinstationsKey -Name 'fEnableScreenCaptureProtect' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force
}

Set-Content $updatePath $file

# run script
# .\optimize -WindowsVersion 2004 -Verbose
.\Win10_VirtualDesktop_Optimize.ps1 -Verbose -AcceptEULA
Write-Host 'AIB Customization: Finished OS Optimizations script Win10_VirtualDesktop_Optimize.ps1'

# Sleep for a min
Start-Sleep -Seconds 60
#Running new file

#Write-Host 'Running new AIB Customization script'
.\Windows_VDOT.ps1 -Verbose -AcceptEULA
Write-Host 'AIB Customization: Finished OS Optimizations script Windows_VDOT.ps1'



