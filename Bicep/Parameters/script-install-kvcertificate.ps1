$vaultUrl = 'https://<yourVaultName>.vault.azure.net'
$certName = '<yourCertName>'
$localPath = 'C:\Temp'

$Response = Invoke-RestMethod -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -Method GET -Headers @{Metadata="true"}
$KeyVaultToken = $Response.access_token

if ((Test-Path -Path $localPath) -eq $false) { New-Item -ItemType Directory -Path $localPath }

$uri = $vaultUrl + "/certificates/" + $certName + "?api-version=2016-10-01"

$cert = Invoke-RestMethod -Uri $uri -Method GET -Headers @{Authorization="Bearer $KeyVaultToken"}

$cert.cer | New-Item -Type File -Name "$certName.cer" -Path $localPath

Import-Certificate -FilePath "$localPath\$certName.cer" -CertStoreLocation Cert:\LocalMachine\Root\