$Error.Clear()

# environment_vars = [
#            "install_log_file=${var.install_log_file}",
#            "dlinks_gdk=${var.dlinks_gdk}"
# ]

. C:\Azure-GDVM\Utils-DownloadFile.ps1

$gdkLocation = $env:Public + '\gdk'
New-Item -ItemType 'directory' -Path $gdkLocation
$linksString = $env:dlinks_gdk
$linksArray = $linksString.Split(',')

foreach ($link in $linksArray)
{
   $gdkZip = $gdkLocation + '\' + $link.Split('/')[-1]
   Write-Output "DOWNLOAD URL - GDK: $link..."
   DownloadFile -url $link -localFile $gdkZip
   Expand-Archive -LiteralPath $gdkZip -DestinationPath $gdkZip.Replace('.zip', '')
   Remove-Item -Path $gdkZip -Force
}

reg add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' /v AllowAllTrustedApps /t REG_DWORD /d 0x00000001 /f
reg add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 0x00000001 /f

reg add 'HKLM\SOFTWARE\Microsoft\XboxLive'

Write-Output 'TASK COMPLETED: Microsoft GDK installation prepared...'

if ($Error.Count -gt 0) { Write-Output 'ERRORS:'; for ( $i=$Error.Count-1; $i -ge 0; $i--) { $err=$Error[$i]; Write-Output "Line $($err.InvocationInfo.ScriptLineNumber): $($err.InvocationInfo.Line.Trim())    Error: $($err.Exception.Message)" }; throw 'Script errors' }