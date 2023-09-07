$Error.Clear()

# environment_vars = [
#            "install_log_file=${var.install_log_file}",
#            "dlink_lgpo_tool=${var.dlink_lgpo_tool}"
# ]

. C:\Azure-GDVM\Utils-DownloadFile.ps1

Get-PnpDevice | where {$_.friendlyname -like 'Microsoft Hyper-V Video' -and $_.status -eq 'OK'} | Disable-PnpDevice -confirm:$false
Write-Output 'TASK COMPLETED: Microsoft Hyper-V Video driver disabled'
$Error.Clear()

Stop-Service -Name defragsvc
$size = (Get-PartitionSupportedSize -DriveLetter 'C')
Resize-Partition -DriveLetter 'C' -Size $size.SizeMax

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Audiosrv -Name Start -Value 00000002
Write-Output 'TASK COMPLETED: Audio enabled'

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 00000001
Write-Output 'TASK COMPLETED: Long paths enabled'

reg load HKLM\DefaultUser C:\Users\Default\NTUSER.DAT
$path = "HKLM:\Defaultuser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-ItemProperty -Path $path -Name HideFileExt -Value "0" -PropertyType DWord -Force
New-ItemProperty -Path $path -Name Hidden -Value "1" -PropertyType DWord -Force
Write-Output 'TASK COMPLETED: Windows Explorer settings adjusted'

$path = "HKLM:\Defaultuser\Control Panel\Mouse"
Set-ItemProperty -Path $path -Name MouseSpeed -Value 1
$path = "HKLM:\Defaultuser\Control Panel\Accessibility\MouseKeys"
Set-ItemProperty -Path $path -Name Flags -Value 63
Write-Output 'TASK COMPLETED: Mouse speed/sensitivity settings adjusted'

Add-Content "$env:install_log_file" "INSTALLED SOFTWARE:"
Add-Content "$env:install_log_file" "==================="

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Output 'TASK COMPLETED: Chocolatey installed'

powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y dotnetfx --version 4.7.2 --force'
Add-Content "$env:install_log_file" "- .NET 4.7.2 (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'): choco install dotnetfx --version 4.7.2)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y vcredist140'
Add-Content "$env:install_log_file" "- Microsoft Visual C++ Redistributable for Visual Studio 2015-2022 (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install vcredist140)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y vcredist2017'
Add-Content "$env:install_log_file" "- Microsoft Visual C++ Redistributable for Visual Studio 2017 (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install vcredist2017)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y directx'
Add-Content "$env:install_log_file" "- DirectX (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install directx)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y 7zip'
Add-Content "$env:install_log_file" "- 7-Zip (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install 7zip)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y syspin'
Add-Content "$env:install_log_file" "- Syspin (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install syspin)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y git'
Add-Content "$env:install_log_file" "- Git (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install git)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y git-lfs'
Add-Content "$env:install_log_file" "- Git Large File Storage (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install git-lfs)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y github-desktop'
Add-Content "$env:install_log_file" "- GitHub Desktop (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install github-desktop)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y nodejs-lts'
Add-Content "$env:install_log_file" "- Node.js LTS (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install nodejs-lts)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y azcopy10'
Add-Content "$env:install_log_file" "- AzCopy (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install azcopy10)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y azure-cli'
Add-Content "$env:install_log_file" "- AzCli (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install azure-cli)"
powershell.exe -ExecutionPolicy Bypass -Command 'choco install -y visualstudiocode'
Add-Content "$env:install_log_file" "- Visual Studio Code (via Chocolatey as of $(Get-Date -Format 'yyyy-MM-dd'):  choco install visualstudiocode)"
Write-Output 'TASK COMPLETED: Chocolatey packages installed...'


New-Item -ItemType 'directory' -Path 'C:\LGPO'
DownloadFile -url $env:dlink_lgpo_tool -localFile 'C:\LGPO\LGPO.zip'

7z x 'C:\LGPO\LGPO.zip' -oC:\LGPO\
Add-Content 'C:\LGPO\GPUPolicies-Add.txt' "Computer`r`nSOFTWARE\Policies\Microsoft\Windows\Server\ServerManager`r`nDoNotOpenAtLogon`r`nDWORD:1`r`n"
Add-Content 'C:\LGPO\GPUPolicies-Add.txt' "Computer`r`nSOFTWARE\Policies\Microsoft\Windows NT\Terminal Services`r`nbEnumerateHWBeforeSW`r`nDWORD:1`r`n"
Add-Content 'C:\LGPO\GPUPolicies-Add.txt' "Computer`r`nSOFTWARE\Policies\Microsoft\Windows NT\Terminal Services`r`nAVCHardwareEncodePreferred`r`nDWORD:1`r`n"
Add-Content 'C:\LGPO\GPUPolicies-Add.txt' "Computer`r`nSOFTWARE\Policies\Microsoft\Windows NT\Terminal Services`r`nAVC444ModePreferred`r`nDWORD:1"
Add-Content 'C:\LGPO\GPUPolicies-Add.txt' "Computer`r`nSOFTWARE\Policies\Microsoft\Windows NT\Terminal Services`r`nfDisablePNPRedir`r`nDWORD:0"
C:\LGPO\LGPO_30\LGPO.exe /t 'C:\LGPO\GPUPolicies-Add.txt'
Remove-Item -Path 'C:\LGPO' -Recurse -Force
Write-Output 'TASK COMPLETED: GPU policies for RDP configured...'

$vsCodePath = $env:ProgramFiles + '\Microsoft VS Code\bin\code'
$extensionsDir = $env:ProgramFiles + '\Microsoft VS Code\resources\app\extensions'

if (Test-Path -Path $vsCodePath -PathType Leaf) {
    if (Test-Path -Path $extensionsDir -PathType Container) {
        & $vsCodePath --install-extension 'ms-dotnettools.csharp' --extensions-dir=$extensionsDir --force 2>$null
        & $vsCodePath --install-extension 'GitHub.vscode-pull-request-github' --extensions-dir=$extensionsDir --force 2>$null
    } else {
        Write-Error "Extensions directory does not exist: $extensionsDir"
    }
} else {
    Write-Error "VS Code executable does not exist: $vsCodePath"
}

## & $vsCodePath --install-extension 'ms-dotnettools.csharp' --extensions-dir=$extensionsDir --force 2>$null
## & $vsCodePath --install-extension 'GitHub.vscode-pull-request-github' --extensions-dir=$extensionsDir --force 2>$null
Add-Content "$env:install_log_file" "- Visual Studio Code extensions:"
Add-Content "$env:install_log_file" "  - ms-dotnettools.csharp"
Add-Content "$env:install_log_file" "  - GitHub.vscode-pull-request-github"
Write-Output 'TASK COMPLETED: VS Code plugins installed...'

if ($Error.Count -gt 0) { Write-Output 'ERRORS:'; for ( $i=$Error.Count-1; $i -ge 0; $i--) { $err=$Error[$i]; Write-Output "Line $($err.InvocationInfo.ScriptLineNumber): $($err.InvocationInfo.Line.Trim())    Error: $($err.Exception.Message)" }; throw 'Script errors' }