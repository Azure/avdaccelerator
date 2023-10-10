
Param(
        [parameter(Mandatory)]
        [string]
        $HostPoolRegistrationToken
)

## Install AVD RD infra agent
# Download agent
$download = Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" -UseBasicParsing
$fileName = ($download.Headers.'Content-Disposition').Split('=')[1].Replace('"','')
$output = [System.IO.FileStream]::new("$pwd\$fileName", [System.IO.FileMode]::Create)
$output.write($download.Content, 0, $download.RawContentLength)
$output.close()
# Install agent
msiexec /i $fileName /quiet REGISTRATIONTOKEN=$HostPoolRegistrationToken
Start-Sleep -Seconds 5

## Install AVD RD infra agent
# Download agent
$download = Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" -UseBasicParsing
$fileName = ($download.Headers.'Content-Disposition').Split('=')[1].Replace('"','')
$output = [System.IO.FileStream]::new("$pwd\$fileName", [System.IO.FileMode]::Create)
$output.write($download.Content, 0, $download.RawContentLength)
$output.close()
# Install agent
msiexec /i $fileName /quiet
Start-Sleep -Seconds 5