$Error.Clear()

# environment_vars = [
#            "install_log_file=${var.install_log_file}",
#			 "source_name=${source.name}"
# ]


$vsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe"
if (-not(Test-Path -PathType Leaf $vsPath))
{
    $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
}
& icacls $env:install_log_file /grant Users:F

schtasks /create /tn 'Finalize GDVM Configuration' /sc onstart /ru system /tr 'powershell.exe -WindowStyle Hidden -File C:\Azure-GDVM\Controller-Initialization.ps1'
Write-Output 'TASK COMPLETED: GDVM Finalization OS on-startup task created...'

if ($Error.Count -gt 0) { Write-Output 'ERRORS:'; for ( $i=$Error.Count-1; $i -ge 0; $i--) { $err=$Error[$i]; Write-Output "Line $($err.InvocationInfo.ScriptLineNumber): $($err.InvocationInfo.Line.Trim())    Error: $($err.Exception.Message)" }; throw 'Script errors' }

while ((Get-Service RdAgent).Status -ne 'Running') { Start-Sleep -s 5 }
while ((Get-Service WindowsAzureGuestAgent).Status -ne 'Running') { Start-Sleep -s 5 }
& $env:SystemRoot\System32\Sysprep\Sysprep.exe /oobe /generalize /mode:vm /quiet /quit
while($true) { $imageState = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break }}