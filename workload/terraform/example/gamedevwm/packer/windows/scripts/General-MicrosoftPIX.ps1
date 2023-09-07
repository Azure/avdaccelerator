$Error.Clear()

# environment_vars = [
#            "install_log_file=${var.install_log_file}",
#            "dlink_pix=${var.dlink_pix}"
# ]

. C:\Azure-GDVM\Utils-DownloadFile.ps1

$url = ''
$downloadPage = Invoke-WebRequest -UseBasicParsing -uri $env:dlink_pix
if ($downloadPage.RawContent -match 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/[a-zA-Z0-9]+') { $url = $Matches[0] }

$exe = $env:Public + '\PIX-Installer-x64.exe'

Write-Output "DOWNLOAD URL - Microsoft PIX: $url..."
DownloadFile -url $url -localFile $exe


$productName = (Get-Item $exe).VersionInfo.ProductName
$productVersion = (Get-Item $exe).VersionInfo.FileVersion

Start-Process $exe -ArgumentList '/install','/quiet','/norestart' -Wait
Remove-Item -Path $exe -Force

Add-Content "$env:install_log_file" "- Microsoft PIX $productVersion"
Write-Output 'TASK COMPLETED: PIX installed...'

if ($Error.Count -gt 0) { Write-Output 'ERRORS:'; for ( $i=$Error.Count-1; $i -ge 0; $i--) { $err=$Error[$i]; Write-Output "Line $($err.InvocationInfo.ScriptLineNumber): $($err.InvocationInfo.Line.Trim())    Error: $($err.Exception.Message)" }; throw 'Script errors' }