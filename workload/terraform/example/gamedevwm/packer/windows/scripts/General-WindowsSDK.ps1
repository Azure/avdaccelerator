$Error.Clear()

# environment_vars = [
#            "install_log_file=${var.install_log_file}",
#            "dlink_winsdk=${var.dlink_winsdk}"
# ]

. C:\Azure-GDVM\Utils-DownloadFile.ps1

$winsdkLocation = $env:Public + '\winsdk'
New-Item -ItemType 'directory' -Path $winsdkLocation

$winsdkSetup = $winsdkLocation + '\winsdksetup.exe'

DownloadFile -url $env:dlink_winsdk -localFile $winsdkSetup

$productVersion = (Get-Item $winsdkSetup).VersionInfo.FileVersion

Start-Process $winsdkSetup -ArgumentList @('/features +','/quiet','/norestart') -Wait

Remove-Item -Path $winsdkLocation -Recurse -Force

Add-Content "$env:install_log_file" "- Windows SDK $productVersion"
Write-Output 'TASK COMPLETED: Windows SDK installed...'

if ($Error.Count -gt 0) { Write-Output 'ERRORS:'; for ( $i=$Error.Count-1; $i -ge 0; $i--) { $err=$Error[$i]; Write-Output "Line $($err.InvocationInfo.ScriptLineNumber): $($err.InvocationInfo.Line.Trim())    Error: $($err.Exception.Message)" }; throw 'Script errors' }