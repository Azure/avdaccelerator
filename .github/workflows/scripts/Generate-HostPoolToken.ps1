<#
    Updates the AVD application display name.
#>
param (
    [string]$HostPoolResourceGroupName,
    [string]$HostPoolName,
    [string]$KeyVaultName
)

#Write-Host "Generating new token for the host pool {0} in Resource Group {1}" -StringValues $HostPoolName, $HostPoolResourceGroupName
$hostPoolToken = New-AzWvdRegistrationInfo -ResourceGroupName $HostPoolResourceGroupName -HostPoolName $HostPoolName -ExpirationTime (Get-Date).AddHours(2) -ErrorAction Stop

# now update key vault
az keyvault secret set --name hostPoolRegistrationToken --vault-name $KeyVaultName --value $hostPoolToken